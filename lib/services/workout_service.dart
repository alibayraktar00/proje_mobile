import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_log_model.dart';

class WorkoutService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static Future<void> addLog(WorkoutLogModel log) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('workout_logs')
        .doc(log.id)
        .set(log.toMap());
  }

  static Future<List<WorkoutLogModel>> getLogsForDate(DateTime date) async {
    if (_uid == null) return [];

    // Create start and end of day dates
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('workout_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WorkoutLogModel.fromMap(doc.data()))
        .toList();
  }

  static Future<void> toggleStatus(String id, bool currentStatus) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('workout_logs')
        .doc(id)
        .update({'isCompleted': !currentStatus});
  }

  static Future<void> deleteLog(String id) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('workout_logs')
        .doc(id)
        .delete();
  }
}
