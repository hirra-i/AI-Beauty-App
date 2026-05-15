import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beauty_ai_app/services/post_login_router.dart';

class LoginSheet extends StatefulWidget {
  final BuildContext parentContext;

  const LoginSheet({
    super.key,
    required this.parentContext,
  });

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

//login
  Future<void> _login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = credential.user;

      //Block if not verified
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email before logging in.'),
          ),
        );

        setState(() => isLoading = false);
        return;
      }

      if (!mounted) return;

      // Close the sheet first
      Navigator.of(context).pop();

      // Navigate using parent context (NOT sheet context)
      await handlePostLogin(widget.parentContext);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
//forgot password
  Future<void> _forgotPassword() async {
    final TextEditingController resetEmailController =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Reset your password"),
        content: TextField(
          controller: resetEmailController,
          decoration: const InputDecoration(
            hintText: "Enter your email",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final enteredEmail = resetEmailController.text.trim();
              if (enteredEmail.isEmpty) return;

              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: enteredEmail);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Password reset email sent. Check your inbox.",
                    ),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(e.message ?? "Something went wrong"),
                  ),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                color: const Color(0xFFF6EFEA),
              ),
            ),
            const SizedBox(height: 24),

            _glassField(
              label: 'Email',
              controller: email,
              keyboardType: TextInputType.emailAddress,
            ),

            _glassPasswordField(),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: Text(
                  "Forgot password?",
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: isLoading ? null : _login,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color:
                        const Color(0xFFD8B6A4).withOpacity(0.6),
                    width: 1.2,
                  ),
                  backgroundColor:
                      Colors.white.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(32),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFF6EFEA),
                      )
                    : Text(
                        'Log in',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              const Color(0xFFF6EFEA),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: _glassDecoration(label),
      ),
    );
  }

  Widget _glassPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: password,
        obscureText: hidePassword,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: _glassDecoration('Password').copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              hidePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _glassDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          GoogleFonts.inter(color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}