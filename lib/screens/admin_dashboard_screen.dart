import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notice_model.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import 'notice_detail_screen.dart';
import 'my_notices_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noticeProvider = context.watch<NoticeProvider>();
    final allNotices = noticeProvider.allNotices;
    final publishedNotices = allNotices.where((n) => n.isPublished).length;
    final pinnedNotices = allNotices.where((n) => n.isPinned).length;
    final totalViews = allNotices.fold(0, (sum, n) => sum + n.viewCount);
    final totalLikes = allNotices.fold(0, (sum, n) => sum + n.likeCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context,
                  'Total Notices',
                  allNotices.length.toString(),
                  Icons.article,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Published',
                  publishedNotices.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Pinned',
                  pinnedNotices.toString(),
                  Icons.push_pin,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Total Views',
                  totalViews.toString(),
                  Icons.visibility,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              //Done with it
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context,
                  'Total Likes',
                  totalLikes.toString(),
                  Icons.thumb_up,
                  Colors.pink,
                ),
                _buildStatCard(
                  context,
                  'Categories',
                  NoticeCategory.values.length.toString(),
                  Icons.category,
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('My Posted Notices'),
                    subtitle: Text('${allNotices.length} notices'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyNoticesScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('Notice Analytics'),
                    subtitle: const Text('View detailed statistics'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAnalyticsDialog(context, allNotices),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Notices by Category',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...NoticeCategory.values.map((category) {
              final count = allNotices
                  .where((n) => n.category == category)
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: category.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  title: Text(category.displayName),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Recent Notices',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...allNotices
                .take(5)
                .map(
                  (notice) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notice.category.color.withAlpha(25),
                        child: Text(notice.category.icon),
                      ),
                      title: Text(
                        notice.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${notice.viewCount} views • ${notice.likeCount} likes',
                      ),
                      trailing: notice.isPinned
                          ? Icon(
                              Icons.push_pin,
                              color: Colors.orange.shade700,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoticeDetailScreen(notice: notice),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context, List<Notice> notices) {
    final topViewed = [...notices]
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    final topLiked = [...notices]
      ..sort((a, b) => b.likeCount.compareTo(a.likeCount));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notice Analytics'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Top 5 Most Viewed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...topViewed
                    .take(5)
                    .map(
                      (n) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.visibility),
                        title: Text(
                          n.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text('${n.viewCount}'),
                      ),
                    ),
                const Divider(),
                const Text(
                  'Top 5 Most Liked',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...topLiked
                    .take(5)
                    .map(
                      (n) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.thumb_up),
                        title: Text(
                          n.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text('${n.likeCount}'),
                      ),
                    ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
