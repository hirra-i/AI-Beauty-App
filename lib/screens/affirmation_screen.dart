import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen>
    with SingleTickerProviderStateMixin {

  final List<String> affirmations = [
    "You glow differently when you're confident.",
    "Your undertone is your superpower.",
    "Soft glam or bold glam — you own it.",
    "Beauty is energy, and yours is radiant.",
    "Your natural features deserve to shine.",
    "Confidence is your best beauty product.",
    "You are effortlessly beautiful.",
    "Today is a good day to glow.",
  ];

  late String currentAffirmation;

  late AnimationController _controller;
  late Animation<double> _fade;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    currentAffirmation = affirmations[_random.nextInt(affirmations.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  void _nextAffirmation() {
    _controller.reset();

    setState(() {
      currentAffirmation =
          affirmations[_random.nextInt(affirmations.length)];
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextAffirmation,
      child: Scaffold(
        body: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                'lib/assets/image.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.35)),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FadeTransition(
                  opacity: _fade,
                  child: Text(
                    currentAffirmation,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      color: const Color(0xFFF6EFEA),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}