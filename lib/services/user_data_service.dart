import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw StateError('No logged in user');
    return u.uid;
  }

  Future<void> setAiPermissionsPromptCompleted() async {
    await _db.collection('users').doc(_uid).set({
      'aiPermissionsPromptCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveAiProfile({
    required String undertone,
    required double confidence,
    required String quality,
    required Map<String, dynamic> debug,
  }) async {
    await _db.collection('users').doc(_uid).set({
      'aiProfile': {
        'undertone': undertone,
        'confidence': confidence,
        'quality': quality,
        'debug': debug, // you can remove this later
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}