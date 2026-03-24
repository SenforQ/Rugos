import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GenerateMediaApiException implements Exception {
  GenerateMediaApiException(this.message, {this.httpStatus, this.apiCode});

  final String message;
  final int? httpStatus;
  final int? apiCode;

  @override
  String toString() => 'GenerateMediaApiException: $message';
}

class GenerateMediaTaskDetail {
  GenerateMediaTaskDetail({
    required this.taskId,
    required this.state,
    this.model,
    this.resultJson,
    this.failMsg,
    this.failCode,
  });

  final String taskId;
  final String state;
  final String? model;
  final String? resultJson;
  final String? failMsg;
  final String? failCode;

  bool get isSuccess => state.toLowerCase() == 'success';

  bool get isFailed {
    final String s = state.toLowerCase();
    return s.contains('fail') || s == 'error' || s == 'cancelled' || s == 'canceled';
  }

  List<String> parseResultUrls() {
    final String? raw = resultJson?.trim();
    if (raw == null || raw.isEmpty) {
      return <String>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final Object? urls = decoded['resultUrls'] ?? decoded['result_urls'];
        if (urls is List) {
          return urls.map((Object? e) => e.toString()).where((String e) => e.isNotEmpty).toList();
        }
      }
    } catch (_) {}
    return <String>[];
  }
}

class GenerateMediaApiClient {
  GenerateMediaApiClient({required this.apiKey});

  final String apiKey;

  static const String host = 'api.kie.ai';
  static const String createTaskPath = '/api/v1/jobs/createTask';
  static const String recordInfoPath = '/api/v1/jobs/recordInfo';

  Map<String, String> get _headers => <String, String>{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final int? code = json['code'] as int?;
    if (code != 200) {
      final String msg = (json['msg'] as String?) ?? 'Request failed';
      throw GenerateMediaApiException(msg, apiCode: code);
    }
    final Object? data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw GenerateMediaApiException('Invalid response: missing data');
  }

  Future<String> createNanoBananaProTask({
    required String prompt,
    List<String> imageInput = const <String>[],
    String aspectRatio = '1:1',
    String resolution = '1K',
    String outputFormat = 'png',
    String? callBackUrl,
  }) async {
    final Uri uri = Uri.https(host, createTaskPath);
    final Map<String, dynamic> body = <String, dynamic>{
      'model': 'nano-banana-pro',
      'input': <String, dynamic>{
        'prompt': prompt,
        'image_input': imageInput,
        'aspect_ratio': aspectRatio,
        'resolution': resolution,
        'output_format': outputFormat,
      },
    };
    if (callBackUrl != null && callBackUrl.isNotEmpty) {
      body['callBackUrl'] = callBackUrl;
    }
    final http.Response res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw GenerateMediaApiException('HTTP ${res.statusCode}', httpStatus: res.statusCode);
    }
    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    final Map<String, dynamic> data = _unwrap(json);
    final String? taskId = data['taskId'] as String?;
    if (taskId == null || taskId.isEmpty) {
      throw GenerateMediaApiException('Missing taskId');
    }
    return taskId;
  }

  Future<String> createSoraImageToVideoTask({
    required String prompt,
    required List<String> imageUrls,
    String aspectRatio = 'landscape',
    String nFrames = '10',
    bool removeWatermark = true,
    String uploadMethod = 's3',
    List<String> characterIdList = const <String>[],
    String? callBackUrl,
    String? progressCallBackUrl,
  }) async {
    final Uri uri = Uri.https(host, createTaskPath);
    final Map<String, dynamic> input = <String, dynamic>{
      'prompt': prompt,
      'image_urls': imageUrls,
      'aspect_ratio': aspectRatio,
      'n_frames': nFrames,
      'remove_watermark': removeWatermark,
      'upload_method': uploadMethod,
    };
    if (characterIdList.isNotEmpty) {
      input['character_id_list'] = characterIdList;
    }
    final Map<String, dynamic> body = <String, dynamic>{
      'model': 'sora-2-image-to-video',
      'input': input,
    };
    if (callBackUrl != null && callBackUrl.isNotEmpty) {
      body['callBackUrl'] = callBackUrl;
    }
    if (progressCallBackUrl != null && progressCallBackUrl.isNotEmpty) {
      body['progressCallBackUrl'] = progressCallBackUrl;
    }
    final http.Response res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw GenerateMediaApiException('HTTP ${res.statusCode}', httpStatus: res.statusCode);
    }
    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    final Map<String, dynamic> data = _unwrap(json);
    final String? taskId = data['taskId'] as String?;
    if (taskId == null || taskId.isEmpty) {
      throw GenerateMediaApiException('Missing taskId');
    }
    return taskId;
  }

  Future<GenerateMediaTaskDetail> getTaskDetail(String taskId) async {
    final Uri uri = Uri.https(host, recordInfoPath, <String, String>{'taskId': taskId});
    final http.Response res = await http.get(uri, headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw GenerateMediaApiException('HTTP ${res.statusCode}', httpStatus: res.statusCode);
    }
    final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
    final Map<String, dynamic> data = _unwrap(json);
    return GenerateMediaTaskDetail(
      taskId: (data['taskId'] as String?) ?? taskId,
      state: (data['state'] as String?) ?? '',
      model: data['model'] as String?,
      resultJson: data['resultJson'] as String?,
      failMsg: data['failMsg'] as String?,
      failCode: data['failCode'] as String?,
    );
  }

  Future<GenerateMediaTaskDetail> pollUntilComplete(
    String taskId, {
    Duration interval = const Duration(seconds: 2),
    int maxAttempts = 90,
    void Function(GenerateMediaTaskDetail detail)? onUpdate,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      final GenerateMediaTaskDetail detail = await getTaskDetail(taskId);
      onUpdate?.call(detail);
      if (detail.isSuccess) {
        return detail;
      }
      if (detail.isFailed) {
        final String err = detail.failMsg?.trim().isNotEmpty == true
            ? detail.failMsg!.trim()
            : 'Task failed (${detail.state})';
        throw GenerateMediaApiException(err);
      }
      await Future<void>.delayed(interval);
    }
    throw GenerateMediaApiException('Timed out waiting for task $taskId');
  }
}
