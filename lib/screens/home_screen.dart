import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notice_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import '../widgets/category_chip.dart';
import 'notice_detail_screen.dart';
import 'create_notice_screen.dart';
import 'bookmarks_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().loadNotices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (_) {},
                ),
                ...NoticeCategory.values.map(
                  (c) => ChoiceChip(
                    label: Text('${c.icon} ${c.displayName}'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Date Range',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Time'),
                  selected: true,
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('Today'),
                  selected: false,
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('This Week'),
                  selected: false,
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('This Month'),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    final isFaculty = authProvider.isFaculty;
    final noticeProvider = context.watch<NoticeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Board'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) => noticeProvider.setSortOption(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
              const PopupMenuItem(value: 'oldest', child: Text('Oldest First')),
              const PopupMenuItem(value: 'views', child: Text('Most Viewed')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notices...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      context.read<NoticeProvider>().setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterSheet(context),
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected:
                      context.watch<NoticeProvider>().selectedCategory == null,
                  onTap: () => context.read<NoticeProvider>().setCategory(null),
                ),
                ...NoticeCategory.values.map(
                  (category) => CategoryChip(
                    label: '${category.icon} ${category.displayName}',
                    isSelected:
                        context.watch<NoticeProvider>().selectedCategory ==
                        category,
                    onTap: () =>
                        context.read<NoticeProvider>().setCategory(category),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<NoticeProvider>(
              builder: (context, noticeProvider, _) {
                if (noticeProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notices = noticeProvider.notices;

                if (notices.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notices found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => noticeProvider.loadNotices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      final notice = notices[index];
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
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (isAdmin || isFaculty)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateNoticeScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Post Notice'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
