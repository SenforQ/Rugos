import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'custom_teacher_store.dart';
import 'dismiss_keyboard_on_tap.dart';
import 'wallet_balance_store.dart';
import 'wallet_economy.dart';

class CustomTeacherCreatePage extends StatefulWidget {
  const CustomTeacherCreatePage({super.key});

  @override
  State<CustomTeacherCreatePage> createState() => _CustomTeacherCreatePageState();
}

class _CustomTeacherCreatePageState extends State<CustomTeacherCreatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _danceTypeController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController(
    text: 'How should I start training this week?\nGive me a 15-minute routine for today.\nHow can I improve my rhythm and timing?\nCreate a beginner combo for me.',
  );
  final ImagePicker _picker = ImagePicker();
  final CustomTeacherStore _store = CustomTeacherStore();

  XFile? _pickedAvatar;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _danceTypeController.dispose();
    _introController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null) {
      return;
    }
    setState(() {
      _pickedAvatar = file;
    });
  }

  Future<String> _saveAvatarToSandbox() async {
    if (_pickedAvatar == null) {
      return '';
    }
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${docs.path}/custom_teacher_avatars');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.png';
    final String relativePath = 'custom_teacher_avatars/$fileName';
    final String targetPath = '${docs.path}/$relativePath';
    final List<int> bytes = await _pickedAvatar!.readAsBytes();
    await File(targetPath).writeAsBytes(bytes, flush: true);
    return relativePath;
  }

  Future<void> _saveTeacher() async {
    final String name = _nameController.text.trim();
    final String danceType = _danceTypeController.text.trim();
    final String intro = _introController.text.trim();
    if (name.isEmpty || danceType.isEmpty || intro.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });
    bool chargedForExtraSlot = false;
    try {
      final List<CustomTeacher> existing = await _store.loadTeachers();
      if (existing.length >= WalletEconomy.freeCustomTeacherSlots) {
        final int balance = await WalletBalanceStore.getBalance();
        if (balance < WalletEconomy.extraTeacherOverFreeCost) {
          if (!mounted) {
            return;
          }
          setState(() {
            _saving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '已有${WalletEconomy.freeCustomTeacherSlots}个机器人后，每新增1个需${WalletEconomy.extraTeacherOverFreeCost} Coins，当前余额不足',
              ),
            ),
          );
          return;
        }
        final bool paid = await WalletBalanceStore.deductCoins(WalletEconomy.extraTeacherOverFreeCost);
        if (!paid) {
          if (!mounted) {
            return;
          }
          setState(() {
            _saving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('扣费失败，请稍后重试')),
          );
          return;
        }
        chargedForExtraSlot = true;
      }

      final String avatarPath = await _saveAvatarToSandbox();
      final List<String> presets = _questionsController.text
          .split('\n')
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty)
          .toList();

      final CustomTeacher teacher = CustomTeacher(
        name: name,
        danceType: danceType,
        backgroundIntro: intro,
        avatarRelativePath: avatarPath,
        presetQuestions: presets,
      );
      await _store.addTeacher(teacher);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (chargedForExtraSlot) {
        await WalletBalanceStore.addCoins(WalletEconomy.extraTeacherOverFreeCost);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Dance Teacher')),
      body: DismissKeyboardOnTap(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 46,
                      backgroundImage: _pickedAvatar == null ? null : FileImage(File(_pickedAvatar!.path)),
                      child: _pickedAvatar == null ? const Icon(Icons.person, size: 46) : null,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _pickAvatar,
                      child: const Text('Upload Avatar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Teacher Name', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. Nova'),
              ),
              const SizedBox(height: 14),
              const Text('Dance Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _danceTypeController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. Street Dance'),
              ),
              const SizedBox(height: 14),
              const Text('Background Intro', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _introController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Short profile for this coach (used as context when you chat).',
                ),
              ),
              const SizedBox(height: 14),
              const Text('Quick Preset Questions (one per line)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _questionsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Line-separated questions',
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _saveTeacher,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
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
