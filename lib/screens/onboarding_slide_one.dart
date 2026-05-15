import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget blurredBackground(String imagePath) {
  return Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.1),
        ),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.black.withOpacity(0.25),
          ),
        ),
      ),
    ],
  );
}

class OnboardingSlideOne extends StatelessWidget {
  const OnboardingSlideOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        blurredBackground('lib/assets/favour_pic.jpg'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beauty, designed\nfor you.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 44,
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFF6EFEA),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Personalised beauty guidance that adapts to who you are — not the other way around.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
