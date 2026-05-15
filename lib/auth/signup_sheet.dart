import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpSheet extends StatefulWidget {
  const SignUpSheet({super.key});

  @override
  State<SignUpSheet> createState() => _SignUpSheetState();
}

class _SignUpSheetState extends State<SignUpSheet> {
  final _formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = credential.user;

      if (user != null) {
        await user.sendEmailVerification();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'firstName': firstName.text.trim(),
          'lastName': lastName.text.trim(),
          'email': email.text.trim(),
          'introCompleted': false,
          'preferences': {},
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Verify your email"),
            content: const Text(
              "We’ve sent a verification email.\n\nPlease verify your email before logging in.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // close bottom sheet
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create account',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  color: const Color(0xFFF6EFEA),
                ),
              ),
              const SizedBox(height: 24),

              _glassField('First name', firstName),
              _glassField('Last name', lastName),
              _glassField('Email', email, emailType: true),

              _glassPasswordField(
                label: 'Password',
                controller: password,
                hidden: hidePassword,
                toggle: () =>
                    setState(() => hidePassword = !hidePassword),
              ),

              _glassPasswordField(
                label: 'Confirm password',
                controller: confirmPassword,
                hidden: hideConfirmPassword,
                toggle: () => setState(
                    () => hideConfirmPassword = !hideConfirmPassword),
                validate: (v) =>
                    v != password.text ? 'Passwords do not match' : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _signUp,
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
                  child: isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF6EFEA),
                        )
                      : Text(
                          'Sign up',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFF6EFEA),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassField(
    String label,
    TextEditingController controller, {
    bool emailType = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (v) =>
            v == null || v.isEmpty ? 'Required' : null,
        keyboardType: emailType
            ? TextInputType.emailAddress
            : TextInputType.text,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: _glassDecoration(label),
      ),
    );
  }

  Widget _glassPasswordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback toggle,
    String? Function(String?)? validate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: hidden,
        validator: validate ??
            (v) =>
                v != null && v.length < 6
                    ? 'Min 6 chars'
                    : null,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: _glassDecoration(label).copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              hidden
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: toggle,
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

