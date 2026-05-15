import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BeautyChatScreen extends StatefulWidget {
  const BeautyChatScreen({
    super.key,
    required this.undertone,
    required this.preferences,
  });

  final String undertone;
  final Map<String, dynamic> preferences;

  @override
  State<BeautyChatScreen> createState() => _BeautyChatScreenState();
}

class _BeautyChatScreenState extends State<BeautyChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;

  final List<Map<String, String>> _messages = [
    {
      "role": "assistant",
      "content":
          "Hi lovely ✨ I’m your Beauty AI. Ask me anything about makeup, skincare, or colours that suit you."
    }
  ];

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _controller.clear();
      _loading = true;
    });

    _scrollToBottom();

    setState(() {
      _messages.add({"role": "assistant", "content": "Typing..."});
    });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('beautyChat');

      final result = await callable.call({
        "undertone": widget.undertone,
        "preferences": widget.preferences,
        "messages": _messages,
      });

      final reply = result.data["reply"]?.toString() ?? "";

      _messages.removeLast();

      setState(() {
        _messages.add({
          "role": "assistant",
          "content": reply.isEmpty ? "Try asking that another way 💛" : reply
        });
      });

      _scrollToBottom();
    } catch (e) {
      _messages.removeLast();

      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "Something went wrong. Try again ✨"
        });
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _bubble(Map<String, String> message) {
    final isUser = message["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFD8B6A4)
              : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(22),
          border: isUser
              ? null
              : Border.all(
                  color: const Color(0xFFD8B6A4).withOpacity(0.5),
                  width: 1,
                ),
        ),
        child: Text(
          message["content"] ?? "",
          style: GoogleFonts.inter(
            fontSize: 14.5,
            height: 1.6,
            color: isUser ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
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
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                "Beauty Chat",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _messages.map(_bubble).toList(),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFD8B6A4).withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          cursorColor: const Color(0xFFD8B6A4),
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: "Ask something...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: _loading ? null : _sendMessage,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward,
                                color: Colors.black,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
