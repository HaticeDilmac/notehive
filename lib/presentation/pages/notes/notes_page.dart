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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newNote),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const GreetingHeader(),
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
                    print(
                      "${AppLocalizations.of(context)!.error}: ${snapshot.error}",
                    );
                    return Center(
                      child: Text(
                        '${AppLocalizations.of(context)!.error}: ${snapshot.error}',
                      ),
                    );
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
                              try {
                                await _repo.deleteNote(n);
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
