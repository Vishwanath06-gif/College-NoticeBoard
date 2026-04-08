import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/notice_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';

class NoticeDetailScreen extends StatefulWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().incrementViewCount(widget.notice.id);
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareNotice() {
    final text =
        '''
📢 ${widget.notice.title}

${widget.notice.category.icon} ${widget.notice.category.displayName}

${widget.notice.content}

Posted by: ${widget.notice.authorName}
Date: ${DateFormat('MMM d, y').format(widget.notice.createdAt)}

Shared from College Notice Board
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notice copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isBookmarked =
        authProvider.user?.bookmarks.contains(widget.notice.id) ?? false;
    final isAdmin = authProvider.isAdmin;
    final isAuthor = authProvider.user?.uid == widget.notice.authorId;
    final noticeProvider = context.read<NoticeProvider>();
    final isLiked =
        authProvider.user != null &&
        widget.notice.likedBy.contains(authProvider.user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Details'),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: isBookmarked ? Colors.amber : null,
            ),
            tooltip: 'Bookmark',
            onPressed: () => authProvider.toggleBookmark(widget.notice.id),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _shareNotice,
          ),
          if (isAdmin || isAuthor)
            PopupMenuButton(
              itemBuilder: (context) => [
                if (isAdmin) ...[
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        widget.notice.isPinned
                            ? Icons.push_pin_outlined
                            : Icons.push_pin,
                      ),
                      title: Text(widget.notice.isPinned ? 'Unpin' : 'Pin'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => noticeProvider.togglePin(widget.notice.id),
                  ),
                ],
                PopupMenuItem(
                  child: const ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Notice'),
                        content: const Text(
                          'Are you sure you want to delete this notice?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              noticeProvider.deleteNotice(widget.notice.id);
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: widget.notice.category.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.notice.category.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.notice.category.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.notice.category.displayName,
                        style: TextStyle(
                          color: widget.notice.category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (widget.notice.isPinned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pinned',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.notice.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    widget.notice.authorName.isNotEmpty
                        ? widget.notice.authorName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.notice.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        DateFormat(
                          'MMMM d, y • h:mm a',
                        ).format(widget.notice.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.notice.targetAudience != TargetAudience.all) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      widget.notice.targetAudience ==
                              TargetAudience.specificDepartment
                          ? widget.notice.targetDepartment ??
                                'Specific Department'
                          : widget.notice.targetYear != null
                          ? '${widget.notice.targetYear} Students'
                          : 'Specific Audience',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 32),
            Text(
              widget.notice.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            if (widget.notice.expiryDate != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_busy, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Expires: ${DateFormat('MMMM d, y').format(widget.notice.expiryDate!)}',
                    ),
                  ],
                ),
              ),
            ],
            if (widget.notice.attachments.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Attachments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.notice.attachments.map(
                (url) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getFileIcon(url),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      url.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(url),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.visibility, color: Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.notice.viewCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Views',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => noticeProvider.toggleLike(
                        widget.notice.id,
                        authProvider.user!.uid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Icon(
                              isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.notice.likeCount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Likes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: isBookmarked ? Colors.amber : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${authProvider.user?.bookmarks.length ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Saved',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String url) {
    final ext = url.split('.').last.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return Icons.image;
    if (['doc', 'docx'].contains(ext)) return Icons.description;
    return Icons.attach_file;
  }
}
