### NoteHive Backend (FastAPI)

This folder contains the FastAPI service for NoteHive. Every request must include a Firebase ID token. The backend verifies the token, extracts the user id (`uid`), and stores user notes in Firestore under `users/{uid}/notes`.

Data model: `users/{uid}/notes/{noteId}`
- Fields: `title`, `content`, `pinned` (bool), `createdAt`, `updatedAt`

### Requirements
- Python 3.10+
- pip
- Firebase Service Account JSON (for Admin SDK)

### Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate     # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

Provide the service account path via environment variable (must belong to your Firebase project):
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/Users/hatice/Development/FlutterProjects/notehive/backend/notehive-app-firebase-adminsdk-fbsvc-dcdf21c72c.json"   # macOS/Linux
# Windows PowerShell:
# $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\\abs\\path\\service-account.json"
```

### Run
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API root: `http://localhost:8000`

### How it connects to Firebase
- Admin SDK is initialized using `GOOGLE_APPLICATION_CREDENTIALS`.
- `Authorization: Bearer <ID_TOKEN>` is verified; `uid` is extracted.
- Notes are read/written at `users/{uid}/notes` so each user only sees their own data.

### Quick API examples
```bash
# List (current user)
curl -H "Authorization: Bearer <ID_TOKEN>" \
     http://localhost:8000/notes

# Create
curl -X POST \
  -H "Authorization: Bearer <ID_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"title":"Title","content":"Body"}' \
  http://localhost:8000/notes

# Update (noteId is a Firestore string id)
curl -X PUT \
  -H "Authorization: Bearer <ID_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"title":"New Title","content":"New Body"}' \
  http://localhost:8000/notes/<noteId>

# Delete
curl -X DELETE \
  -H "Authorization: Bearer <ID_TOKEN>" \
  http://localhost:8000/notes/<noteId>
```

> Tip: The Flutter app already attaches the ID token automatically. From terminal, sign in with Firebase Auth and obtain an ID token before calling the API.

### CORS & development
CORS is permissive in development. In production, restrict `allow_origins`.

### Emulator/SIM URLs
- Android emulator: `http://10.0.2.2:8000`
- iOS simulator/macOS: `http://127.0.0.1:8000`

### Notes
- Sorting by both `pinned` and `updatedAt` may require a composite index in Firestore.
- Ensure the service account has Firestore access (e.g., `roles/datastore.user`).