import 'package:beauty_ai_app/screens/onboarding_pager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'affirmation_loading_screen.dart';

class IntroduceYourselfScreen extends StatefulWidget {
  const IntroduceYourselfScreen({super.key});

  @override
  State<IntroduceYourselfScreen> createState() =>
      _IntroduceYourselfScreenState();
}

class _IntroduceYourselfScreenState extends State<IntroduceYourselfScreen>
    with SingleTickerProviderStateMixin {
  // -----------------------
  // STATE
  // -----------------------
  int step = 0;
  final int totalSteps = 4;

  final TextEditingController nameController = TextEditingController();
  String? pronouns;
  String? ageRange;

  late AnimationController _controller;
  late Animation<double> _fade;

  // -----------------------
  // INIT
  // -----------------------
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  // -----------------------
  // FIRESTORE SAVE
  // -----------------------
  Future<void> _saveIntroductionData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'intro': {
          'displayName': nameController.text.trim(),
          'pronouns': pronouns,
          'ageRange': ageRange,
        },
        'introCompleted': true,
        'introCompletedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // -----------------------
  // STEP HANDLER
  // -----------------------
  Future<void> _nextStep() async {
    _controller.reset();

    if (step < totalSteps - 1) {
      setState(() => step++);
      _controller.forward();
    } else {
      await _saveIntroductionData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AffirmationLoadingScreen(),
        ),
      );
    }
  }

  // -----------------------
  // DISPOSE
  // -----------------------
  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    super.dispose();
  }

  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/smiling_pic_duo.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.15),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: _buildStep(),
              ),
            ),
          ),
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

  // -----------------------
  // STEP SWITCH
  // -----------------------
  Widget _buildStep() {
    switch (step) {
      case 0:
        return _intro();
      case 1:
        return _name();
      case 2:
        return _choiceStep(
          'What are your pronouns?\n(optional)',
          ['She / Her', 'He / Him', 'They / Them', 'Prefer not to say'],
          (value) => pronouns = value,
        );
      case 3:
        return _choiceStep(
          'Which age range fits you best?',
          ['Under 18', '18–24', '25–34', '35–44', '45+'],
          (value) => ageRange = value,
        );
      default:
        return const SizedBox();
    }
  }

  // -----------------------
  // STEPS
  // -----------------------
  Widget _intro() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _title("Now that that's done,\nlet’s get to know you."),
        const SizedBox(height: 36),
        _softButton('Continue', _nextStep),
      ],
    );
  }

  Widget _name() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('What would you like us\nto call you?'),
        const SizedBox(height: 32),
        _textField(),
        const SizedBox(height: 36),
        _softButton('Next', _nextStep),
      ],
    );
  }

  Widget _choiceStep(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _title(title),
        const SizedBox(height: 32),
        ...options.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _softButton(o, () {
              onSelect(o);
              _nextStep();
            }),
          ),
        ),
      ],
    );
  }

  // -----------------------
  // UI HELPERS
  // -----------------------
  Widget _title(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.playfairDisplay(
        fontSize: 32,
        height: 1.35,
        color: const Color(0xFFF6EFEA),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _textField() {
    return TextField(
      controller: nameController,
      style: GoogleFonts.inter(fontSize: 18),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.95),
        hintText: 'Your name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _softButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
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
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFFF6EFEA),
          ),
        ),
      ),
    );
  }

  // -----------------------
  // LOGOUT
  // -----------------------
  Future<void> _confirmLogout() async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => AlertDialog(
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
                (_) => false,
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
}
