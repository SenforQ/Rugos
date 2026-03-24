import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'dismiss_keyboard_on_tap.dart';
import 'my_video_store.dart';
import 'video_local_thumbnail.dart';

class MyVideoCreatePage extends StatefulWidget {
  const MyVideoCreatePage({super.key});

  @override
  State<MyVideoCreatePage> createState() => _MyVideoCreatePageState();
}

class _MyVideoCreatePageState extends State<MyVideoCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final MyVideoStore _store = MyVideoStore();

  XFile? _pickedVideo;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _experienceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    setState(() {
      _pickedVideo = file;
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
    if (_pickedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a video first')),
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
      final Directory dir = Directory('${docs.path}/user_dance_videos');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final String ext = p.extension(_pickedVideo!.path);
      final String safeExt = ext.isNotEmpty ? ext : '.mp4';
      final String fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}$safeExt';
      final String relativePath = 'user_dance_videos/$fileName';
      final String targetPath = '${docs.path}/$relativePath';
      final List<int> bytes = await _pickedVideo!.readAsBytes();
      await File(targetPath).writeAsBytes(bytes, flush: true);
      await VideoLocalThumbnail.ensureThumbnailFile(relativePath);

      final UserDanceVideo item = UserDanceVideo(
        videoRelativePath: relativePath,
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
      appBar: AppBar(title: const Text('Add video')),
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
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: _pickedVideo == null
                          ? Icon(Icons.video_library_outlined, size: 64, color: Colors.grey.shade500)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade600),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    p.basename(_pickedVideo!.path),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.video_file_outlined),
                      label: const Text('Choose video'),
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
                  hintText: 'Title for this practice clip',
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
