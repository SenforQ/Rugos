import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TeacherChatSession {
  const TeacherChatSession({
    required this.teacherName,
    required this.danceType,
    required this.backgroundIntro,
    required this.imageRef,
    required this.imageIsAsset,
    required this.presetQuestions,
    required this.lastSnippet,
    required this.updatedAtMs,
  });

  final String teacherName;
  final String danceType;
  final String backgroundIntro;
  final String imageRef;
  final bool imageIsAsset;
  final List<String> presetQuestions;
  final String lastSnippet;
  final int updatedAtMs;

  String get sessionKey => '${teacherName.trim()}\u0001${danceType.trim()}';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'teacherName': teacherName,
      'danceType': danceType,
      'backgroundIntro': backgroundIntro,
      'imageRef': imageRef,
      'imageIsAsset': imageIsAsset,
      'presetQuestions': presetQuestions,
      'lastSnippet': lastSnippet,
      'updatedAtMs': updatedAtMs,
    };
  }

  factory TeacherChatSession.fromJson(Map<String, dynamic> json) {
    return TeacherChatSession(
      teacherName: (json['teacherName'] as String?) ?? '',
      danceType: (json['danceType'] as String?) ?? '',
      backgroundIntro: (json['backgroundIntro'] as String?) ?? '',
      imageRef: (json['imageRef'] as String?) ?? '',
      imageIsAsset: json['imageIsAsset'] as bool? ?? true,
      presetQuestions: (json['presetQuestions'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(),
      lastSnippet: (json['lastSnippet'] as String?) ?? '',
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}

class TeacherChatSessionStore {
  static const String _key = 'teacher_chat_sessions_v1';

  Future<Map<String, TeacherChatSession>> _loadMap() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <String, TeacherChatSession>{};
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, TeacherChatSession> out = <String, TeacherChatSession>{};
      for (final MapEntry<String, dynamic> e in decoded.entries) {
        if (e.value is Map<String, dynamic>) {
          final TeacherChatSession s = TeacherChatSession.fromJson(e.value as Map<String, dynamic>);
          if (s.teacherName.isNotEmpty) {
            out[s.sessionKey] = s;
          }
        }
      }
      return out;
    } catch (_) {
      return <String, TeacherChatSession>{};
    }
  }

  Future<void> _saveMap(Map<String, TeacherChatSession> map) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = <String, dynamic>{
      for (final MapEntry<String, TeacherChatSession> e in map.entries) e.key: e.value.toJson(),
    };
    await prefs.setString(_key, jsonEncode(encoded));
  }

  Future<List<TeacherChatSession>> loadSessionsSorted() async {
    final Map<String, TeacherChatSession> map = await _loadMap();
    final List<TeacherChatSession> list = map.values.toList();
    list.sort((TeacherChatSession a, TeacherChatSession b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return list;
  }

  Future<void> upsertSession(TeacherChatSession session) async {
    final Map<String, TeacherChatSession> map = await _loadMap();
    map[session.sessionKey] = session;
    await _saveMap(map);
  }
}
