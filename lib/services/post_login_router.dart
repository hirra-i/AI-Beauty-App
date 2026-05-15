import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/screens/introduction_screen.dart';
import '/screens/preferences_screen.dart';
import '/screens/profile_loading_screen.dart';
import '/services/local_profile_store.dart';

Future<void> handlePostLogin(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  
  final localProfile = await LocalProfileStore().load();

  if (!context.mounted) return;

  if (localProfile != null) {
    Navigator.pushReplacementNamed(context, '/homeHub');
    return;
  }


  final docRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

  late DocumentSnapshot doc;

  try {
    doc = await docRef.get();
  } catch (e) {
    debugPrint('Firestore error: $e');
    return;
  }

  if (!context.mounted) return;

  if (!doc.exists) {
    await docRef.set({
      'introCompleted': false,
      'preferences': {},
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const IntroduceYourselfScreen(),
      ),
    );
    return;
  }

  final data = doc.data() as Map<String, dynamic>;

  final bool introDone = data['introCompleted'] == true;

  final bool prefsDone =
      data['preferences'] != null &&
      data['preferences'] is Map &&
      (data['preferences'] as Map).isNotEmpty;

  final String name =
      data['intro']?['displayName']?.toString().trim().isNotEmpty == true
          ? data['intro']['displayName']
          : 'there';

  if (!context.mounted) return;

 
  if (introDone && prefsDone) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PersonalisedLoadingScreen(name: name),
      ),
    );
  } else if (introDone && !prefsDone) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PreferencesScreen(),
      ),
    );
  } else {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const IntroduceYourselfScreen(),
      ),
    );
  }
}

