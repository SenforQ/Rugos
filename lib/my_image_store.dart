import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserDanceImage {
  const UserDanceImage({
    required this.imageRelativePath,
    required this.title,
    required this.experience,
    required this.tags,
  });

  /// Path relative to [getApplicationDocumentsDirectory], e.g. `user_dance_images/img_123.jpg`
  final String imageRelativePath;
  final String title;
  final String experience;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'imageRelativePath': imageRelativePath,
      'title': title,
      'experience': experience,
      'tags': tags,
    };
  }

  factory UserDanceImage.fromJson(Map<String, dynamic> json) {
    final String path =
        (json['imageRelativePath'] as String?)?.trim() ?? (json['imagePath'] as String?)?.trim() ?? '';
    return UserDanceImage(
      imageRelativePath: path,
      title: (json['title'] as String?) ?? '',
      experience: (json['experience'] as String?) ?? '',
      tags: (json['tags'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .where((String e) => e.trim().isNotEmpty)
          .toList(),
    );
  }
}

class MyImageStore {
  static const String _key = 'user_dance_images';

  Future<List<UserDanceImage>> loadAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <UserDanceImage>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> e) => UserDanceImage.fromJson(e))
        .toList();
  }

  Future<void> saveAll(List<UserDanceImage> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((UserDanceImage e) => e.toJson()).toList()),
    );
  }

  Future<void> add(UserDanceImage item) async {
    final List<UserDanceImage> current = await loadAll();
    await saveAll(<UserDanceImage>[item, ...current]);
  }
}
