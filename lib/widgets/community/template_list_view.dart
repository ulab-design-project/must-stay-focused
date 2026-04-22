import 'package:flutter/material.dart';

import '../../data/models/community_template.dart';
import '../../style/containers.dart';
import '../../style/theme.dart';
import 'template_card.dart';

class TemplateListView extends StatelessWidget {
  final List<CommunityTemplate> templates;
  final ValueChanged<CommunityTemplate> onOpenDetails;
  final ValueChanged<CommunityTemplate> onDownload;
  final String? downloadingTemplateId;

  const TemplateListView({
    super.key,
    required this.templates,
    required this.onOpenDetails,
    required this.onDownload,
    this.downloadingTemplateId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppElementSizes.spacingMd),
        child: templates.isEmpty
            ? Center(
                child: Text(
                  'No templates available yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTextSizes.body,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];

                  return TemplateCard(
                    template: template,
                    onTap: () => onOpenDetails(template),
                    onDownload: () => onDownload(template),
                    isDownloading: downloadingTemplateId == template.id,
                  );
                },
              ),
      ),
    );
  }
}
