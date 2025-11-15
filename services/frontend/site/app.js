//vanilla Javascript
const notesList = document.querySelector("#notesList");
const template = document.querySelector("#noteTemplate");
const titleInput = document.querySelector("#title");
const contentInput = document.querySelector("#content");
const saveBtn = document.querySelector("#saveBtn");
const cancelBtn = document.querySelector("#cancelBtn");

// track which note is being edited so the button toggles between save/update
let editingId = null;

async function fetchNotes() {
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
  // not diffing for performance, just destroying and rebuilding the list
  notesList.innerHTML = "";
  notes.forEach((note) => {
    const node = template.content.cloneNode(true);
    node.querySelector(".note-title").textContent = note.title || "Untitled";
    node.querySelector(".note-body").textContent = note.content || "";
    node.querySelector(".note-date").textContent = new Date(
        note.created_at
    ).toLocaleString();

    const editBtn = node.querySelector(".note-edit");
    const deleteBtn = node.querySelector(".note-delete");
    editBtn.addEventListener("click", () => startEdit(note));
    deleteBtn.addEventListener("click", () => removeNote(note.id));

    notesList.appendChild(node);
  });
}

function startEdit(note) {
  //drop note data back into the form so users can tweak typos
  editingId = note.id;
  titleInput.value = note.title;
  contentInput.value = note.content;
  saveBtn.textContent = "Update note";
  cancelBtn.hidden = false;
}

function resetForm() {
  editingId = null;
  titleInput.value = "";
  contentInput.value = "";
  saveBtn.textContent = "Save note";
  cancelBtn.hidden = true;
}

async function saveNote() {
  const title = titleInput.value.trim();
  const content = contentInput.value.trim();
  if (!title && !content) {
    alert("Need at least a title or some content, otherwise it's blank air");
    return;
  }

  saveBtn.disabled = true;
  try {
    const endpoint = editingId ? `/api/notes/${editingId}` : "/api/notes";
    const method = editingId ? "PUT" : "POST";
    const res = await fetch(endpoint, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, content }),
    });
    if (!res.ok) throw new Error(await res.text());
    resetForm();
    await fetchNotes();
  } catch (err) {
    alert("Oops, note failed to save. check console.");
    console.error(err);
  } finally {
    saveBtn.disabled = false;
  }
}

async function removeNote(id) {
  //allows user to delete their notes as if they never existed
  if (!confirm("Do you actually want to delete this note?")) return;
  try {
    const res = await fetch(`/api/notes/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error(await res.text());
    if (editingId === id) resetForm();
    await fetchNotes();
  } catch (err) {
    alert("Could not delete note.");
    console.error(err);
  }
}

saveBtn.addEventListener("click", saveNote);
cancelBtn.addEventListener("click", resetForm);
fetchNotes();
