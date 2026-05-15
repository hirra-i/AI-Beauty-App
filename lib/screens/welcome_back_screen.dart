import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _startLoading();
  }

  void _startLoading() async {
    const total = 15000;
    const step = 100;

    int elapsed = 0;

    while (elapsed < total) {
      await Future.delayed(const Duration(milliseconds: step));

      elapsed += step;

      if (!mounted) return;

      setState(() {
        progress = elapsed / total;
      });
    }

    Navigator.pushReplacementNamed(context, "/homeHub");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _particles() {
    final random = Random();
    return List.generate(18, (index) {
      return Positioned(
        left: random.nextDouble() * 400,
        top: random.nextDouble() * 800,
        child: Opacity(
          opacity: 0.15,
          child: Container(
            width: random.nextDouble() * 6 + 2,
            height: random.nextDouble() * 6 + 2,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// Background Image
          Positioned.fill(
            child: Image.asset(
              "lib/assets/smiling_pic_duo.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),

          /// Floating particles
          ..._particles(),

          /// Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      "Welcome back ✨",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        color: const Color(0xFFF6EFEA),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Preparing your personalised beauty space",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),

                    const SizedBox(height: 45),

                    /// Progress bar container
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [

                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFFD8B6A4),
                              ),
                            ),

                            /// shimmer glow
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment(
                                    progress * 2 - 1, 0),
                                child: Container(
                                  width: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.4),
                                        Colors.transparent
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${(progress * 100).toInt()}%",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}