import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/notice_model.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Stream<List<Notice>> getAllNotices() {
    return _firestore
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Notice.fromFirestore(doc.id, doc.data()!))
              .toList(),
        );
  }

  Stream<List<Notice>> getNoticesByCategory(NoticeCategory category) {
    return _firestore
        .collection('notices')
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Notice.fromFirestore(doc.id, doc.data()!))
              .toList(),
        );
  }

  Future<Notice> createNotice({
    required String title,
    required String content,
    required NoticeCategory category,
    NoticePriority priority = NoticePriority.medium,
    required String authorId,
    required String authorName,
    DateTime? expiryDate,
    List<String> attachmentUrls = const [],
    bool isPinned = false,
    TargetAudience targetAudience = TargetAudience.all,
    String? targetDepartment,
    String? targetYear,
    NoticeStatus status = NoticeStatus.published,
  }) async {
    final notice = Notice(
      id: _uuid.v4(),
      title: title,
      content: content,
      category: category,
      priority: priority,
      authorId: authorId,
      authorName: authorName,
      expiryDate: expiryDate,
      attachments: attachmentUrls,
      isPinned: isPinned,
      targetAudience: targetAudience,
      targetDepartment: targetDepartment,
      targetYear: targetYear,
      status: status,
    );

    await _firestore
        .collection('notices')
        .doc(notice.id)
        .set(notice.toFirestore());
    return notice;
  }

  Future<void> updateNotice(
    String noticeId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('notices').doc(noticeId).update(updates);
  }

  Future<void> deleteNotice(String noticeId) async {
    await _firestore.collection('notices').doc(noticeId).delete();
  }

  Future<void> incrementViewCount(String noticeId) async {
    await _firestore.collection('notices').doc(noticeId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Future<void> togglePin(String noticeId, bool isPinned) async {
    await _firestore.collection('notices').doc(noticeId).update({
      'isPinned': isPinned,
    });
  }

  Future<void> toggleLike(String noticeId, String userId) async {
    final doc = await _firestore.collection('notices').doc(noticeId).get();
    if (!doc.exists) return;

    final likedBy = List<String>.from(doc.data()!['likedBy'] ?? []);

    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }

    await _firestore.collection('notices').doc(noticeId).update({
      'likedBy': likedBy,
      'likeCount': likedBy.length,
    });
  }

  Future<String> uploadAttachment(File file, String fileName) async {
    final ref = _storage
        .ref()
        .child('attachments')
        .child('${_uuid.v4()}_$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Stream<List<Notice>> searchNotices(String query) {
    return _firestore
        .collection('notices')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Notice.fromFirestore(doc.id, doc.data()!))
              .toList(),
        );
  }

  Future<List<Notice>> getNoticesForUser(List<String> noticeIds) async {
    final notices = <Notice>[];
    for (final id in noticeIds) {
      final doc = await _firestore.collection('notices').doc(id).get();
      if (doc.exists) {
        notices.add(Notice.fromFirestore(doc.id, doc.data()!));
      }
    }
    return notices;
  }
}
