import 'dart:convert';

class CommunityTemplateType {
  static const String taskList = 'TaskList';
  static const String flashCard = 'FlashCard';

  static String toRemote(String type) {
    if (type == flashCard) {
      return 'flashcard';
    }
    return 'tasklist';
  }

  static String fromRemote(String rawType) {
    if (rawType.toLowerCase() == 'flashcard') {
      return flashCard;
    }
    return taskList;
  }
}

class CommunityTemplate {
  final String id;
  final String type;
  final String title;
  final String authorName;
  final String description;
  final List<String> tags;
  final int downloads;
  final DateTime createdAt;
  final Map<String, dynamic> payload;

  const CommunityTemplate({
    required this.id,
    required this.type,
    required this.title,
    required this.authorName,
    required this.description,
    required this.tags,
    required this.downloads,
    required this.createdAt,
    required this.payload,
  });

  bool get isTaskList => type == CommunityTemplateType.taskList;

  bool get isFlashCard => type == CommunityTemplateType.flashCard;

  int get itemCount {
    if (isTaskList) {
      return (payload['tasks'] as List?)?.length ?? 0;
    }
    return (payload['cards'] as List?)?.length ?? 0;
  }

  String get itemCountLabel {
    if (isTaskList) {
      return '$itemCount Tasks';
    }
    return '$itemCount FlashCards';
  }

  factory CommunityTemplate.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['json_payload'] ?? {};
    Map<String, dynamic> resolvedPayload;

    if (rawPayload is String && rawPayload.isNotEmpty) {
      resolvedPayload = Map<String, dynamic>.from(jsonDecode(rawPayload));
    } else if (rawPayload is Map<String, dynamic>) {
      resolvedPayload = rawPayload;
    } else {
      resolvedPayload = {};
    }

    final rawTags = json['tags'];
    final resolvedTags = rawTags is List
        ? rawTags.map((tag) => tag.toString()).toList()
        : <String>[];

    return CommunityTemplate(
      id: (json['id'] ?? '').toString(),
      type: CommunityTemplateType.fromRemote((json['type'] ?? '').toString()),
      title: (json['title'] ?? '').toString(),
      authorName: (json['author_name'] ?? 'Anonymous').toString(),
      description: (json['description'] ?? '').toString(),
      tags: resolvedTags,
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      payload: resolvedPayload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'type': CommunityTemplateType.toRemote(type),
      'title': title,
      'author_name': authorName,
      'description': description,
      'tags': tags,
      'downloads': downloads,
      'created_at': createdAt.toIso8601String(),
      'json_payload': payload,
    };
  }

  CommunityTemplate copyWith({
    String? id,
    String? type,
    String? title,
    String? authorName,
    String? description,
    List<String>? tags,
    int? downloads,
    DateTime? createdAt,
    Map<String, dynamic>? payload,
  }) {
    return CommunityTemplate(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      downloads: downloads ?? this.downloads,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
    );
  }
}
