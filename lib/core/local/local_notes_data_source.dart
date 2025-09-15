import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../note_model.dart';

// Notlar için basit yerel depolama ve offline sırayı burada tutuyoruz.
class LocalNotesDataSource {
  // Keys used for Hive boxes
  static const String notesBoxKey = 'notes_box';
  static const String opsBoxKey = 'pending_ops_box';

  // Hive kutuları
  late final Box<Map> _notesBox;
  late final Box<Map> _opsBox;

  // Uygulama açılırken bir kere çağırmak yeterli.
  static Future<LocalNotesDataSource> init() async {
    await Hive.initFlutter();
    final notes = await Hive.openBox<Map>(notesBoxKey);
    final ops = await Hive.openBox<Map>(opsBoxKey);
    return LocalNotesDataSource._(notes, ops);
  }

  // Private constructor, only used by init()
  LocalNotesDataSource._(this._notesBox, this._opsBox);

  // ---------------- NOT CRUD ----------------

  // NoteModel → Map
  Map<String, dynamic> _noteToMap(NoteModel note) {
    return {
      'title': note.title,
      'content': note.content,
      'pinned': note.pinned,
      'createdAt': note.createdAt.millisecondsSinceEpoch,
      'updatedAt': note.updatedAt.millisecondsSinceEpoch,
      'isDirty': note.isDirty,
    };
  }

  // Var ise günceller, yoksa ekler.
  Future<void> upsertNote(NoteModel note) async {
    await _notesBox.put(note.id, _noteToMap(note));
  }

  // ID ile not sil
  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  // Tüm notları getir; query varsa başlık/içeriğe göre filtreler.
  List<NoteModel> getAll({String query = ''}) {
    final items = _notesBox.keys
        .map((key) {
          final map = Map<String, dynamic>.from(
            _notesBox.get(key, defaultValue: {}) as Map,
          );
          return NoteModel.fromMap(key.toString(), map);
        })
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
  }

  // Basit sıralama: pin'li olanlar önce, sonra updatedAt (yeni → eski)
  List<NoteModel> getAllSorted({String query = ''}) {
    final list = getAll(query: query);
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  // Hive değiştikçe (put/delete) güncel sıralı listeyi yayınlar.
  Stream<List<NoteModel>> watchSorted({String query = ''}) {
    final controller = StreamController<List<NoteModel>>.broadcast();
    controller.add(getAllSorted(query: query));

    final sub = _notesBox.watch().listen((_) {
      controller.add(getAllSorted(query: query));
    });
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  // ---------------- PENDING OPS (offline sync queue) ----------------

  // Kuyruğa bir işlem ekle (ör: insert/update/delete)
  Future<void> enqueueOp(Map<String, dynamic> op) async {
    await _opsBox.add(op);
  }

  // Bekleyen tüm işlemler
  List<Map<String, dynamic>> pendingOps() {
    return _opsBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Senkron sonrası kuyruğu temizle
  Future<void> clearOps() async {
    await _opsBox.clear();
  }
}
