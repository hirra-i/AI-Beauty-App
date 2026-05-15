import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/signup_sheet.dart';
import '../auth/login_sheet.dart';

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

class OnboardingSlideTwo extends StatelessWidget {
  const OnboardingSlideTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        blurredBackground('lib/assets/app_pic.jpg'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let’s begin.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFF6EFEA),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Create an account to personalise your experience and receive thoughtful recommendations.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),

              const SizedBox(height: 32),

              // 🌸 GET STARTED (MATCHES OTHER SCREENS)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const SignUpSheet(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFFD8B6A4).withOpacity(0.6),
                      width: 1.2,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF6EFEA),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🌸 LOGIN LINK
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => LoginSheet(parentContext: context),
                  );
                },
                child: Text(
                  'Already have an account? Log in',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}
