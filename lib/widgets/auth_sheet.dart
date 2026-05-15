import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthSheet extends StatelessWidget {
  final String title;
  final String buttonText;
  final bool loading;
  final VoidCallback onSubmit;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;

  const AuthSheet({
    super.key,
    required this.title,
    required this.buttonText,
    required this.loading,
    required this.onSubmit,
    required this.children,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E6DC).withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: GoogleFonts.playfairDisplay(fontSize: 28)),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8B6A4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(buttonText,
                        style: const TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool email;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.email = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        keyboardType:
            email ? TextInputType.emailAddress : TextInputType.text,
        decoration: _decoration(label),
      ),
    );
  }
}

class AuthPasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hidden;
  final VoidCallback toggle;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.hidden,
    required this.toggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: hidden,
        validator: (v) =>
            v != null && v.length < 6 ? 'Minimum 6 characters' : null,
        decoration: _decoration(label).copyWith(
          suffixIcon: IconButton(
            icon:
                Icon(hidden ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}

InputDecoration _decoration(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
