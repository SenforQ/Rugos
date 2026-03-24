import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Same as [Editor_page] / [UserProfileStore]: persist only **paths relative to ApplicationDocumentsDirectory**,
/// and resolve real files with [fileFromRelativePath] for display.
class LocalStoragePaths {
  LocalStoragePaths._();

  static Future<File> fileFromRelativePath(String relativePath) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    return File(p.normalize(p.join(baseDir.path, relativePath)));
  }

  /// Resolves a stored path: prefers relative paths; legacy absolute paths are used if the file still exists.
  static Future<File?> resolveStoredFile(String stored) async {
    final String trimmed = stored.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (p.isAbsolute(trimmed)) {
      final File legacy = File(trimmed);
      if (await legacy.exists()) {
        return legacy;
      }
      return null;
    }
    final File file = await fileFromRelativePath(trimmed);
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
