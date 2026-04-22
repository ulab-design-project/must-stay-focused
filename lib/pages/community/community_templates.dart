import 'package:flutter/material.dart';

import '../../data/models/community_template.dart';
import '../../data/repositories/community_repository.dart';
import '../../style/background.dart';
import '../../style/tabs.dart';
import '../../style/theme.dart';
import '../../widgets/community/template_list_view.dart';
import '../../widgets/community/template_search_bar.dart';
import '../../widgets/community/template_upload.dart';
import 'template_details_page.dart';

class CommunityTemplatesPage extends StatefulWidget {
  const CommunityTemplatesPage({super.key});

  @override
  State<CommunityTemplatesPage> createState() => _CommunityTemplatesPageState();
}

class _CommunityTemplatesPageState extends State<CommunityTemplatesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  int _loadRequestId = 0;

  List<CommunityTemplate> _templates = <CommunityTemplate>[];
  List<CommunityTemplate> _visibleTemplates = <CommunityTemplate>[];
  String? _downloadingTemplateId;

  String get _activeType {
    if (_tabController.index == 1) {
      return CommunityTemplateType.flashCard;
    }
    return CommunityTemplateType.taskList;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadTemplates();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
      if (_tabController.index != 2) {
        _loadTemplates();
      }
    }
  }

  Future<void> _loadTemplates({String? forcedType}) async {
    final requestId = ++_loadRequestId;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final type = forcedType ?? _activeType;
      final loaded = await communityRepo.fetchTemplates(type: type);

      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _templates = loaded;
        _visibleTemplates = List<CommunityTemplate>.from(loaded);
      });
    } catch (e, stackTrace) {
      debugPrint('CommunityTemplatesPage _loadTemplates error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted && requestId == _loadRequestId) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted && requestId == _loadRequestId) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDownload(CommunityTemplate template) async {
    try {
      setState(() => _downloadingTemplateId = template.id);
      await communityRepo.downloadTemplate(template);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${template.title} downloaded to local database.'),
        ),
      );
      await _loadTemplates();
    } catch (e, stackTrace) {
      debugPrint('CommunityTemplatesPage _handleDownload error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingTemplateId = null);
      }
    }
  }

  Future<void> _openDetails(CommunityTemplate template) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TemplateDetailsPage(
            templateId: template.id,
            templateType: template.type,
            initialTemplate: template,
          ),
        ),
      );
      await _loadTemplates();
    } catch (e, stackTrace) {
      debugPrint('CommunityTemplatesPage _openDetails error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Widget _buildListContent() {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingMd),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingMd),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
      );
    }

    return Column(
      children: [
        TemplateSearchBar(
          key: ValueKey(_activeType),
          sourceTemplates: _templates,
          onFiltered: (result) {
            if (!mounted) {
              return;
            }
            setState(() => _visibleTemplates = result);
          },
        ),
        const SizedBox(height: AppElementSizes.spacingMd),
        Expanded(
          child: TemplateListView(
            templates: _visibleTemplates,
            onOpenDetails: _openDetails,
            onDownload: _handleDownload,
            downloadingTemplateId: _downloadingTemplateId,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _tabController.index == 2
        ? TemplateUpload(onUploaded: () {})
        : _buildListContent();

    final theme = Theme.of(context);
    return BackgroundDrop(
      scaffold: Scaffold(
        appBar: AppBar(
          title: const Text('Community Templates'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingMd),
          child: body,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppElementSizes.spacingMd,
              0,
              AppElementSizes.spacingMd,
              AppElementSizes.spacingMd,
            ),
            child: GlassTabBar(
              height: 56,
              controller: _tabController,
              indicatorColor: theme.colorScheme.secondary.withValues(
                alpha: 0.5,
              ),
              selectedIconColor: theme.colorScheme.onSurface,
              unselectedIconColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.75,
              ),
              selectedLabelStyle: TextStyle(color: theme.colorScheme.onSurface),
              unselectedLabelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
              tabs: const [
                Tab(icon: Icon(Icons.checklist_rtl), child: Text('TaskList')),
                Tab(icon: Icon(Icons.style), child: Text('FlashCards')),
                Tab(icon: Icon(Icons.upload_rounded), child: Text('Upload')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
