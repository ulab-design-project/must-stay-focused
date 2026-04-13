import 'package:flutter/material.dart';

import '../../data/models/community_template.dart';
import '../../data/repositories/community_repository.dart';
import '../../style/theme.dart';
import '../../style/cards.dart';
import '../../widgets/community/template_list_view.dart';
import '../../widgets/community/template_search_bar.dart';
import '../../widgets/community/template_upload.dart';
import 'template_details_page.dart';

class CommunityTemplates extends StatefulWidget {
  const CommunityTemplates({super.key});

  @override
  State<CommunityTemplates> createState() => _CommunityTemplatesState();
}

class _CommunityTemplatesState extends State<CommunityTemplates>
    with SingleTickerProviderStateMixin {
  final _communityRepository = CommunityRepository();
  late TabController _tabController;

  List<CommunityTemplate> _templates = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'downloads';
  List<String> _selectedTags = [];
  final List<String> _availableTags = ['Productivity', 'Study', 'Workout', 'Mindfulness', 'Habit'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTemplates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TemplateType get _currentType {
    switch (_tabController.index) {
      case 0:
        return TemplateType.todoList;
      case 1:
        return TemplateType.flashcardDeck;
      default:
        return TemplateType.todoList;
    }
  }

  Future<void> _loadTemplates() async {
    if (_tabController.index == 2) return;

    setState(() => _isLoading = true);

    try {
      _templates = await _communityRepository.fetchTemplates(
        _currentType,
        searchQuery: _searchQuery,
        tags: _selectedTags,
        sortBy: _sortBy,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load templates: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTemplateTap(CommunityTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateDetailsPage(template: template),
      ),
    );
  }

  void _onDownload(CommunityTemplate template) async {
    // TODO: Implement actual download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${template.title}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplateList(),
                _buildTemplateList(),
                TemplateUpload(onUploadComplete: () {
                  _tabController.animateTo(0);
                  _loadTemplates();
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassCard(
        padding: EdgeInsets.zero,
        child: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Tasks'),
            Tab(icon: Icon(Icons.style), text: 'Flashcards'),
            Tab(icon: Icon(Icons.upload), text: 'Upload'),
          ],
          onTap: (index) {
            setState(() {});
            if (index != 2) _loadTemplates();
          },
        ),
      ),
    );
  }

  Widget _buildTemplateList() {
    return Column(
      children: [
        TemplateSearchBar(
          onSearchChanged: (value) {
            _searchQuery = value;
            _loadTemplates();
          },
          onSortChanged: (value) {
            _sortBy = value;
            _loadTemplates();
          },
          onTagsChanged: (tags) {
            _selectedTags = tags;
            _loadTemplates();
          },
          availableTags: _availableTags,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TemplateListView(
                  templates: _templates,
                  onTemplateTap: _onTemplateTap,
                  onDownload: _onDownload,
                ),
        ),
      ],
    );
  }
}