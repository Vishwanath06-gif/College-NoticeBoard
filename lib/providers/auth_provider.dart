import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get isFaculty =>
      _user?.role == UserRole.faculty || _user?.role == UserRole.admin;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email: email, password: password);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> toggleBookmark(String noticeId) async {
    if (_user == null) return;

    final bookmarks = List<String>.from(_user!.bookmarks);
    if (bookmarks.contains(noticeId)) {
      bookmarks.remove(noticeId);
    } else {
      bookmarks.add(noticeId);
    }

    await _authService.updateBookmarks(_user!.uid, bookmarks);
    _user = _user!.copyWith(bookmarks: bookmarks);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
