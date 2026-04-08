import 'package:flutter/material.dart';

enum NoticeCategory {
  academic,
  exams,
  results,
  events,
  placements,
  holidays,
  sports,
  general,
  urgent,
}

extension NoticeCategoryExtension on NoticeCategory {
  String get displayName {
    switch (this) {
      case NoticeCategory.academic:
        return 'Academic';
      case NoticeCategory.exams:
        return 'Examinations';
      case NoticeCategory.results:
        return 'Results';
      case NoticeCategory.events:
        return 'Events';
      case NoticeCategory.placements:
        return 'Placements';
      case NoticeCategory.holidays:
        return 'Holidays';
      case NoticeCategory.sports:
        return 'Sports';
      case NoticeCategory.general:
        return 'General';
      case NoticeCategory.urgent:
        return 'Urgent';
    }
  }

  String get icon {
    switch (this) {
      case NoticeCategory.academic:
        return '📚';
      case NoticeCategory.exams:
        return '📝';
      case NoticeCategory.results:
        return '📊';
      case NoticeCategory.events:
        return '🎉';
      case NoticeCategory.placements:
        return '💼';
      case NoticeCategory.holidays:
        return '🏖️';
      case NoticeCategory.sports:
        return '⚽';
      case NoticeCategory.general:
        return '📌';
      case NoticeCategory.urgent:
        return '🚨';
    }
  }

  Color get color {
    switch (this) {
      case NoticeCategory.academic:
        return Colors.blue;
      case NoticeCategory.exams:
        return Colors.orange;
      case NoticeCategory.results:
        return Colors.purple;
      case NoticeCategory.events:
        return Colors.pink;
      case NoticeCategory.placements:
        return Colors.green;
      case NoticeCategory.holidays:
        return Colors.teal;
      case NoticeCategory.sports:
        return Colors.red;
      case NoticeCategory.general:
        return Colors.grey;
      case NoticeCategory.urgent:
        return Colors.red.shade900;
    }
  }
}

enum NoticePriority { low, medium, high }

extension NoticePriorityExtension on NoticePriority {
  String get displayName {
    switch (this) {
      case NoticePriority.low:
        return 'Low';
      case NoticePriority.medium:
        return 'Medium';
      case NoticePriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case NoticePriority.low:
        return Colors.green;
      case NoticePriority.medium:
        return Colors.orange;
      case NoticePriority.high:
        return Colors.red;
    }
  }
}

enum NoticeStatus { draft, published, archived }

enum TargetAudience { all, specificDepartment, specificYear }

class Notice {
  final String id;
  final String title;
  final String content;
  final NoticeCategory category;
  final NoticePriority priority;
  final NoticeStatus status;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? expiryDate;
  final List<String> attachments;
  final bool isPinned;
  final int viewCount;
  final int likeCount;
  final TargetAudience targetAudience;
  final String? targetDepartment;
  final String? targetYear;
  final List<String> likedBy;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.priority = NoticePriority.medium,
    this.status = NoticeStatus.published,
    required this.authorId,
    required this.authorName,
    DateTime? createdAt,
    this.publishedAt,
    this.expiryDate,
    this.attachments = const [],
    this.isPinned = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.targetAudience = TargetAudience.all,
    this.targetDepartment,
    this.targetYear,
    this.likedBy = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory Notice.fromFirestore(String id, Map<String, dynamic> data) {
    return Notice(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: NoticeCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => NoticeCategory.general,
      ),
      priority: NoticePriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => NoticePriority.medium,
      ),
      status: NoticeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => NoticeStatus.published,
      ),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      publishedAt: data['publishedAt']?.toDate(),
      expiryDate: data['expiryDate']?.toDate(),
      attachments: List<String>.from(data['attachments'] ?? []),
      isPinned: data['isPinned'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      targetAudience: TargetAudience.values.firstWhere(
        (e) => e.name == data['targetAudience'],
        orElse: () => TargetAudience.all,
      ),
      targetDepartment: data['targetDepartment'],
      targetYear: data['targetYear'],
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'publishedAt': publishedAt ?? DateTime.now(),
      'expiryDate': expiryDate,
      'attachments': attachments,
      'isPinned': isPinned,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'targetAudience': targetAudience.name,
      'targetDepartment': targetDepartment,
      'targetYear': targetYear,
      'likedBy': likedBy,
    };
  }

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isPublished => status == NoticeStatus.published;
  bool get isDraft => status == NoticeStatus.draft;
}
