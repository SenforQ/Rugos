import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> downloadBytesToMagicGenerations(
  String url, {
  String? forcedExtension,
}) async {
  final Uri uri = Uri.parse(url);
  final http.Response resp = await http.get(uri);
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    throw Exception('Download failed HTTP ${resp.statusCode}');
  }
  final List<int> bytes = resp.bodyBytes;
  final Directory docs = await getApplicationDocumentsDirectory();
  final Directory dir = Directory(p.join(docs.path, 'magic_generations'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  String ext = forcedExtension ?? p.extension(uri.path);
  if (ext.isEmpty || ext.length > 6) {
    ext = '.bin';
  }
  final String name = 'mg_${DateTime.now().millisecondsSinceEpoch}$ext';
  final String relative = 'magic_generations/$name';
  final File file = File(p.join(docs.path, relative));
  await file.writeAsBytes(bytes, flush: true);
  return relative;
}

String guessImageExtensionFromUrl(String url) {
  final String ext = p.extension(Uri.parse(url).path).toLowerCase();
  if (ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp') {
    return ext;
  }
  return '.png';
}

String guessVideoExtensionFromUrl(String url) {
  final String ext = p.extension(Uri.parse(url).path).toLowerCase();
  if (ext == '.mp4' || ext == '.mov' || ext == '.webm') {
    return ext;
  }
  return '.mp4';
}
