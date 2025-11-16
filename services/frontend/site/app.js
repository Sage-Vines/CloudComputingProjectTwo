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
    renderNotes(notes);
  } catch (err) {
    console.error("could not fetch notes", err);
  }
}

function renderNotes(notes) {
  //not diffing for performance, just destroying and rebuilding the list
  notesListElement.innerHTML = "";
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
    const res = await fetch(endpoint, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, content }),
    });
    if (!res.ok) throw new Error(await res.text());
    resetForm();
    await pullNotesFromServer();
  } catch (err) {
    alert("Oops, note failed to save. check console.");
    console.error(err);
  } finally {
    saveNoteButton.disabled = false;
  }
}

async function removeNoteForever(id) {
  //allows user to delete notes as if they never existed
  if (!confirm("Do you actually want to delete this note?")) return;
  try {
    const res = await fetch(`/api/notes/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error(await res.text());
    if (activeNoteId === id) resetForm();
    await pullNotesFromServer();
  } catch (err) {
    alert("Could not delete note.");
    console.error(err);
  }
}

saveNoteButton.addEventListener("click", upsertNoteFromForm);
cancelEditButton.addEventListener("click", resetForm);
pullNotesFromServer();
