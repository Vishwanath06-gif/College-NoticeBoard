import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import 'notice_detail_screen.dart';

class MyNoticesScreen extends StatelessWidget {
  const MyNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final noticeProvider = context.watch<NoticeProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myNotices = noticeProvider.allNotices
        .where((n) => n.authorId == user.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Posted Notices')),
      body: myNotices.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notices posted yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Go to Home and tap "Post Notice"\nto create your first notice',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myNotices.length,
              itemBuilder: (context, index) {
                final notice = myNotices[index];
                return Dismissible(
                  key: Key(notice.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Notice'),
                        content: const Text(
                          'Are you sure you want to delete this notice?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    context.read<NoticeProvider>().deleteNotice(notice.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notice deleted')),
                    );
                  },
                  child: NoticeCard(
                    notice: notice,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoticeDetailScreen(notice: notice),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
