import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:beauty_ai_app/ui/app_background.dart';

class RecommendationsScreen extends StatelessWidget {
  final Map<String, dynamic> advice;

  const RecommendationsScreen({
    super.key,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    final undertone = advice["undertone"] ?? "unknown";
    final confidence = advice["confidence"] ?? 0;
    final lipstick = List<String>.from(advice["lipstick"] ?? []);
    final blush = List<String>.from(advice["blush"] ?? []);
    final jewellery = List<String>.from(advice["jewellery"] ?? []);
    final hair = List<String>.from(advice["hairColours"] ?? []);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            // Blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // TITLE
                    Text(
                      "Your Personalised Guide ✨",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        color: const Color(0xFFF6EFEA),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // ADVICE BOX
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD8B6A4).withOpacity(0.6),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Undertone: $undertone",
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFF6EFEA),
                                ),
                              ),
                              Text(
                                "Confidence: $confidence%",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text("Lipstick",
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              ...lipstick.map((e) => Text(
                                    "• $e",
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  )),
                              const SizedBox(height: 16),
                              Text("Blush",
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              ...blush.map((e) => Text(
                                    "• $e",
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  )),
                              const SizedBox(height: 16),
                              Text("Jewellery",
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              ...jewellery.map((e) => Text(
                                    "• $e",
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  )),
                              const SizedBox(height: 16),
                              Text("Hair Colours",
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              ...hair.map((e) => Text(
                                    "• $e",
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CONTINUE TO CHAT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/homeHub');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD8B6A4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Text(
                          "Continue to Beauty Chat",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BACK BUTTON
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
