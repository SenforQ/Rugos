import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'generate_media_api_config.dart';

class GenerateMediaUploadException implements Exception {
  GenerateMediaUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _mimeFromExtension(String ext) {
  switch (ext.toLowerCase()) {
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.png':
      return 'image/png';
    case '.webp':
      return 'image/webp';
    case '.gif':
      return 'image/gif';
    default:
      return 'image/jpeg';
  }
}

Future<String> uploadLocalImageFileForGeneration(String absolutePath) async {
  final File file = File(absolutePath);
  if (!await file.exists()) {
    throw GenerateMediaUploadException('That file could not be found.');
  }
  final int size = await file.length();
  if (size > 10 * 1024 * 1024) {
    throw GenerateMediaUploadException('Image must be 10 MB or smaller.');
  }
  final List<int> bytes = await file.readAsBytes();
  final String ext = p.extension(absolutePath);
  final String mime = _mimeFromExtension(ext);
  final String b64 = base64Encode(bytes);
  final String base64Data = 'data:$mime;base64,$b64';
  final String fileName = p.basename(absolutePath);
  final Uri uri = Uri.parse('https://kieai.redpandaai.co/api/file-base64-upload');
  final Map<String, dynamic> payload = <String, dynamic>{
    'base64Data': base64Data,
    'uploadPath': 'images/base64',
    'fileName': fileName,
  };
  final http.Response res = await http.post(
    uri,
    headers: <String, String>{
      'Authorization': 'Bearer $kGenerateMediaApiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(payload),
  );
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw GenerateMediaUploadException('Upload failed (HTTP ${res.statusCode}).');
  }
  final Object? decoded = jsonDecode(res.body);
  if (decoded is! Map<String, dynamic>) {
    throw GenerateMediaUploadException('Unexpected upload response.');
  }
  final Map<String, dynamic> json = decoded;
  final bool success = json['success'] == true;
  final int? code = json['code'] as int?;
  if (!success || code != 200) {
    final String msg = (json['msg'] as String?) ?? 'Upload failed';
    throw GenerateMediaUploadException(msg);
  }
  final Object? dataRaw = json['data'];
  if (dataRaw is! Map<String, dynamic>) {
    throw GenerateMediaUploadException('Upload response missing data.');
  }
  final String? url = dataRaw['downloadUrl'] as String?;
  if (url == null || url.trim().isEmpty) {
    throw GenerateMediaUploadException('Upload response missing file URL.');
  }
  return url.trim();
}
