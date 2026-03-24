import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MagicGenerationRecord {
  const MagicGenerationRecord({
    required this.id,
    required this.mediaKind,
    required this.status,
    required this.taskId,
    required this.prompt,
    required this.createdAtMs,
    required this.aspectInfo,
    required this.mediaRelativePaths,
    this.lastPollState,
    this.failMessage,
  });

  static const String statusProcessing = 'processing';
  static const String statusSuccess = 'success';
  static const String statusFailed = 'failed';
  static const String statusNoResult = 'no_result';

  final String id;
  final String mediaKind;
  final String status;
  final String taskId;
  final String prompt;
  final int createdAtMs;
  final String aspectInfo;
  final List<String> mediaRelativePaths;
  final String? lastPollState;
  final String? failMessage;

  bool get isVideo => mediaKind == 'video';
  bool get isProcessing => status == statusProcessing;
  bool get isSuccess => status == statusSuccess;
  bool get isFailed => status == statusFailed;
  bool get isNoResult => status == statusNoResult;

  String get primaryLocalPath => mediaRelativePaths.isNotEmpty ? mediaRelativePaths.first : '';

  MagicGenerationRecord copyWith({
    String? id,
    String? mediaKind,
    String? status,
    String? taskId,
    String? prompt,
    int? createdAtMs,
    String? aspectInfo,
    List<String>? mediaRelativePaths,
    String? lastPollState,
    bool clearLastPollState = false,
    String? failMessage,
    bool clearFailMessage = false,
  }) {
    return MagicGenerationRecord(
      id: id ?? this.id,
      mediaKind: mediaKind ?? this.mediaKind,
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
      prompt: prompt ?? this.prompt,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      aspectInfo: aspectInfo ?? this.aspectInfo,
      mediaRelativePaths: mediaRelativePaths ?? this.mediaRelativePaths,
      lastPollState: clearLastPollState ? null : (lastPollState ?? this.lastPollState),
      failMessage: clearFailMessage ? null : (failMessage ?? this.failMessage),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'mediaKind': mediaKind,
      'status': status,
      'taskId': taskId,
      'prompt': prompt,
      'createdAtMs': createdAtMs,
      'aspectInfo': aspectInfo,
      'mediaRelativePaths': mediaRelativePaths,
      'lastPollState': lastPollState,
      'failMessage': failMessage,
    };
  }

  factory MagicGenerationRecord.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawPaths = json['mediaRelativePaths'] as List<dynamic>?;
    List<String> paths = rawPaths == null
        ? <String>[]
        : rawPaths.map((dynamic e) => e.toString()).where((String e) => e.trim().isNotEmpty).toList();
    final String? legacy = (json['mediaRelativePath'] as String?)?.trim();
    if (paths.isEmpty && legacy != null && legacy.isNotEmpty) {
      paths = <String>[legacy];
    }
    String status = (json['status'] as String?)?.trim() ?? '';
    if (status.isEmpty) {
      status = paths.isNotEmpty ? statusSuccess : statusFailed;
    }
    return MagicGenerationRecord(
      id: (json['id'] as String?) ?? '',
      mediaKind: (json['mediaKind'] as String?) ?? 'image',
      status: status,
      taskId: (json['taskId'] as String?) ?? '',
      prompt: (json['prompt'] as String?) ?? '',
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      aspectInfo: (json['aspectInfo'] as String?) ?? '',
      mediaRelativePaths: paths,
      lastPollState: json['lastPollState'] as String?,
      failMessage: json['failMessage'] as String?,
    );
  }
}

class MagicGenerationStore {
  static const String _key = 'magic_generation_records_v1';

  Future<List<MagicGenerationRecord>> loadAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <MagicGenerationRecord>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> e) => MagicGenerationRecord.fromJson(e))
        .toList();
  }

  Future<void> saveAll(List<MagicGenerationRecord> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((MagicGenerationRecord e) => e.toJson()).toList()),
    );
  }

  Future<void> upsertRecord(MagicGenerationRecord item) async {
    final List<MagicGenerationRecord> current = await loadAll();
    final int idx = current.indexWhere((MagicGenerationRecord e) => e.id == item.id);
    if (idx >= 0) {
      current[idx] = item;
    } else {
      current.insert(0, item);
    }
    await saveAll(current);
  }

  Future<void> add(MagicGenerationRecord item) async {
    final List<MagicGenerationRecord> current = await loadAll();
    await saveAll(<MagicGenerationRecord>[item, ...current]);
  }

  Future<void> addAll(List<MagicGenerationRecord> items) async {
    if (items.isEmpty) {
      return;
    }
    final List<MagicGenerationRecord> current = await loadAll();
    await saveAll(<MagicGenerationRecord>[...items, ...current]);
  }
}
