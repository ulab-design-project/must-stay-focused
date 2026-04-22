import 'package:flutter/material.dart';

import '../../data/models/community_template.dart';
import '../../style/buttons.dart';
import '../../style/chips.dart';
import '../../style/containers.dart';
import '../../style/theme.dart';

class TemplateCard extends StatelessWidget {
  final CommunityTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final bool isDownloading;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.onDownload,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = template.tags;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppElementSizes.spacingSm),
      child: GlassCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppElementSizes.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppElementSizes.spacingMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: AppTextSizes.title,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppElementSizes.spacingXs),
                      Text(
                        'by ${template.authorName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.85,
                          ),
                          fontSize: AppTextSizes.small,
                        ),
                      ),
                      const SizedBox(height: AppElementSizes.spacingXs),
                      Text(
                        template.itemCountLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.85,
                          ),
                          fontSize: AppTextSizes.small,
                        ),
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: AppElementSizes.spacingSm),
                        Wrap(
                          spacing: AppElementSizes.spacingXs,
                          runSpacing: AppElementSizes.spacingXs,
                          children: tags
                              .take(4)
                              .map(
                                (tag) => GlassChip(
                                  label: tag,
                                  labelStyle: TextStyle(
                                    fontSize: AppTextSizes.compact,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  selected: false,
                                  onTap: null,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppElementSizes.spacingSm),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassSquircleIconButton(
                      size: AppElementSizes.buttonSquare,
                      isPrimary: true,
                      onPressed: isDownloading ? null : onDownload,
                      icon: isDownloading
                          ? SizedBox(
                              width: AppElementSizes.icon,
                              height: AppElementSizes.icon,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onSurface,
                              ),
                            )
                          : const Icon(Icons.download_rounded),
                    ),
                    const SizedBox(height: AppElementSizes.spacingXs),
                    Text(
                      '${template.downloads}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: AppTextSizes.small,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
