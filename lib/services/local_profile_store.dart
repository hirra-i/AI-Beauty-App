import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileStore {
  static const _key = "user_profile";

  Future<void> saveProfile({
    required String undertone,
    required Map<String, dynamic> preferences,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      "undertone": undertone,
      "preferences": preferences,
    };

    await prefs.setString(_key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return null;

    return jsonDecode(raw);
  }
}