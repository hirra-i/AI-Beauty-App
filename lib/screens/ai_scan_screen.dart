import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AiScanScreen extends StatefulWidget {
  const AiScanScreen({super.key});

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen> {
  File? _image;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  // Pick image
  Future<void> _pickImage(ImageSource source) async {
    if (_loading) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _image = File(picked.path);
        });
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  // Run AI analysis
  Future<void> _runAIAnalysis(String category) async {
    if (_image == null) return;

    setState(() => _loading = true);

    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        _image!.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 70,
      );

      final base64Image = base64Encode(compressed!);
      final callable =
          FirebaseFunctions.instance.httpsCallable('getBeautyAdvice');

      final result = await callable.call({
        "image": base64Image,
        "category": category,
      });

      final advice = Map<String, dynamic>.from(result.data["advice"]);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "aiProfile": advice,
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/recommendations',
        arguments: advice,
      );
    } catch (e) {
      print("AI scan error: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'AI undertone scan',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Face the camera in natural light for the most accurate analysis.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    if (_image != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _image!,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: _glassButton(
                            text: "Take photo",
                            onTap: _loading
                                ? null
                                : () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _glassButton(
                            text: "Choose photo",
                            onTap: _loading
                                ? null
                                : () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _image == null || _loading
                            ? null
                            : () => _runAIAnalysis("makeup"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              )
                            : Text(
                                'View recommendations',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required String text,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFD8B6A4),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}