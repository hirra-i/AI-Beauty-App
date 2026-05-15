import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );

    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _routeNext();
      }
    });
  }

  Future<void> _routeNext() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/splash');
      return;
    }

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && !refreshedUser.emailVerified) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/splash');
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    final introCompleted = data['introCompleted'] == true;
    final prefs = data['preferences'];
    final hasPreferences =
        prefs != null && prefs is Map && prefs.isNotEmpty;
    final permissionsPromptCompleted =
        data['aiPermissionsPromptCompleted'] == true;

    if (!mounted) return;

    if (!introCompleted) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    if (!hasPreferences) {
      Navigator.pushReplacementNamed(context, '/preferences');
      return;
    }

    if (!permissionsPromptCompleted) {
      Navigator.pushReplacementNamed(context, '/permissions');
      return;
    }

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_pic.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(-0.15, 0),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Preparing your experience',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFF6EFEA),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.4),
                        valueColor: const AlwaysStoppedAnimation(
                          Color.fromARGB(255, 211, 179, 161),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


