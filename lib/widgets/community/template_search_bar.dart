import 'package:flutter/material.dart';

import '../../../style/theme.dart';
import '../../../style/textfield.dart';
import '../../../style/cards.dart';

class TemplateSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onSortChanged;
  final Function(List<String>) onTagsChanged;
  final List<String> availableTags;

  const TemplateSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onTagsChanged,
    required this.availableTags,
  });

  @override
  State<TemplateSearchBar> createState() => _TemplateSearchBarState();
}

class _TemplateSearchBarState extends State<TemplateSearchBar> {
  String _searchQuery = '';
  String _sortBy = 'downloads';
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppElementSizes.spacingLg),
      child: Column(
        children: [
          GlassTextField(
            hintText: 'Search templates...',
            onChanged: (value) {
              _searchQuery = value;
              widget.onSearchChanged(value);
            },
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppElementSizes.spacingMd),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      dropdownColor: theme.colorScheme.surface,
                      items: const [
                        DropdownMenuItem(value: 'downloads', child: Text('Most Downloaded')),
                        DropdownMenuItem(value: 'created_at', child: Text('Recent')),
                        DropdownMenuItem(value: 'star_rating', child: Text('Highest Rated')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                          widget.onSortChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppElementSizes.spacingMd),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppElementSizes.spacingMd),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<List<String>>(
                      isExpanded: true,
                      hint: const Text('Select Tags'),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      dropdownColor: theme.colorScheme.surface,
                      items: [
                        DropdownMenuItem(
                          value: widget.availableTags,
                          child: const Text('All Tags'),
                        ),
                        ...widget.availableTags.map((tag) => DropdownMenuItem(
                          value: [tag],
                          child: Text(tag),
                        )),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            if (value.length == widget.availableTags.length) {
                              _selectedTags.clear();
                            } else {
                              if (_selectedTags.contains(value.first)) {
                                _selectedTags.remove(value.first);
                              } else {
                                _selectedTags.add(value.first);
                              }
                            }
                          });
                          widget.onTagsChanged(_selectedTags);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}