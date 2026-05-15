import 'package:beauty_ai_app/screens/profile_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui'; // REQUIRED for blur


class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  final Map<String, String> answers = {};

  late AnimationController _controller;
  late Animation<double> _fade;

  final List<Map<String, dynamic>> questions = [
    {
      'key': 'makeup_style',
      'question': 'How would you describe your everyday makeup style?',
      'options': [
        'Minimal / natural',
        'Soft glam',
        'Bold / expressive',
      ],
    },
    {
      'key': 'skin_tone',
      'question': 'How would you describe your skin tone?',
      'options': [
        'Fair',
        'Light',
        'Medium',
        'Deep',
      ],
    },
    {
      'key': 'aesthetic',
      'question': 'Which aesthetic do you feel most drawn to?',
      'options': [
        'Light feminine',
        'Dark feminine',
        'Balanced',
        'Exploring',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _selectAnswer(String value) {
    setState(() {
      answers[questions[currentQuestion]['key']] = value;
      _controller.reset();

      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        _controller.forward();
      } else {
        _savePreferences();
      }
    });
  }

Future<void> _savePreferences() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(
    {
      'preferences': answers,
      'preferencesCompleted': true,
      'preferencesUpdatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );

  _goToProfileLoading();
}

void _goToProfileLoading() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final name = doc.data()?['intro']?['displayName'] ?? 'there';

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => PersonalisedLoadingScreen(name: name),
    ),
  );
}



  void _showCompleteDialog() {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFFF6EFEA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'All set ✨',
        style: GoogleFonts.playfairDisplay(fontSize: 24),
      ),
      content: Text(
        'Your preferences have been saved.\nYou can update them anytime.',
        style: GoogleFonts.inter(fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // close dialog first

            // 🔹 get user's name from Firestore
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            final name =
                doc.data()?['intro']?['displayName'] ?? 'there';

            // 🔹 navigate to personalised loading screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PersonalisedLoadingScreen(name: name),
              ),
            );
          },
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}


  Future<void> _confirmLogout() async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
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
              Navigator.of(context).popUntil((route) => route.isFirst);
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
    final question = questions[currentQuestion];

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'lib/assets/app_pic_2.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.15),
            ),
          ),

          // BLUR + SOFT OVERLAY
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),
          


          // DARK OVERLAY
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // QUESTION CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      question['question'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        height: 1.35,
                        color: const Color(0xFFF6EFEA),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 36),

                    ...question['options'].map<Widget>((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => _selectAnswer(option),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: const Color(0xFFD8B6A4).withOpacity(0.6),
                                width: 1.2,
                              ),
                              backgroundColor:
                                  Colors.white.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: Text(
                              option,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFFF6EFEA),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),

          // LOG OUT BUTTON (BOTTOM LEFT)
          Positioned(
            bottom: 24,
            left: 24,
            child: TextButton(
              onPressed: _confirmLogout,
              child: Text(
                'Log out',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.85),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



