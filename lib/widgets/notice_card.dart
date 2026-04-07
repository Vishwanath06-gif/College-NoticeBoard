import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notice_model.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onTap;

  const NoticeCard({super.key, required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        notice.category,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${notice.category.icon} ${notice.category.displayName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(notice.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (notice.isPinned)
                    const Icon(Icons.push_pin, size: 18, color: Colors.orange),
                  Text(
                    DateFormat('MMM d, y').format(notice.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                notice.content,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    notice.authorName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${notice.viewCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (notice.attachments.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${notice.attachments.length}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(NoticeCategory category) {
    switch (category) {
      case NoticeCategory.academic:
        return Colors.blue;
      case NoticeCategory.events:
        return Colors.purple;
      case NoticeCategory.placements:
        return Colors.green;
      case NoticeCategory.general:
        return Colors.grey;
      case NoticeCategory.urgent:
        return Colors.red;
    }
  }
}
