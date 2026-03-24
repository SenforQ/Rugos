import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserDanceVideo {
  const UserDanceVideo({
    required this.videoRelativePath,
    required this.title,
    required this.experience,
    required this.tags,
  });

  /// Path relative to ApplicationDocuments, e.g. `user_dance_videos/vid_123.mp4`
  final String videoRelativePath;
  final String title;
  final String experience;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'videoRelativePath': videoRelativePath,
      'title': title,
      'experience': experience,
      'tags': tags,
    };
  }

  factory UserDanceVideo.fromJson(Map<String, dynamic> json) {
    final String path =
        (json['videoRelativePath'] as String?)?.trim() ?? (json['videoPath'] as String?)?.trim() ?? '';
    return UserDanceVideo(
      videoRelativePath: path,
      title: (json['title'] as String?) ?? '',
      experience: (json['experience'] as String?) ?? '',
      tags: (json['tags'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .where((String e) => e.trim().isNotEmpty)
          .toList(),
    );
  }
}

class MyVideoStore {
  static const String _key = 'user_dance_videos';

  Future<List<UserDanceVideo>> loadAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <UserDanceVideo>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> e) => UserDanceVideo.fromJson(e))
        .toList();
  }

  Future<void> saveAll(List<UserDanceVideo> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((UserDanceVideo e) => e.toJson()).toList()),
    );
  }

  Future<void> add(UserDanceVideo item) async {
    final List<UserDanceVideo> current = await loadAll();
    await saveAll(<UserDanceVideo>[item, ...current]);
  }
}
