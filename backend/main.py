from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any, Optional, List

# Firebase Admin SDK for verifying ID tokens and Firestore
try:
    import firebase_admin
    from firebase_admin import auth as firebase_auth
    from firebase_admin import firestore
    # Initialize only once; uses Application Default Credentials if available
    if not firebase_admin._apps:
        firebase_admin.initialize_app()
    db = firestore.client()
except Exception as e:
    firebase_admin = None   
    firebase_auth = None  
    db = None

app = FastAPI(title="NoteHive API")

# CORS (adjust origins as needed for web/dev)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


# Note model (request payload)
class NoteIn(BaseModel):
    title: str
    content: str
    pinned: bool | None = None


def _notes_collection_for_user(user_id: str):
    if db is None:
        raise HTTPException(status_code=500, detail="Database not configured")
    return db.collection("users").document(user_id).collection("notes")


# Dependency to get current Firebase user id from Authorization header
def get_current_user_id(authorization: Optional[str] = Header(None)) -> str:
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
    id_token = authorization.split(" ", 1)[1].strip()

    if firebase_auth is None:
        # Backend not configured with Firebase Admin credentials
        raise HTTPException(status_code=500, detail="Auth not configured on server")
    try:
        decoded = firebase_auth.verify_id_token(id_token)
        uid = decoded.get("uid")
        if not uid:
            raise HTTPException(status_code=401, detail="Invalid token")
        return uid
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def _serialize_doc(doc) -> Dict[str, Any]:
    data = doc.to_dict() or {}
    return {
        "id": doc.id,
        "title": data.get("title", ""),
        "content": data.get("content", ""),
        "pinned": bool(data.get("pinned", False)),
        "createdAt": data.get("createdAt"),
        "updatedAt": data.get("updatedAt"),
    }

# GET: Read current user's notes
@app.get("/notes")
def get_notes(user_id: str = Depends(get_current_user_id)) -> List[Dict[str, Any]]:
    coll = _notes_collection_for_user(user_id)
    try:
        query = coll.order_by("pinned", direction=firestore.Query.DESCENDING).order_by(
            "updatedAt", direction=firestore.Query.DESCENDING
        )
        docs = query.stream()
    except Exception:
        docs = coll.stream()
    return [_serialize_doc(d) for d in docs]


# POST: Create a note for current user
@app.post("/notes")
def create_note(note: NoteIn, user_id: str = Depends(get_current_user_id)):
    coll = _notes_collection_for_user(user_id)
    doc_ref = coll.document()
    payload = {
        "title": note.title,
        "content": note.content,
        "pinned": bool(note.pinned) if note.pinned is not None else False,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }
    doc_ref.set(payload)
    created = doc_ref.get()
    return _serialize_doc(created)


# PUT: Update a note (must belong to current user)
@app.put("/notes/{note_id}")
def update_note(note_id: str, note: NoteIn, user_id: str = Depends(get_current_user_id)):
    doc_ref = _notes_collection_for_user(user_id).document(note_id)
    snapshot = doc_ref.get()
    if not snapshot.exists:
        raise HTTPException(status_code=404, detail="Note not found")
    updates: Dict[str, Any] = {
        "title": note.title,
        "content": note.content,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }
    if note.pinned is not None:
        updates["pinned"] = bool(note.pinned)
    doc_ref.update(updates)
    updated = doc_ref.get()
    return _serialize_doc(updated)


# DELETE: Delete a note (must belong to current user)
@app.delete("/notes/{note_id}")
def delete_note(note_id: str, user_id: str = Depends(get_current_user_id)):
    doc_ref = _notes_collection_for_user(user_id).document(note_id)
    snapshot = doc_ref.get()
    if not snapshot.exists:
        raise HTTPException(status_code=404, detail="Note not found")
    doc_ref.delete()
    return {"message": f"Note {note_id} deleted"}