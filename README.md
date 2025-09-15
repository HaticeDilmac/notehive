## NoteHive

A modern, cross‑platform notes app. It features email auth, user‑scoped notes, pin/search, offline cache (Hive), a FastAPI backend, and optional AI summarization (OpenAI/OpenRouter).

## Features
- Email sign‑in/up with verification (Firebase Auth)
- User‑scoped notes (each user sees only their data)
- Notes: create, edit, delete, pin/unpin, search, responsive masonry grid
- Offline‑first UX: Hive local cache; background sync when online
- Backend: FastAPI + Firebase Admin (verifies ID tokens; reads/writes in Firestore under `users/{uid}/notes`)
- AI Summarization: one‑tap summary from the editor content

## Architecture at a Glance
- The app uses FastAPI as the primary data source. After sign‑in, all API calls include `Authorization: Bearer <ID_TOKEN>`.
- `NotesRepository`
  - Stream: watches Hive (instant UI updates offline) and polls backend periodically.
  - CRUD: calls backend only; writes to Hive for instant UX. Create is queued offline (update/delete can be extended similarly).
- Backend (FastAPI): verifies the ID token and works in Firestore at `users/{uid}/notes`.
- AI: API key is loaded from `.env`; supports OpenAI or OpenRouter.

## Project Structure
- `lib/`
  - `core/`
    - `notes_repository.dart`: data layer (backend + Hive). Stream and CRUD.
    - `notes_service.dart`: backend HTTP client (attaches ID token).
    - `local/local_notes_data_source.dart`: Hive local cache + offline queue.
    - `note_model.dart`: note entity.
    - `ai_summarizer.dart`: OpenAI/OpenRouter summarizer service.
    - `auth_service.dart`: auth helpers.
  - `presentation/`: pages and widgets (Notes, Editor Sheet, etc.)
  - `logic/`: cubits/blocs (theme, language, auth).
  - `l10n/`: localization (en/tr).
  - `routes/`: app router.
- `backend/`: FastAPI service (`main.py`, `requirements.txt`, README)

## Requirements
- Flutter SDK (stable)
- Firebase project: platform configs set up
  - Android: `android/app/google-services.json`
  - iOS/macOS: `ios/Runner/GoogleService-Info.plist` (plus standard configs in `macos/Runner`)
  - Dart: `lib/firebase_options.dart` (generated via FlutterFire CLI)

## Run the App
```bash
flutter pub get
flutter run
```
Notes:
- Android emulator backend URL: `http://10.0.2.2:8000`
- iOS simulator/macOS: `http://127.0.0.1:8000`

## Localization (Flutter gen-l10n)
- ARB files live under `lib/l10n/` (`app_en.arb`, `app_tr.arb`).
- `pubspec.yaml` has `flutter: generate: true`, so localizations are generated on build.
- If you add/change ARB keys and want to regenerate manually:
```bash
flutter gen-l10n
```
- Generated files include `lib/l10n/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_tr.dart`.

## Backend Setup (FastAPI)
See `backend/README.md`. TL;DR:
```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Firebase Admin credentials (Service Account JSON)
export GOOGLE_APPLICATION_CREDENTIALS="/abs/path/service-account.json"

uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
Do NOT commit the service account JSON. Keep it locally and reference it via env var.

## AI Summarization (.env)
1) Create `.env` at the project root. Ensure `.env` is listed under `flutter/assets` in `pubspec.yaml` (already set).
2) Example content:
```
OPENAI_API_KEY=sk-xxxx
OPENAI_MODEL=gpt-4o-mini
# Optional OpenAI organization
OPENAI_ORG=
# Optional: use OpenRouter instead of OpenAI
# OPENAI_BASE_URL=https://openrouter.ai/api/v1
# OPENROUTER_SITE_URL=https://example.com
# OPENROUTER_APP_NAME=NoteHive
```
3) Fully restart the app (hot reload is not enough).

> If you get 429 (rate limit) or 401/403 (auth), check your billing/model access. OpenAI no longer has permanent free quotas. OpenRouter may offer free/cheaper models.

## Offline Behavior
- `LocalNotesDataSource` stores notes in Hive and emits changes live.
- When offline:
  - The list comes from Hive; pinned notes remain on top.
  - Creating a note shows immediately with a temporary ID; it syncs when online.
  - Current implementation queues create. You can extend to queue update/delete as well.

## Troubleshooting
- Backend 500 / `Auth not configured on server`:
  - Ensure `GOOGLE_APPLICATION_CREDENTIALS` points to your service account JSON.
- 401/403 (backend/AI):
  - Are you signed in? Is the ID token attached? For AI, is the API key valid and the model allowed?
- 429 (AI):
  - Slow down, shorten the text, and/or add billing/credits.
- Android emulator cannot reach backend:
  - Use `10.0.2.2` (iOS/macOS uses `127.0.0.1`).

## Screenshots
Place images under `docs/screenshots/` and reference them here, e.g.:

![Home](docs/screenshots/home.png)
![Editor](docs/screenshots/editor.png)
![Dark Mode](docs/screenshots/dark.png)

## Demo Video
Add a link to a hosted video (YouTube, Loom, etc.) or a GIF:

- YouTube: https://your-demo-video-url
- or embed a GIF: `docs/demo.gif`

## Development Notes
- The notes stream polls the backend every 5s and merges with live Hive updates for instant UX.
- `NotesService` auto‑selects base URL per platform (Android `10.0.2.2`, others `127.0.0.1`).
- Localization keys live in `lib/l10n`.

## License
Sample application for educational purposes. Adapt and extend as needed.
