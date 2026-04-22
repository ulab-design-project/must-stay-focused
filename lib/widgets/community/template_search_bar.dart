import 'package:flutter/material.dart';

import '../../data/models/community_template.dart';
import '../../style/containers.dart';
import '../../style/dialogs.dart';
import '../../style/forms.dart';
import '../../style/list_tile.dart';
import '../../style/picker.dart';
import '../../style/theme.dart';

class TemplateSearchBar extends StatefulWidget {
  final List<CommunityTemplate> sourceTemplates;
  final ValueChanged<List<CommunityTemplate>> onFiltered;

  const TemplateSearchBar({
    super.key,
    required this.sourceTemplates,
    required this.onFiltered,
  });

  @override
  State<TemplateSearchBar> createState() => _TemplateSearchBarState();
}

class _TemplateSearchBarState extends State<TemplateSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTags = <String>{};
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilters());
  }

  @override
  void didUpdateWidget(covariant TemplateSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceTemplates != widget.sourceTemplates) {
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _allAvailableTags {
    final tags = <String>{};
    for (final template in widget.sourceTemplates) {
      tags.addAll(template.tags);
    }
    final sortedTags = tags.toList()..sort();
    return sortedTags;
  }

  void _applyFilters() {
    try {
      final query = _searchController.text.trim().toLowerCase();

      List<CommunityTemplate> filtered = widget.sourceTemplates.where((
        template,
      ) {
        final matchesQuery =
            query.isEmpty ||
            template.title.toLowerCase().contains(query) ||
            template.authorName.toLowerCase().contains(query) ||
            template.description.toLowerCase().contains(query);

        final matchesTags =
            _selectedTags.isEmpty ||
            _selectedTags.every(template.tags.contains);

        return matchesQuery && matchesTags;
      }).toList();

      if (_sortBy == 'downloads') {
        filtered.sort((a, b) => b.downloads.compareTo(a.downloads));
      } else {
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      widget.onFiltered(filtered);
    } catch (e, stackTrace) {
      debugPrint('TemplateSearchBar _applyFilters error: $e');
      debugPrintStack(stackTrace: stackTrace);
      widget.onFiltered(List<CommunityTemplate>.from(widget.sourceTemplates));
    }
  }

  Future<void> _openSortPicker() async {
    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(AppElementSizes.spacingLg),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassListTile(
                    title: Text(
                      'Recent',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: _sortBy == 'recent'
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, 'recent'),
                  ),
                  GlassListTile(
                    title: Text(
                      'Downloads',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: _sortBy == 'downloads'
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, 'downloads'),
                    isLast: true,
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (result == null || !mounted) {
        return;
      }

      setState(() => _sortBy = result);
      _applyFilters();
    } catch (e, stackTrace) {
      debugPrint('TemplateSearchBar _openSortPicker error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _openTagMultiSelect() async {
    try {
      final allTags = _allAvailableTags;
      final pickedTags = Set<String>.from(_selectedTags);

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return GlassDialog(
                title: 'Select Tags',
                maxWidth: 360,
                content: allTags.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(
                          AppElementSizes.spacingSm,
                        ),
                        child: Text(
                          'No tags available.',
                          style: TextStyle(
                            color: Theme.of(
                              dialogContext,
                            ).colorScheme.onSurface,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 260,
                        child: ListView.builder(
                          itemCount: allTags.length,
                          itemBuilder: (context, index) {
                            final tag = allTags[index];
                            final selected = pickedTags.contains(tag);
                            return GlassListTile(
                              title: Text(
                                tag,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              trailing: selected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : Icon(
                                      Icons.circle_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              onTap: () {
                                setDialogState(() {
                                  if (selected) {
                                    pickedTags.remove(tag);
                                  } else {
                                    pickedTags.add(tag);
                                  }
                                });
                              },
                              isLast: index == allTags.length - 1,
                            );
                          },
                        ),
                      ),
                actions: [
                  GlassDialogAction(
                    label: 'Clear',
                    onPressed: () {
                      pickedTags.clear();
                      Navigator.pop(dialogContext);
                    },
                  ),
                  GlassDialogAction(
                    label: 'Apply',
                    isPrimary: true,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedTags
          ..clear()
          ..addAll(pickedTags);
      });
      _applyFilters();
    } catch (e, stackTrace) {
      debugPrint('TemplateSearchBar _openTagMultiSelect error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GlassTextField(
          controller: _searchController,
          placeholder: 'Search templates',
          textStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          placeholderStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: AppTextSizes.body,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          onChanged: (_) => _applyFilters(),
        ),
        const SizedBox(height: AppElementSizes.spacingSm),
        Row(
          children: [
            Expanded(
              child: GlassPicker(
                height: AppElementSizes.buttonHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                value: _selectedTags.isEmpty
                    ? 'Tags'
                    : 'Tags (${_selectedTags.length})',
                placeholder: 'Tags',
                textStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: AppTextSizes.small,
                ),
                placeholderStyle: TextStyle(
                  fontSize: AppTextSizes.small,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                icon: Icon(
                  Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                onTap: _openTagMultiSelect,
              ),
            ),
            const SizedBox(width: AppElementSizes.spacingSm),
            Expanded(
              child: GlassPicker(
                height: AppElementSizes.buttonHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                value: _sortBy == 'downloads' ? 'Downloads' : 'Recent',
                placeholder: 'Sort by',
                textStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: AppTextSizes.small,
                ),
                placeholderStyle: TextStyle(
                  fontSize: AppTextSizes.small,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                icon: Icon(
                  Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                onTap: _openSortPicker,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
