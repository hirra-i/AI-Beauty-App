import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'onboarding_pager.dart';

class BeautyProfileSummaryScreen extends StatelessWidget {
  const BeautyProfileSummaryScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Log out?',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w400),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const OnboardingPager(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tags = [
      'Soft glam',
      'Warm undertone',
      'Balanced aesthetic',
      'Natural makeup',
      'Personalised picks',
      'Everyday beauty',
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6EFEA),
              Color(0xFFE7D3C6),
              Color(0xFFD8B6A4),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your beauty profile',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Based on what you’ve shared, here’s how we’ll personalise your experience.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: tags.map(_profileTag).toList(),
                    ),

                    const SizedBox(height: 28),

                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>? ?? {};
                        final aiProfile = data['aiProfile'];

                        return Column(
                          children: [
                            if (aiProfile != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFD8B6A4)
                                        .withOpacity(0.6),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'AI Undertone Analysis',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      aiProfile['undertone']
                                          .toString()
                                          .toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFD8B6A4),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Confidence: ${((aiProfile['confidence'] ?? 0) * 100).round()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.black87.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/aiScan');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  aiProfile == null
                                      ? 'Run AI Analysis'
                                      : 'Update AI Analysis',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),
                          ],
                        );
                      },
                    ),

                    Text(
                      'These insights are generated without storing identifiable data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black87.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 24,
              left: 24,
              child: TextButton(
                onPressed: () => _confirmLogout(context),
                child: Text(
                  'Log out',
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD8B6A4).withOpacity(0.6),
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}