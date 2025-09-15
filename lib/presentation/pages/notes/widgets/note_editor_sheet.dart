import 'package:flutter/material.dart';
import 'package:notehive/core/note_model.dart';
import 'package:notehive/core/ai_summarizer.dart';
import 'package:notehive/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

/// NoteEditorSheet is a reusable bottom sheet for creating/updating notes.
/// It returns when the user saves or closes. Consumers handle persistence.
class NoteEditorSheet extends StatefulWidget {
  const NoteEditorSheet({super.key, this.note, required this.onSubmit});

  final NoteModel? note;
  final Future<void> Function(String title, String content) onSubmit;

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final AISummarizer _summarizer = AISummarizer();
  bool _isSummarizing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.note == null ? loc.newNote : loc.editNote,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: loc.titleHint,
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: loc.contentHint,
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 48, 12),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap:
                        _isSummarizing
                            ? null
                            : () async {
                              final text = _contentController.text.trim();
                              if (text.isEmpty) return;
                              setState(() => _isSummarizing = true);
                              try {
                                final summary = await _summarizer.summarize(
                                  text,
                                );
                                if (!mounted) return;
                                _contentController.text = summary;
                                _contentController
                                    .selection = TextSelection.collapsed(
                                  offset: _contentController.text.length,
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${AppLocalizations.of(context)!.operationFailed}: $e',
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted)
                                  setState(() => _isSummarizing = false);
                              }
                            },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child:
                          _isSummarizing
                              ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                              : Icon(
                                Icons.auto_awesome,
                                size: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton.icon(
              // Button color customized as requested
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.check),
              label: Text(widget.note == null ? loc.save : loc.update),
              onPressed: () async {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();
                if (title.isEmpty && content.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.enterTitleOrContent)),
                    );
                  }
                  return;
                }
                await widget.onSubmit(title, content);
              },
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}
