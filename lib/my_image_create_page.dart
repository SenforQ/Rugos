import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'dismiss_keyboard_on_tap.dart';
import 'my_image_store.dart';

class MyImageCreatePage extends StatefulWidget {
  const MyImageCreatePage({super.key});

  @override
  State<MyImageCreatePage> createState() => _MyImageCreatePageState();
}

class _MyImageCreatePageState extends State<MyImageCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final MyImageStore _store = MyImageStore();

  XFile? _pickedImage;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _experienceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (file == null) {
      return;
    }
    setState(() {
      _pickedImage = file;
    });
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(RegExp(r'[,，、\s]+'))
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an image first')),
      );
      return;
    }
    final String title = _titleController.text.trim();
    final String experience = _experienceController.text.trim();
    if (title.isEmpty || experience.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title and notes')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });
    try {
      final Directory docs = await getApplicationDocumentsDirectory();
      final Directory dir = Directory('${docs.path}/user_dance_images');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String relativePath = 'user_dance_images/$fileName';
      final String targetPath = '${docs.path}/$relativePath';
      final List<int> bytes = await _pickedImage!.readAsBytes();
      await File(targetPath).writeAsBytes(bytes, flush: true);

      final UserDanceImage item = UserDanceImage(
        imageRelativePath: relativePath,
        title: title,
        experience: experience,
        tags: _parseTags(_tagsController.text),
      );
      await _store.add(item);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save failed — try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add image')),
      body: DismissKeyboardOnTap(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: _pickedImage == null
                            ? ColoredBox(
                                color: Colors.grey.shade200,
                                child: Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade500),
                              )
                            : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose image'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Title for this practice photo',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
                controller: _experienceController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: 'What you practiced, what worked, what to improve…',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Comma-separated tags, e.g. hip-hop, basics, daily',
                ),
              ),
              const SizedBox(height: 28),
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
