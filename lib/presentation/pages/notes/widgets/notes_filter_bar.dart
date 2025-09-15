import 'package:flutter/material.dart';
import 'package:notehive/l10n/app_localizations.dart';

/// NotesFilterBar shows the search field and the pinned filter toggle.
/// It lifts the state up via callbacks to the parent page.
class NotesFilterBar extends StatelessWidget {
  const NotesFilterBar({
    super.key,
    required this.onQueryChanged,
    required this.showPinnedOnly,
    required this.onToggleFilter,
  });

  final ValueChanged<String> onQueryChanged;
  final bool showPinnedOnly;
  final ValueChanged<bool> onToggleFilter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceVariant.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppLocalizations.of(context)!.searchHint,
                filled: true,
                fillColor: colors.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onChanged: onQueryChanged,
            ),
          ),
          const SizedBox(width: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(AppLocalizations.of(context)!.filterAll),
                icon: const Icon(Icons.list),
              ),
              ButtonSegment(
                value: true,
                label: Text(AppLocalizations.of(context)!.filterPinned),
                icon: const Icon(Icons.push_pin),
              ),
            ],
            selected: {showPinnedOnly},
            onSelectionChanged: (set) {
              if (set.isNotEmpty) onToggleFilter(set.first);
            },
          ),
        ],
      ),
    );
  }
}
