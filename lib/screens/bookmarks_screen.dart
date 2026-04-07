import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import 'notice_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final noticeProvider = context.watch<NoticeProvider>();
    final bookmarkedIds = authProvider.user?.bookmarks ?? [];

    final bookmarkedNotices = noticeProvider.allNotices
        .where((notice) => bookmarkedIds.contains(notice.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarkedNotices.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on any notice\nto save it here',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedNotices.length,
              itemBuilder: (context, index) {
                final notice = bookmarkedNotices[index];
                return NoticeCard(
                  notice: notice,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoticeDetailScreen(notice: notice),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
