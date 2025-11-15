# stdlib web server, now stores notes in postgres without fancy frameworks
# intentionally scrappy so you can read it without a framework manual nearby
import json
import os
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse

import psycopg


def env(name: str, default: str = "") -> str:
  """Grab env vars with a fallback so local dev isnt brittle."""
  return os.environ.get(name, default)


# global-ish config so the rest of the file doesnt need to keep threading env vars
DB_CONFIG = {
    "host": env("DATABASE_HOST", "postgres-db"),
    "dbname": env("DATABASE_NAME", "app_db"),
    "user": env("DATABASE_USER", "app_user"),
    "password": env("DATABASE_PASSWORD", ""),
    "port": int(env("DATABASE_PORT", "5432")),
}


def init_db():
  """Create the notes table on boot so the API never crashes on missing schema."""
  # create the notes table if someone destroyed it, keeps demo resilient
  with psycopg.connect(**DB_CONFIG) as conn:
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS notes (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL DEFAULT '',
          content TEXT NOT NULL DEFAULT '',
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
        """
    )


def list_notes():
  """Return every note newest-first for the frontend list."""
  # grab everything newest first so the UI feels lively
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      cur.execute(
          "SELECT id, title, content, created_at FROM notes ORDER BY created_at DESC;"
      )
      rows = cur.fetchall()
      return [
          {
              "id": row[0],
              "title": row[1],
              "content": row[2],
              "created_at": row[3].isoformat(),
          }
          for row in rows
      ]


def insert_note(title: str, content: str):
  """Insert a note and return the new row so UI can refresh without round-trips."""
  # bare bones insert with a RETURNING so we can echo data back to the UI
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      cur.execute(
          "INSERT INTO notes (title, content) VALUES (%s, %s) RETURNING id, created_at;",
          (title, content),
      )
      row = cur.fetchone()
      conn.commit()
      return {
          "id": row[0],
          "title": title,
          "content": content,
          "created_at": row[1].isoformat(),
      }


def update_note(note_id: int, title: str, content: str):
  """Persist edits; returns None if the row vanished."""
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      cur.execute(
          """
          UPDATE notes
             SET title = %s,
                 content = %s
           WHERE id = %s
       RETURNING id, created_at;
          """,
          (title, content, note_id),
      )
      row = cur.fetchone()
      if not row:
        return None
      conn.commit()
      return {
          "id": row[0],
          "title": title,
          "content": content,
          "created_at": row[1].isoformat(),
      }


def delete_note(note_id: int):
  """Delete a note and report whether anything actually disappeared."""
  with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:
      cur.execute("DELETE FROM notes WHERE id = %s;", (note_id,))
      deleted = cur.rowcount > 0
      conn.commit()
      return deleted


def note_id_from_path(path: str) -> int | None:
  """Extract note id from routes like /api/notes/123 and ignore noise."""
  # accepts /api/notes/123 and shrugs at bad input instead of crashing
  parts = path.rstrip("/").split("/")
  if len(parts) == 4 and parts[1] == "api" and parts[2] == "notes":
    try:
      return int(parts[3])
    except ValueError:
      return None
  return None


class Handler(BaseHTTPRequestHandler):

  def _json(self, payload, status=200):
    """Consistent JSON responses with length + type headers."""
    body = json.dumps(payload).encode("utf-8")
    self.send_response(status)
    self.send_header("Content-Type", "application/json")
    self.send_header("Content-Length", str(len(body)))
    self.end_headers()
    self.wfile.write(body)

  def do_GET(self):  # noqa: N802 (keeping name default)
    """Serve /api/notes listing."""
    path = urlparse(self.path).path
    if path == "/api/notes":
      notes = list_notes()
      self._json(notes)
    else:
      self._json({"error": "not found"}, status=404)

  def do_POST(self):  # noqa: N802
    """Create a new note when the form submits."""
    path = urlparse(self.path).path
    if path != "/api/notes":
      self._json({"error": "not found"}, status=404)
      return

    payload = self._read_json()
    if payload is None:
      return

    title, content = self._extract_body(payload)
    if title is None:
      return

    note = insert_note(title[:120], content[:2000])
    self._json(note, status=201)

  def do_PUT(self):  # noqa: N802
    """Update an existing note; body matches POST payload."""
    path = urlparse(self.path).path
    note_id = note_id_from_path(path)
    if note_id is None:
      self._json({"error": "note id missing"}, status=400)
      return

    payload = self._read_json()
    if payload is None:
      return

    title, content = self._extract_body(payload)
    if title is None:
      return

    updated = update_note(note_id, title[:120], content[:2000])
    if not updated:
      self._json({"error": "note not found"}, status=404)
      return
    self._json(updated)

  def do_DELETE(self):  # noqa: N802
    """Trash a note entirely."""
    path = urlparse(self.path).path
    note_id = note_id_from_path(path)
    if note_id is None:
      self._json({"error": "note id missing"}, status=400)
      return

#ensures that note is actually deleted
    if delete_note(note_id):
      self._json({"status": "gone"})
    else:
      self._json({"error": "note not found"}, status=404)

  def _read_json(self):
    """Best-effort JSON parser that surfaces 400s for bad payloads."""
    length = int(self.headers.get("Content-Length", 0))
    data = self.rfile.read(length) if length else b"{}"
    try:
      return json.loads(data)
    except json.JSONDecodeError:
      self._json({"error": "bad json payload"}, status=400)
      return None

  def _extract_body(self, payload):
    """Validate title/content presence and normalize whitespace."""
    title = (payload.get("title") or "").strip()
    content = (payload.get("content") or "").strip()
    if not title and not content:
      self._json({"error": "need a title or some content"}, status=422)
      return None, None
    return title, content


def main():
  init_db()
  port = int(env("PORT", "5000"))
  server = HTTPServer(("0.0.0.0", port), Handler)
  print(f"Backend server listening on :{port}")
  server.serve_forever()


if __name__ == "__main__":
  main()

