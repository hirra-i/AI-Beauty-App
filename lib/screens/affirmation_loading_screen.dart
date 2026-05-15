import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'preferences_screen.dart'; // 👈 adjust path if needed

class AffirmationLoadingScreen extends StatefulWidget {
  const AffirmationLoadingScreen({super.key});

  @override
  State<AffirmationLoadingScreen> createState() =>
      _AffirmationLoadingScreenState();
}

class _AffirmationLoadingScreenState extends State<AffirmationLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  int affirmationIndex = 0;

  final List<String> affirmations = [
    'You are enough.',
    'Your beauty is not a standard to meet.',
    'You don’t need to change to belong.',
    'Embrace your uniqueness.',
    'This experience is made for you.',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), //total duration
    );

    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    //CHANGE AFFIRMATIONS OVER TIME
    _controller.addListener(() {
      final newIndex =
          (_controller.value * affirmations.length).floor().clamp(
                0,
                affirmations.length - 1,
              );

      if (newIndex != affirmationIndex) {
        setState(() {
          affirmationIndex = newIndex;
        });
      }
    });

    // NAVIGATE WHEN FINISHED
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PreferencesScreen(),
          ),
        );
      }
    });
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
          // BACKGROUND IMAGE (same as intro)
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_pic_6.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.15),
            ),
          ),

          // BLUR + OVERLAY
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    affirmations[affirmationIndex],
                    key: ValueKey(affirmationIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFF6EFEA),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

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
                          Color(0xFFD8B6A4), // 👈 pinky beige
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
