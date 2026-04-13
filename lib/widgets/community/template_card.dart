import 'package:flutter/material.dart';

import '../../../data/models/community_template.dart';
import '../../../style/theme.dart';
import '../../../style/cards.dart';

class TemplateCard extends StatelessWidget {
  final CommunityTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppElementSizes.spacingLg,
        vertical: AppElementSizes.spacingSm,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(AppElementSizes.spacingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: TextStyle(
                      fontSize: AppTextSizes.title,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppElementSizes.spacingXs),
                  Text(
                    'by ${template.authorName}',
                    style: TextStyle(
                      fontSize: AppTextSizes.small,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppElementSizes.spacingXs),
                  Text(
                    template.type == TemplateType.todoList
                        ? '${_getItemCount()} Tasks'
                        : '${_getItemCount()} Flashcards',
                    style: TextStyle(
                      fontSize: AppTextSizes.small,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  if (template.tags.isNotEmpty) ...[
                    const SizedBox(height: AppElementSizes.spacingSm),
                    Wrap(
                      spacing: AppElementSizes.spacingSm,
                      runSpacing: AppElementSizes.spacingXs,
                      children: template.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppElementSizes.spacingSm,
                                  vertical: AppElementSizes.spacingXs,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: AppTextSizes.compact,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            InkWell(
              onTap: onDownload,
              borderRadius: BorderRadius.circular(AppElementSizes.cardRadius),
              child: Padding(
                padding: const EdgeInsets.all(AppElementSizes.spacingSm),
                child: Column(
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: AppElementSizes.icon,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppElementSizes.spacingXs),
                    Text(
                      '${template.downloads}',
                      style: TextStyle(
                        fontSize: AppTextSizes.small,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  int _getItemCount() {
    try {
      return template.jsonPayload.split('},{').length;
    } catch (e) {
      return 0;
    }
  }
}