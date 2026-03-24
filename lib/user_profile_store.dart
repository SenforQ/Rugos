import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_paths.dart';

class UserProfileData {
  const UserProfileData({
    required this.nickname,
    required this.signature,
    required this.avatarRelativePath,
  });

  final String nickname;
  final String signature;
  final String? avatarRelativePath;
}

class UserProfileStore {
  static const String _nicknameKey = 'user_nickname';
  static const String _signatureKey = 'user_signature';
  static const String _avatarRelativePathKey = 'user_avatar_relative_path';
  static const String defaultNickname = 'Rugos';
  static const String defaultSignature = 'Create your next story.';

  static Future<UserProfileData> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return UserProfileData(
      nickname: prefs.getString(_nicknameKey) ?? defaultNickname,
      signature: prefs.getString(_signatureKey) ?? defaultSignature,
      avatarRelativePath: prefs.getString(_avatarRelativePathKey),
    );
  }

  static Future<void> save({
    required String nickname,
    required String signature,
    String? avatarRelativePath,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);
    await prefs.setString(_signatureKey, signature);
    if (avatarRelativePath != null) {
      await prefs.setString(_avatarRelativePathKey, avatarRelativePath);
    }
  }

  static Future<File> avatarFileFromRelativePath(String relativePath) async {
    return LocalStoragePaths.fileFromRelativePath(relativePath);
  }
}
