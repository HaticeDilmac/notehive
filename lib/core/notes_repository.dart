import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart'; // removed
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // removed

import 'note_model.dart';
import 'notes_service.dart';
import 'local/local_notes_data_source.dart';

// Not veri katmanı: backend API + yerel önbellek (Hive)
class NotesRepository {
  NotesRepository({
    NotesService? backendService,
    LocalNotesDataSource? local,
  }) : _backendService = backendService ?? NotesService(),
       _local = local ?? defaultLocal {
    // internet gelince bekleyen offline işlemleri tekrar dener
    if (_local != null) {
      _connSub ??= Connectivity().onConnectivityChanged.listen((list) {
        final status = list.isNotEmpty ? list.last : ConnectivityResult.none;
        if (status != ConnectivityResult.none) {
          syncPendingBackendOps();
        }
      });
    }
  }

  final NotesService _backendService;
  LocalNotesDataSource? _local;
  static LocalNotesDataSource? defaultLocal;
  static StreamSubscription<List<ConnectivityResult>>? _connSub;

  // Firestore doğrudan kullanılmıyor; eski metod kaldırıldı

  // FirebaseAuth uid artık burada kullanılmıyor; eski metod kaldırıldı

  // Firestore offline cache artık kullanılmıyor
  static Future<void> enablePersistence() async {}

  // backend üzerinden notları getirir (local cache + canlı Hive izleme + periyodik poll)
  Stream<List<NoteModel>> streamNotes({String query = ''}) {
    final controller = StreamController<List<NoteModel>>.broadcast();
    bool hasEmitted = false;

    DateTime _parseDate(dynamic v) {
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    Future<void> refresh() async {
      try {
        final conn = await Connectivity().checkConnectivity();
        if (conn == ConnectivityResult.none) {
          // offline: mevcut değeri koru
          return;
        }
        final data = await _backendService.fetchNotes();
        final items = data.map((m) {
          final id = (m['id'] ?? '') as String;
          return NoteModel(
            id: id,
            title: (m['title'] ?? '') as String,
            content: (m['content'] ?? '') as String,
            pinned: (m['pinned'] ?? false) as bool,
            createdAt: _parseDate(m['createdAt']),
            updatedAt: _parseDate(m['updatedAt']),
            isDirty: false,
          );
        }).toList(growable: false);

        if (_local != null) {
          for (final n in items) {
            await _local!.upsertNote(n);
          }
        }

        List<NoteModel> sorted = List.of(items)
          ..sort((a, b) {
            if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });

        if (query.isNotEmpty) {
          final lower = query.toLowerCase();
          sorted = sorted
              .where((n) => n.title.toLowerCase().contains(lower) || n.content.toLowerCase().contains(lower))
              .toList(growable: false);
        }

        controller.add(sorted);
        hasEmitted = true;
      } catch (_) {
        // ilk değer hiç yayınlanmadıysa hata göster, aksi halde yoksay
        if (!hasEmitted) {
          controller.addError('Failed to load notes');
        }
      }
    }

    Timer? timer;
    StreamSubscription<List<NoteModel>>? hiveSub;
    controller.onListen = () {
      // önce local cache ya da boş liste ver
      if (_local != null) {
        // İlk yerel anlık görüntüyü hemen yayınla ki UI beklemede kalmasın
        final initialLocal = _local!.getAllSorted(query: query);
        controller.add(initialLocal);
        hasEmitted = true;
        // Hive'daki değişiklikleri canlı izleyelim ki offline anında UI güncellensin
        hiveSub = _local!.watchSorted(query: query).listen((list) {
          controller.add(list);
          hasEmitted = true;
        });
      } else {
        controller.add(const <NoteModel>[]);
      }
      // ardından backend'den periyodik çek
      refresh();
      timer = Timer.periodic(const Duration(seconds: 5), (_) => refresh());
    };
    controller.onCancel = () {
      timer?.cancel();
      hiveSub?.cancel();
    };

    return controller.stream;
  }

  // yeni note oluştur (yalnızca backend + local cache)
  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    // offline veya online fark etmeksizin: yerelde hemen göster
    String tempId = DateTime.now().microsecondsSinceEpoch.toString();
    if (_local != null) {
      await _local!.upsertNote(
        NoteModel(
          id: tempId,
          title: title,
          content: content,
          pinned: false,
          createdAt: now,
          updatedAt: now,
          isDirty: true,
        ),
      );
    }
    // backend create
    _syncBackendSafe(
      () async {
        final created = await _backendService.createNote(title: title, content: content);
        final id = (created['id'] ?? '') as String;
        if (_local != null && id.isNotEmpty) {
          await _local!.upsertNote(
            NoteModel(
              id: id,
              title: (created['title'] ?? title) as String,
              content: (created['content'] ?? content) as String,
              pinned: (created['pinned'] ?? false) as bool,
              createdAt: DateTime.tryParse((created['createdAt'] ?? '') as String) ?? now,
              updatedAt: DateTime.tryParse((created['updatedAt'] ?? '') as String) ?? now,
              isDirty: false,
            ),
          );
          // eski geçici kaydı kaldır
          await _local!.deleteNote(tempId);
        }
      },
      fallbackOp: {
        'type': 'create',
        'data': {'title': title, 'content': content},
      },
    );
  }

