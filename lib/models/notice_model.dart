enum NoticeCategory { academic, events, placements, general, urgent }

extension NoticeCategoryExtension on NoticeCategory {
  String get displayName {
    switch (this) {
      case NoticeCategory.academic:
        return 'Academic';
      case NoticeCategory.events:
        return 'Events';
      case NoticeCategory.placements:
        return 'Placements';
      case NoticeCategory.general:
        return 'General';
      case NoticeCategory.urgent:
        return 'Urgent';
    }
  }

  String get icon {
    switch (this) {
      case NoticeCategory.academic:
        return '🎓';
      case NoticeCategory.events:
        return '📅';
      case NoticeCategory.placements:
        return '💼';
      case NoticeCategory.general:
        return '📌';
      case NoticeCategory.urgent:
        return '🚨';
    }
  }
}

class Notice {
  final String id;
  final String title;
  final String content;
  final NoticeCategory category;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final List<String> attachments;
  final bool isPinned;
  final int viewCount;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    required this.authorName,
    DateTime? createdAt,
    this.expiryDate,
    this.attachments = const [],
    this.isPinned = false,
    this.viewCount = 0,
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
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      expiryDate: data['expiryDate']?.toDate(),
      attachments: List<String>.from(data['attachments'] ?? []),
      isPinned: data['isPinned'] ?? false,
      viewCount: data['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category.name,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'expiryDate': expiryDate,
      'attachments': attachments,
      'isPinned': isPinned,
      'viewCount': viewCount,
    };
  }

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
}
