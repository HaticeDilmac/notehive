import 'package:flutter/material.dart';
import 'package:notehive/core/note_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notehive/core/notes_repository.dart';
import 'package:notehive/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'widgets/note_card.dart';
import 'widgets/notes_filter_bar.dart';
import 'widgets/note_editor_sheet.dart';
import 'widgets/greeting_header.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NotesRepository _repo = NotesRepository();
  String _query = '';
  bool _showPinnedOnly = false;
  bool _streamErrorShown = false;

  @override
  void initState() {
    super.initState();
  }

  void _setQuery(String q) => setState(() => _query = q);

  void _toggleFilter(bool showPinned) =>
      setState(() => _showPinnedOnly = showPinned);

  Future<void> _openEditor({NoteModel? note}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return NoteEditorSheet(
          note: note,
          onSubmit: (title, content) async {
            try {
              if (note == null) {
                await _repo.createNote(title: title, content: content);
              } else {
                await _repo.updateNote(
                  NoteModel(
                    id: note.id,
                    title: title,
                    content: content,
                    pinned: note.pinned,
                    createdAt: note.createdAt,
                    updatedAt: DateTime.now(),
                  ),
                );
              }
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${AppLocalizations.of(context)!.operationFailed}: $e',
                    ),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const GreetingHeader(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newNote),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(0.5.h),
              child: NotesFilterBar(
                onQueryChanged: _setQuery,
                showPinnedOnly: _showPinnedOnly,
                onToggleFilter: _toggleFilter,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<NoteModel>>(
                stream: _repo.streamNotes(query: _query),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    if (!_streamErrorShown) {
                      _streamErrorShown = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${AppLocalizations.of(context)!.error}: ${snapshot.error}',
                            ),
                          ),
                        );
                      });
                    }
                    return Center(
                      child: Text(
                        '${AppLocalizations.of(context)!.error}: ${snapshot.error}',
                      ),
                    );
                  } else {
                    // hata yoksa bayrağı sıfırla
                    _streamErrorShown = false;
                  }
                  final allNotes = snapshot.data ?? [];
                  final notes =
                      _showPinnedOnly
                          ? allNotes.where((n) => n.pinned).toList()
                          : allNotes;
                  if (notes.isEmpty) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.emptyNotes),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount =
                          width > 1100
                              ? 4
                              : width > 800
                              ? 3
                              : width > 500
                              ? 2
                              : 1;
                      return MasonryGridView.count(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final n = notes[index];
                          return NoteCard(
                            note: n,
                            colorIndex: index,
                            onTap: () => _openEditor(note: n),
                            onDelete: () async {
                              final deletedNote = n;
                              try {
                                await _repo.deleteNote(
                                  deletedNote,
                                ); //note deletee funct.
                                if (mounted) {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  messenger.hideCurrentSnackBar();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 4),
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.notesDeleted,
                                      ),
                                      action: SnackBarAction(
                                        label:
                                            AppLocalizations.of(
                                              context,
                                            )!.notesUndo,
                                        onPressed: () async {
                                          await _repo.createNote(
                                            title: deletedNote.title,
                                            content: deletedNote.content,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${AppLocalizations.of(context)!.deleteFailed}: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            onTogglePin: () async {
                              try {
                                await _repo.togglePin(n);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${AppLocalizations.of(context)!.pinFailed}: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
