class NoteModel {
  final String id;
  final String title;
  final String content;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Whether this note is pending local-only change (unsynced)
  final bool isDirty;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = false,
  });

  Map<String, dynamic> toMap({required String ownerId}) {
    return {
      'title': title,
      'content': content,
      'pinned': pinned,
      'ownerId': ownerId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static NoteModel fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      title: (map['title'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      pinned: (map['pinned'] ?? false) as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] ?? 0) as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] ?? 0) as int,
      ),
      isDirty: (map['isDirty'] ?? false) as bool,
    );
  }
}


