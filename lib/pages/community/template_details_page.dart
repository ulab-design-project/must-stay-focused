import 'dart:convert';
import 'package:flutter/material.dart';

import '../../data/models/community_template.dart';
import '../../data/models/task.dart';
import '../../data/models/flash_card.dart';
import '../../data/repositories/community_repository.dart';
import '../../style/theme.dart';
import '../../style/cards.dart';
import '../../widgets/community/template_card.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/flashcard/flash_card.dart';
import '../../data/models/task.dart';

class TemplateDetailsPage extends StatefulWidget {
  final CommunityTemplate template;

  const TemplateDetailsPage({
    super.key,
    required this.template,
  });

  @override
  State<TemplateDetailsPage> createState() => _TemplateDetailsPageState();
}

class _TemplateDetailsPageState extends State<TemplateDetailsPage> {
  final _communityRepository = CommunityRepository();
  List<dynamic> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _parsePayload();
  }

  void _parsePayload() {
    try {
      final data = jsonDecode(widget.template.jsonPayload);
      if (widget.template.type == TemplateType.todoList) {
        _items = (data['tasks'] as List).map((e) {
          final task = Task();
          task.title = e['title'];
          task.description = e['description'];
          task.priority = TaskPriority.values.firstWhere(
            (p) => p.name == e['priority'],
            orElse: () => TaskPriority.medium,
          );
          task.isCompleted = false;
          task.creationTime = DateTime.now();
          return task;
        }).toList();
      } else {
        _items = (data['cards'] as List).map((e) {
          final card = FlashCard();
          card.front = e['frontText'];
          card.back = e['backText'];
          card.creationDate = DateTime.now();
          return card;
        }).toList();
      }
      setState(() {});
    } catch (e, stackTrace) {
      debugPrint('TemplateDetailsPage parse error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _downloadTemplate() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual download to local DB
      await _communityRepository.incrementDownloads(widget.template.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template downloaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TemplateCard(
              template: widget.template,
              onTap: () {},
              onDownload: _downloadTemplate,
            ),
            if (widget.template.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppElementSizes.spacingLg),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppElementSizes.spacingMd),
                  child: Text(widget.template.description),
                ),
              ),
            const Padding(
              padding: EdgeInsets.all(AppElementSizes.spacingLg),
              child: Text(
                'Contents',
                style: TextStyle(
                  fontSize: AppTextSizes.h3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppElementSizes.spacingLg),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                if (widget.template.type == TemplateType.todoList) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppElementSizes.spacingMd),
                    child: IgnorePointer(
                      child: TaskCard(
                        task: _items[index],
                        onEdit: () {},
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppElementSizes.spacingMd),
                    child: IgnorePointer(
                      child: FlashCardWidget(
                        card: _items[index],
                        onRated: () {},
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}