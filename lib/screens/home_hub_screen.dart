import 'package:beauty_ai_app/screens/affirmation_screen.dart';
import 'package:beauty_ai_app/screens/lib/screens/beauty_chat_screen.dart';
import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../services/local_profile_store.dart';

class HomeHubScreen extends StatefulWidget {
  const HomeHubScreen({super.key});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends State<HomeHubScreen> {
  int _index = 0;
  String undertone = "unknown";
  Map<String, dynamic> preferences = {};
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await LocalProfileStore().load();
      if (profile != null) {
        undertone = profile["undertone"] ?? "unknown";
        preferences = Map<String, dynamic>.from(profile["preferences"] ?? {});
      }
    } catch (e) {
      debugPrint("Profile load error: $e");
    }

    if (mounted) {
      setState(() {
        _loadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pages = [
      BeautyChatScreen(
        undertone: undertone,
        preferences: preferences,
      ),
      const AffirmationsScreen(),
      const BeautyProfileSummaryScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: const Color(0xFFD8B6A4),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "Affirm",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
