import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';

import 'local_storage_paths.dart';

class VideoLocalThumbnail {
  VideoLocalThumbnail._();

  static final Map<String, Future<File?>> _pending = HashMap<String, Future<File?>>();

  static String relativeThumbnailPathForVideo(String videoRelativePath) {
    final String stem = p.basenameWithoutExtension(videoRelativePath.trim());
    return 'user_dance_videos/thumbnails/${stem}_thumb.jpg';
  }

  static Future<File?> existingThumbnailFile(String videoRelativePath) async {
    final String rel = relativeThumbnailPathForVideo(videoRelativePath);
    if (rel.isEmpty) {
      return null;
    }
    final File f = await LocalStoragePaths.fileFromRelativePath(rel);
    if (await f.exists()) {
      return f;
    }
    return null;
  }

  static Future<File?> ensureThumbnailFile(String videoRelativePath) async {
    final String key = videoRelativePath.trim();
    if (key.isEmpty) {
      return null;
    }
    final File? cached = await existingThumbnailFile(key);
    if (cached != null) {
      return cached;
    }
    return _pending.putIfAbsent(key, () => _generateAndCache(key));
  }

  static Future<File?> _generateAndCache(String videoRelativePath) async {
    try {
      final File? videoFile = await LocalStoragePaths.resolveStoredFile(videoRelativePath);
      if (videoFile == null) {
        return null;
      }
      final File thumbFile = await LocalStoragePaths.fileFromRelativePath(
        relativeThumbnailPathForVideo(videoRelativePath),
      );
      await thumbFile.parent.create(recursive: true);
      final String? outPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: thumbFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        maxHeight: 0,
        timeMs: 0,
        quality: 82,
      );
      if (outPath == null || outPath.isEmpty) {
        return null;
      }
      final File written = File(outPath);
      if (await written.exists()) {
        return written;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      _pending.remove(videoRelativePath);
    }
  }
}
