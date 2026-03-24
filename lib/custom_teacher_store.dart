import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CustomTeacher {
  const CustomTeacher({
    required this.name,
    required this.danceType,
    required this.backgroundIntro,
    required this.avatarRelativePath,
    required this.presetQuestions,
  });

  final String name;
  final String danceType;
  final String backgroundIntro;
  /// Path relative to Documents, e.g. `custom_teacher_avatars/avatar_123.png`
  final String avatarRelativePath;
  final List<String> presetQuestions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'danceType': danceType,
      'backgroundIntro': backgroundIntro,
      'avatarRelativePath': avatarRelativePath,
      'presetQuestions': presetQuestions,
    };
  }

  factory CustomTeacher.fromJson(Map<String, dynamic> json) {
    final String avatar =
        (json['avatarRelativePath'] as String?)?.trim() ?? (json['avatarPath'] as String?)?.trim() ?? '';
    return CustomTeacher(
      name: (json['name'] as String?) ?? '',
      danceType: (json['danceType'] as String?) ?? '',
      backgroundIntro: (json['backgroundIntro'] as String?) ?? '',
      avatarRelativePath: avatar,
      presetQuestions: (json['presetQuestions'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .where((String e) => e.trim().isNotEmpty)
          .toList(),
    );
  }
}

class CustomTeacherStore {
  static const String _key = 'custom_dance_teachers';

  Future<List<CustomTeacher>> loadTeachers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <CustomTeacher>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => CustomTeacher.fromJson(item))
        .toList();
  }

  Future<void> saveTeachers(List<CustomTeacher> teachers) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      teachers.map((CustomTeacher t) => t.toJson()).toList(),
    );
    await prefs.setString(_key, encoded);
  }

  Future<void> addTeacher(CustomTeacher teacher) async {
    final List<CustomTeacher> current = await loadTeachers();
    final List<CustomTeacher> updated = <CustomTeacher>[teacher, ...current];
    await saveTeachers(updated);
  }
}