  // mevcut note’u güncelle (yalnızca backend + local cache)
  Future<void> updateNote(NoteModel note) async {
    final now = DateTime.now();
    if (_local != null) {
      await _local!.upsertNote(
        NoteModel(
          id: note.id,
          title: note.title,
          content: note.content,
          pinned: note.pinned,
          createdAt: note.createdAt,
          updatedAt: now,
          isDirty: false,
        ),
      );
    }

    _syncBackendSafe(() async {
      await _backendService.updateNote(id: note.id, title: note.title, content: note.content);
    });
  }

  // pin durumunu değiştir (yalnızca backend + local cache)
  Future<void> togglePin(NoteModel note) async {
    if (_local != null) {
      await _local!.upsertNote(
        NoteModel(
          id: note.id,
          title: note.title,
          content: note.content,
          pinned: !note.pinned,
          createdAt: note.createdAt,
          updatedAt: DateTime.now(),
          isDirty: false,
        ),
      );
    }
    _syncBackendSafe(() async {
      await _backendService.updateNote(
        id: note.id,
        title: note.title,
        content: note.content,
        pinned: !note.pinned,
      );
    });
  }

  // note sil (yalnızca backend + local cache)
  Future<void> deleteNote(NoteModel note) async {
    if (_local != null) {
      await _local!.deleteNote(note.id);
    }

    _syncBackendSafe(() async {
      await _backendService.deleteNote(note.id);
    });
  }

  // backend sync helper: internet varsa çalıştırır, yoksa kuyruğa atar
  void _syncBackendSafe(
    Future<void> Function() task, {
    Map<String, dynamic>? fallbackOp,
  }) async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) {
        if (fallbackOp != null && _local != null) {
          await _local!.enqueueOp(fallbackOp);
        }
        return;
      }
      await task();
    } catch (_) {
      // ignore errors
    }
  }

  // offline kuyruğundaki işlemleri tekrar backend’e gönder
  Future<void> syncPendingBackendOps() async {
    if (_local == null) return;

    final status = await Connectivity().checkConnectivity();
    if (status == ConnectivityResult.none) return;

    final ops = _local!.pendingOps();
    for (final op in ops) {
      final type = op['type'] as String?;
      final data = Map<String, dynamic>.from(op['data'] as Map? ?? {});

      try {
        if (type == 'create') {
          final title = data['title'] as String? ?? '';
          final content = data['content'] as String? ?? '';
          await _backendService.createNote(title: title, content: content);
        }
        // ileride update/delete de eklenebilir
      } catch (_) {
        // başarısız olursa kuyruğa bırak, sonraki denemeye kalır
      }
    }

    await _local!.clearOps();
  }
}
