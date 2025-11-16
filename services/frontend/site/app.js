//vanilla JavaScript because frameworks felt like overkill for a lil app
const notesListElement = document.querySelector("#notesList");
const noteTemplateElement = document.querySelector("#noteTemplate");
const titleField = document.querySelector("#title");
const contentField = document.querySelector("#content");
const saveNoteButton = document.querySelector("#saveBtn");
const cancelEditButton = document.querySelector("#cancelBtn");

//track which note is being edited so button toggles between save/update
let activeNoteId = null;

async function pullNotesFromServer() {
  try {
    const res = await fetch("/api/notes");
    if (!res.ok) throw new Error("Failed to load");
    const notes = await res.json();
    //console.log("fetched notes:", notes.length);  //debug
    renderNotes(notes);
  } catch (err) {
    console.error("could not fetch notes", err);
    //should probably show user an error but whatever
  }
}

function renderNotes(notes) {
  //not diffing for performance, just destroying and rebuilding the list
  notesListElement.innerHTML = "";
  //if (notes.length === 0) console.log("no notes to render");  //debug
  notes.forEach((note) => {
    const node = noteTemplateElement.content.cloneNode(true);
    node.querySelector(".note-title").textContent = note.title || "Untitled";
    node.querySelector(".note-body").textContent = note.content || "";
    node.querySelector(".note-date").textContent = new Date(note.created_at).toLocaleString();
    const editBtn = node.querySelector(".note-edit");
    const deleteBtn = node.querySelector(".note-delete");
    editBtn.addEventListener("click", () => beginEditingNote(note));
    deleteBtn.addEventListener("click", () => removeNoteForever(note.id));
    notesListElement.appendChild(node);
  });
}

function beginEditingNote(note) {
  //drop note data back into form so users can tweak typos
  activeNoteId = note.id;
  //console.log("editing note:", note.id);  //was debugging
  titleField.value = note.title;
  contentField.value = note.content;
  saveNoteButton.textContent = "Update note";
  cancelEditButton.hidden = false;
}

function resetForm() {
  activeNoteId = null;
  titleField.value = "";
  contentField.value = "";
  saveNoteButton.textContent = "Save note";
  cancelEditButton.hidden = true;
}

async function upsertNoteFromForm() {
  const title = titleField.value.trim();
  const content = contentField.value.trim();
  if (!title && !content) {
    alert("Need at least a title or some content");
    return;
  }
  saveNoteButton.disabled = true;
  try {
    const endpoint = activeNoteId ? `/api/notes/${activeNoteId}` : "/api/notes";
    const method = activeNoteId ? "PUT" : "POST";
    //console.log(`saving note via ${method} to ${endpoint}`);  //debug
    const res = await fetch(endpoint, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, content }),
    });
    if (!res.ok) {
      const errorText = await res.text();
      throw new Error(errorText);
    }
    resetForm();
    await pullNotesFromServer();
  } catch (err) {
    //sometimes the error is helpful, sometimes not
    alert("Oops, note failed to save. check console.");
    console.error("save error:", err);
  } finally {
    saveNoteButton.disabled = false;
  }
}

async function removeNoteForever(id) {
  //allows user to delete notes as if they never existed
  if (!confirm("Do you actually want to delete this note?")) return;
  //console.log("deleting note:", id);  //debug
  const res = await fetch(`/api/notes/${id}`, { method: "DELETE" });
  if (!res.ok) {
    alert("Could not delete note.");
    console.error("delete failed:", await res.text());
    return;
  }
  if (activeNoteId === id) resetForm();
  await pullNotesFromServer();
  //removed try/catch here, see if it works without it
}

saveNoteButton.addEventListener("click", upsertNoteFromForm);
cancelEditButton.addEventListener("click", resetForm);
pullNotesFromServer();  //load notes on page load
//pullNotesFromServer();  //duplicate, was testing something
