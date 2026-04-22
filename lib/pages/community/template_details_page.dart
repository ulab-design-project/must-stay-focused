import 'package:flutter/material.dart';

import '../../data/models/community_template.dart';
import '../../data/repositories/community_repository.dart';
import '../../style/background.dart';
import '../../style/containers.dart';
import '../../style/theme.dart';
import '../../widgets/community/template_card.dart';

class TemplateDetailsPage extends StatefulWidget {
  final String templateId;
  final String templateType;
  final CommunityTemplate? initialTemplate;

  const TemplateDetailsPage({
    super.key,
    required this.templateId,
    required this.templateType,
    this.initialTemplate,
  });

  @override
  State<TemplateDetailsPage> createState() => _TemplateDetailsPageState();
}

class _TemplateDetailsPageState extends State<TemplateDetailsPage> {
  CommunityTemplate? _template;
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _template = widget.initialTemplate;
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final resolved = await communityRepo.fetchTemplateById(
        type: widget.templateType,
        id: widget.templateId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _template = resolved ?? _template;
      });
    } catch (e, stackTrace) {
      debugPrint('TemplateDetailsPage _loadTemplate error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _download() async {
    final template = _template;
    if (template == null || _isDownloading) {
      return;
    }

    try {
      setState(() => _isDownloading = true);
      await communityRepo.downloadTemplate(template);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template downloaded successfully.')),
      );
      await _loadTemplate();
    } catch (e, stackTrace) {
      debugPrint('TemplateDetailsPage _download error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  List<Map<String, dynamic>> _payloadListFor(CommunityTemplate template) {
    if (template.isTaskList) {
      final raw = (template.payload['tasks'] as List?) ?? <dynamic>[];
      return raw
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList();
    }

    final raw = (template.payload['cards'] as List?) ?? <dynamic>[];
    return raw.map((entry) => Map<String, dynamic>.from(entry as Map)).toList();
  }

  Widget _buildPayloadCard(
    CommunityTemplate template,
    Map<String, dynamic> item,
  ) {
    final theme = Theme.of(context);

    if (template.isTaskList) {
      final title = (item['title'] ?? '').toString();
      final description = (item['description'] ?? '').toString();
      final priority = (item['priority'] ?? 'medium').toString();

      return Padding(
        padding: const EdgeInsets.only(bottom: AppElementSizes.spacingSm),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppElementSizes.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: AppTextSizes.body,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: AppElementSizes.spacingXs),
                        Text(
                          description,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppElementSizes.spacingSm),
                Text(
                  priority,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTextSizes.small,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final front = (item['front'] ?? '').toString();
    final back = (item['back'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppElementSizes.spacingSm),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                front,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: AppTextSizes.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppElementSizes.spacingXs),
              Text(
                back,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  fontSize: AppTextSizes.small,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final template = _template;

    return BackgroundDrop(
      scaffold: Scaffold(
        appBar: AppBar(
          title: const Text('Template Details'),
          actions: [
            IconButton(
              onPressed: _isDownloading ? null : _download,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingMd),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              : template == null
              ? Center(
                  child: Text(
                    'Template not found.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              : Column(
                  children: [
                    TemplateCard(
                      template: template,
                      onDownload: _download,
                      isDownloading: _isDownloading,
                    ),
                    const SizedBox(height: AppElementSizes.spacingSm),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _payloadListFor(template).length,
                        itemBuilder: (context, index) {
                          final item = _payloadListFor(template)[index];
                          return _buildPayloadCard(template, item);
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
