import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';

class PersonalisedLoadingScreen extends StatefulWidget {
  final String name;

  const PersonalisedLoadingScreen({
    super.key,
    required this.name,
  });

  @override
  State<PersonalisedLoadingScreen> createState() =>
      _PersonalisedLoadingScreenState();
}

class _PersonalisedLoadingScreenState
    extends State<PersonalisedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 👈 5 seconds
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BeautyProfileSummaryScreen(),
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
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'lib/assets/smiling_pic_duo.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.15),
            ),
          ),

          // BLUR + OVERLAY
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hi ${widget.name},',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFF6EFEA),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We’re setting up your experience.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),

                const SizedBox(height: 36),

                AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.35),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFD8B6A4),
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
