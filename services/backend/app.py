#stdlib web server, now stores notes in postgres without fancy frameworks
# intentionally scrappy so you can read it without a framework manual nearby
import json
import os
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

import psycopg


def grab_env_var(name: str, default: str = "") -> str:
  #just a helper so we dont repeat os.environ.get everywhere
  return os.environ.get(name, default)


#global-ish config so rest of file doesnt need to keep threading env vars
DB_CONFIG = {
    "host": grab_env_var("DATABASE_HOST", "postgres-db"),
    "dbname": grab_env_var("DATABASE_NAME", "app_db"),
    "user": grab_env_var("DATABASE_USER", "app_user"),
    "password": grab_env_var("DATABASE_PASSWORD", ""),
    "port": int(grab_env_var("DATABASE_PORT", "5432")),
}


def init_db():
  """creates the notes table if it doesnt exist"""
  # create notes table if someone destroyed it, keeps demo resilient
  #print("init db called")  #debug
  with psycopg.connect(**DB_CONFIG) as conn:
    conn.execute("""
        CREATE TABLE IF NOT EXISTS notes (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL DEFAULT '',
          content TEXT NOT NULL DEFAULT '',
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
    """)


def fetch_newest_notes():
  #grabs everything newest-first so the UI feels responsive
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      cur.execute("SELECT id, title, content, created_at FROM notes ORDER BY created_at DESC;")
      rows = cur.fetchall()
      return [
          {"id": row[0], "title": row[1], "content": row[2], "created_at": row[3].isoformat()}
          for row in rows
      ]


def add_note_record(title: str, content: str):
  """Insert note & eturn new row so UI can refresh w/out roundtrips"""
  #bare bones insert w/ RETURNING so we echo data back
  #try:
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      cur.execute("INSERT INTO notes (title, content) VALUES (%s, %s) RETURNING id, created_at;", (title, content))
      row = cur.fetchone()
      conn.commit()
      return {"id": row[0], "title": title, "content": content, "created_at": row[1].isoformat()}
  #except Exception as e:
  #  print(f"error adding note: {e}")  #left this here for debugging


def edit_note_record(note_id: int, title: str, content: str):
  #updates a note, returns None if it doesnt exist
  #TODO: maybe add validation here later?
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      #print(f"editing note {note_id}")  #debug line
      cur.execute("""
          UPDATE notes
             SET title = %s, content = %s
           WHERE id = %s
       RETURNING id, created_at;
      """, (title, content, note_id))
      row = cur.fetchone()
      if not row:
        return None
      conn.commit()
      return {"id": row[0], "title": title, "content": content, "created_at": row[1].isoformat()}


def remove_note_record(note_id: int):
  #simple delete, just checks if anything got removed
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      cur.execute("DELETE FROM notes WHERE id = %s;", (note_id,))
      deleted = cur.rowcount > 0  # did we actually delete something?
      conn.commit()
      return deleted


def extract_note_id(path: str) -> int | None:
  #extract note id from path like /api/notes/123
  #accepts /api/notes/123 and shrugs at bad input instead of crashing
  parts = path.rstrip("/").split("/")
  #print(f"extracting id from {parts}")  #was debugging path parsing
  if len(parts) == 4 and parts[1] == "api" and parts[2] == "notes":
    try:
      return int(parts[3])
    except ValueError:
      return None
  return None


class Handler(BaseHTTPRequestHandler):

  def send_json_response(self, payload, status=200):
    #helper to send json with proper headers, reused everywhere
    body = json.dumps(payload).encode("utf-8")
    self.send_response(status)
    self.send_header("Content-Type", "application/json")
    self.send_header("Content-Length", str(len(body)))
    self.end_headers()
    self.wfile.write(body)

  def do_GET(self):
    #just return all notes, simple enough
    path = urlparse(self.path).path
    if path == "/api/notes":
      try:
        notes = fetch_newest_notes()
        self.send_json_response(notes)
      except Exception as e:
        print(f"error fetching notes: {e}")  #keep this for now
        self.send_json_response({"error": "server error"}, status=500)
    else:
      self.send_json_response({"error": "not found"}, status=404)

  def do_POST(self):
    """Create a new note when form submits"""
    path = urlparse(self.path).path
    if path != "/api/notes":
      self.send_json_response({"error": "not found"}, status=404)
      return

    payload = self.read_request_json()
    if payload is None:
      return

    title, content = self.normalize_note_payload(payload)
    if title is None: return

    #might need to catch errors here but seems to work for now
    note = add_note_record(title[:120], content[:2000])  # cap title/content length
    #print(f"created note: {note['id']}")  #debug
    self.send_json_response(note, status=201)

  def do_PUT(self):
    #update existing note, basically same as POST but with id in path
    path = urlparse(self.path).path
    note_id = extract_note_id(path)
    if note_id is None:
      self.send_json_response({"error": "note id missing"}, status=400)
      return

    payload = self.read_request_json()
    if payload is None: return

    title, content = self.normalize_note_payload(payload)
    if title is None: return

    updated = edit_note_record(note_id, title[:120], content[:2000])
    if not updated:
      self.send_json_response({"error": "note was not found"}, status=404)
      return
    self.send_json_response(updated)

  def do_DELETE(self):  # noqa: N802
    """Trash note entirely."""
    path = urlparse(self.path).path
    note_id = extract_note_id(path)
    if note_id is None:
      self.send_json_response({"error": "note id is missing"}, status=400)
      return

    #ensures that note is actually deleted
    if remove_note_record(note_id):
      self.send_json_response({"status": "gone"})
    else:
      self.send_json_response({"error": "note was not found"}, status=404)

  def read_request_json(self):
    #best-effort JSON parsing, sends 400 if it fails
    length = int(self.headers.get("Content-Length", 0))
    data = self.rfile.read(length) if length else b"{}"
    try:
      return json.loads(data)
    except json.JSONDecodeError as e:
      #print(f"json error: {e}")  #debug
      self.send_json_response({"error": "bad json payload"}, status=400)
      return None
    #should probably catch other exceptions too but whatever

  def normalize_note_payload(self, payload):
    #extract & validate title/content, trim whitespace
    title = (payload.get("title") or "").strip()
    content = (payload.get("content") or "").strip()
    if not title and not content:
      self.send_json_response({"error": "need a title or some content"}, status=422)
      return None, None
    return title, content


def main():
  init_db()  #ensure table exists before starting
  port = int(grab_env_var("PORT", "5000"))
  #port = 5001  #temp test port
  server = HTTPServer(("0.0.0.0", port), Handler)
  print(f"Backend server listening on :{port}")
  #print("starting server...")  #debug
  server.serve_forever()


if __name__ == "__main__":
  main()
