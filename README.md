## NoteHive

NoteHive is a cross‑platform notes app built with Flutter. It supports email authentication, email verification, user‑scoped notes, offline persistence with Firestore, and optional syncing with a FastAPI backend.

### Features
- Email sign in/up with verification (Firebase Auth)
- User‑scoped notes: each user only sees their own notes
- Notes stored in Firestore with offline persistence
- Modern notes UI (search, pin/unpin, edit, delete) with a responsive grid
- Optional FastAPI backend for server‑side validation and integrations

### Project Structure
- `lib/` Flutter app code (UI, blocs/cubits, repositories)
- `backend/` FastAPI service (verifies ID tokens and reads/writes Firestore)

### Prerequisites
- Flutter SDK
- A Firebase project (download `GoogleService-Info.plist` and `google-services.json` set up via FlutterFire)

### Run the App
```bash
flutter pub get
flutter run
```

### Backend (optional)
See `backend/README.md` for setup. In short:
```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\\Scripts\\activate
pip install -r requirements.txt
export GOOGLE_APPLICATION_CREDENTIALS="/abs/path/service-account.json"
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Android emulator uses `http://10.0.2.2:8000`, iOS simulator/macOS uses `http://127.0.0.1:8000`.

### Firestore Index
If you sort by both `pinned` and `updatedAt`, Firestore requires a composite index. Create it when prompted or via the console.

### Notes
- This repository includes sample UI and logic intended as a clean starting point. Tweak styles and architecture to your needs.
