import 'package:flutter/material.dart';

import '../../../data/models/community_template.dart';
import 'template_card.dart';

class TemplateListView extends StatelessWidget {
  final List<CommunityTemplate> templates;
  final Function(CommunityTemplate) onTemplateTap;
  final Function(CommunityTemplate) onDownload;

  const TemplateListView({
    super.key,
    required this.templates,
    required this.onTemplateTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return TemplateCard(
          template: template,
          onTap: () => onTemplateTap(template),
          onDownload: () => onDownload(template),
        );
      },
    );
  }
}