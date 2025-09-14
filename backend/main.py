from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

#Note model
class Note(BaseModel):
              # id: verify_id_token
              title: str
              content: str

#fake database
notes_db={}
note_counter=0

#read all notes
@app.get("/notes")
def get_notes():
              return [{"id": note_id, **note} for note_id, note in notes_db.items()]

#POST create note
@app.post("/notes")
def create_note(note: Note):
              global note_counter
              note_counter += 1
              notes_db[note_counter] = note.dict()
              return {"id": note_counter, **note.dict()}

#PUT update note
@app.put("/notes/{note_id}")
def update_note(note_id: int , note: Note):
              if note_id not in notes_db:
                            raise HTTPException(status_code=404, detail="Note not found")
              notes_db[note_id] = note.dict()
              return {"id": note_id, **note.dict()}

#DELETE delete notes
@app.delete("/notes/{note_id}")
def delete_note(note_id: int):
              if note_id not in notes_db:
                            raise HTTPException(status_code=404, detail="Note not found")
              del notes_db[note_id]
              return {"message": f"Note {note_id} deleted"}