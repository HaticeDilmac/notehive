import 'package:flutter/material.dart';
import 'package:notehive/core/note_model.dart';
import 'package:notehive/l10n/app_localizations.dart';

/// NoteCard renders a single note with a themed gradient background.
/// It exposes simple callbacks for edit, pin/unpin and delete actions.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.colorIndex,
  });

  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradients = [
      [
        colorScheme.primaryContainer.withOpacity(0.85),
        colorScheme.secondaryContainer.withOpacity(0.65),
      ],
      [
        colorScheme.tertiaryContainer.withOpacity(0.85),
        colorScheme.primaryContainer.withOpacity(0.65),
      ],
      [
        colorScheme.secondaryContainer.withOpacity(0.85),
        colorScheme.tertiaryContainer.withOpacity(0.65),
      ],
      [
        colorScheme.surfaceVariant.withOpacity(0.8),
        colorScheme.primaryContainer.withOpacity(0.55),
      ],
    ];
    final selectedColors = gradients[colorIndex % gradients.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selectedColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty
                          ? AppLocalizations.of(context)!.untitled
                          : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (note.pinned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.pinnedLabel,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                maxLines: 5, // Shorter content preview per request
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(note.updatedAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: AppLocalizations.of(context)!.editAction,
                    onPressed: onTap,
                  ),
                  IconButton(
                    icon: const Icon(Icons.push_pin_outlined),
                    tooltip:
                        note.pinned
                            ? AppLocalizations.of(context)!.unpinAction
                            : AppLocalizations.of(context)!.pinAction,
                    onPressed: onTogglePin,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.error,
                    onPressed: onDelete,
                    tooltip: AppLocalizations.of(context)!.delete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
