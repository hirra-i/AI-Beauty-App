import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRedirectScreen extends StatefulWidget {
  const ProfileRedirectScreen({super.key});

  @override
  State<ProfileRedirectScreen> createState() => _ProfileRedirectScreenState();
}

class _ProfileRedirectScreenState extends State<ProfileRedirectScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserProfile();
    });
  }

  Future<void> _checkUserProfile() async {

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    Navigator.pushReplacementNamed(context, "/onboarding");
    return;
  }

  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .get();

  if (!doc.exists) {
    Navigator.pushReplacementNamed(context, "/aiScan");
    return;
  }

  final data = doc.data();

  if (data != null && data.containsKey("aiProfile")) {
    Navigator.pushReplacementNamed(context, "/welcomeBack");
  } else {
    Navigator.pushReplacementNamed(context, "/aiScan");
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}