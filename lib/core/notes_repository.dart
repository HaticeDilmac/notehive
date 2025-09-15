import 'dart:async';
// lib/core/notes_repository.dart (en üst)
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart'; // BUNU SİLİN
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'note_model.dart';
import 'notes_service.dart';

class NotesRepository {
  NotesRepository({FirebaseFirestore? firestore, NotesService? backendService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _backendService = backendService ?? NotesService();

  final FirebaseFirestore _firestore;
  final NotesService _backendService;

  CollectionReference<Map<String, dynamic>> _userNotesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  Future<String> _uid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return user.uid;
  }

  // Enable offline persistence
  static Future<void> enablePersistence() async {
    try {
      // Newer Firestore versions: set settings for persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (_) {
      // Ignore if not supported or already enabled
    }
  }

  Stream<List<NoteModel>> streamNotes({String query = ''}) async* {
    final uid = await _uid();
    final base = _userNotesCollection(uid);
    Query<Map<String, dynamic>> coll;
    try {
      coll = base
          .orderBy('pinned', descending: true)
          .orderBy('updatedAt', descending: true);
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // Composite iindex nopt supported in offlineee modee
        coll = base.orderBy('updatedAt', descending: true);
      } else {
        rethrow;
      }
    }

    yield* coll.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((d) => NoteModel.fromMap(d.id, d.data()))
          .toList(growable: false);
      if (query.isEmpty) return items;
      final lower = query.toLowerCase();
      return items
          .where(
            (n) =>
                n.title.toLowerCase().contains(lower) ||
                n.content.toLowerCase().contains(lower),
          )
          .toList(growable: false);
    });
  }

  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    final uid = await _uid();
    final now = DateTime.now();
    final doc = _userNotesCollection(uid).doc();
    await doc.set({
      'title': title,
      'content': content,
      'pinned': false,
      'ownerId': uid,
      'createdAt': now.millisecondsSinceEpoch,
      'updatedAt': now.millisecondsSinceEpoch,
    });
    _syncBackendSafe(() async {
      await _backendService.createNote(title: title, content: content);
    });
  }

  Future<void> updateNote(NoteModel note) async {
    final uid = await _uid();
    final now = DateTime.now();
    await _userNotesCollection(uid).doc(note.id).update({
      'title': note.title,
      'content': note.content,
      'updatedAt': now.millisecondsSinceEpoch,
    });
    _syncBackendSafe(() async {
      // Firestore id is string; backend ids are ints. We skip mapping here.
      // You can extend backend to accept externalId for reconciliation.
    });
  }

  Future<void> togglePin(NoteModel note) async {
    final uid = await _uid();
    await _userNotesCollection(uid).doc(note.id).update({
      'pinned': !note.pinned,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteNote(NoteModel note) async {
    final uid = await _uid();
    await _userNotesCollection(uid).doc(note.id).delete();
    _syncBackendSafe(() async {
      // Optional: if you maintain mapping to backend ids, call delete
    });
  }

  void _syncBackendSafe(Future<void> Function() task) async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) return;
      await task();
    } catch (_) {
      // best-effort; ignore
    }
  }
}
