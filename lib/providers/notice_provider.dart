import 'package:flutter/foundation.dart';
import '../models/notice_model.dart';
import '../services/notice_service.dart';

class NoticeProvider extends ChangeNotifier {
  final NoticeService _noticeService = NoticeService();
  List<Notice> _notices = [];
  List<Notice> _filteredNotices = [];
  NoticeCategory? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _sortOption = 'newest';

  List<Notice> get notices {
    List<Notice> result =
        _filteredNotices.isEmpty &&
            _searchQuery.isEmpty &&
            _selectedCategory == null
        ? List.from(_notices)
        : List.from(_filteredNotices);

    switch (_sortOption) {
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'views':
        result.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      default:
        result.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
    }

    return result;
  }

  List<Notice> get allNotices => _notices;
  NoticeCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;

  List<Notice> get pinnedNotices => _notices.where((n) => n.isPinned).toList();
  List<Notice> get activeNotices =>
      _notices.where((n) => !n.isExpired).toList();

  Future<void> loadNotices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _noticeService.getAllNotices().listen((notices) {
        _notices = notices;
        _applyFilters();
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(NoticeCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredNotices = _notices.where((notice) {
      final matchesCategory =
          _selectedCategory == null || notice.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          notice.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          notice.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch && !notice.isExpired;
    }).toList();
  }

  Future<void> createNotice({
    required String title,
    required String content,
    required NoticeCategory category,
    required String authorId,
    required String authorName,
    DateTime? expiryDate,
    List<String> attachmentUrls = const [],
    bool isPinned = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _noticeService.createNotice(
        title: title,
        content: content,
        category: category,
        authorId: authorId,
        authorName: authorName,
        expiryDate: expiryDate,
        attachmentUrls: attachmentUrls,
        isPinned: isPinned,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteNotice(String noticeId) async {
    try {
      await _noticeService.deleteNotice(noticeId);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> togglePin(String noticeId) async {
    final notice = _notices.firstWhere((n) => n.id == noticeId);
    try {
      await _noticeService.togglePin(noticeId, !notice.isPinned);
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> incrementViewCount(String noticeId) async {
    await _noticeService.incrementViewCount(noticeId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
