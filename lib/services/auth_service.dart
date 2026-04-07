import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(user.uid, doc.data()!);
    });
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(user.uid, doc.data()!);
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = AppUser(
      uid: credential.user!.uid,
      email: email,
      name: name,
      role: role,
    );

    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    return user;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();
    if (!doc.exists) throw Exception('User data not found');
    return AppUser.fromFirestore(credential.user!.uid, doc.data()!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateBookmarks(String userId, List<String> bookmarks) async {
    await _firestore.collection('users').doc(userId).update({
      'bookmarks': bookmarks,
    });
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': newRole.name,
    });
  }
}
