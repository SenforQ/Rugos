import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'dismiss_keyboard_on_tap.dart';
import 'user_profile_store.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _avatarRelativePath;
  XFile? _pickedAvatar;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final UserProfileData data = await UserProfileStore.load();
    _nicknameController.text = data.nickname;
    _signatureController.text = data.signature;
    _avatarRelativePath = data.avatarRelativePath;
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) {
      return;
    }
    setState(() {
      _pickedAvatar = picked;
    });
  }

  Future<String?> _savePickedAvatarAsRelativePath() async {
    if (_pickedAvatar == null) {
      return _avatarRelativePath;
    }
    final Directory baseDir = await getApplicationDocumentsDirectory();
    const String relativePath = 'profile_avatar.png';
    final File targetFile = File('${baseDir.path}/$relativePath');
    final List<int> bytes = await _pickedAvatar!.readAsBytes();
    await targetFile.writeAsBytes(bytes, flush: true);
    return relativePath;
  }

  Future<void> _save() async {
    final String nickname = _nicknameController.text.trim();
    final String signature = _signatureController.text.trim();
    if (nickname.isEmpty || signature.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in nickname and signature.')),
      );
      return;
    }
    setState(() {
      _saving = true;
    });
    final String? relativePath = await _savePickedAvatarAsRelativePath();
    await UserProfileStore.save(
      nickname: nickname,
      signature: signature,
      avatarRelativePath: relativePath,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<ImageProvider<Object>> _avatarProvider() async {
    if (_pickedAvatar != null) {
      return FileImage(File(_pickedAvatar!.path));
    }
    if (_avatarRelativePath != null) {
      final File avatarFile = await UserProfileStore.avatarFileFromRelativePath(_avatarRelativePath!);
      if (await avatarFile.exists()) {
        return FileImage(avatarFile);
      }
    }
    return const AssetImage('assets/user_default.png');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Information')),
      body: DismissKeyboardOnTap(
        child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: FutureBuilder<ImageProvider<Object>>(
                future: _avatarProvider(),
                builder: (BuildContext context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
                  final ImageProvider<Object> provider =
                      snapshot.data ?? const AssetImage('assets/user_default.png');
                  return Column(
                    children: [
                      CircleAvatar(radius: 44, backgroundImage: provider),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _pickAvatar,
                        child: const Text('Choose Avatar'),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nickname', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                hintText: 'Enter nickname',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Signature', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _signatureController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter signature',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
