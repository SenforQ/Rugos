import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'local_storage_paths.dart';
import 'my_video_store.dart';

class MyVideoDetailPage extends StatefulWidget {
  const MyVideoDetailPage({super.key, required this.item});

  final UserDanceVideo item;

  @override
  State<MyVideoDetailPage> createState() => _MyVideoDetailPageState();
}

class _MyVideoDetailPageState extends State<MyVideoDetailPage> {
  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final File? file = await LocalStoragePaths.resolveStoredFile(widget.item.videoRelativePath);
    if (file == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Video file not found';
        });
      }
      return;
    }
    final VideoPlayerController c = VideoPlayerController.file(file);
    try {
      await c.initialize();
      c.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          _controller = c;
          _loading = false;
        });
      }
    } catch (e) {
      await c.dispose();
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Unable to play video';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: _controller != null && _controller!.value.isInitialized
                    ? _controller!.value.aspectRatio
                    : 16 / 9,
                child: _buildVideoArea(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(widget.item.experience, style: const TextStyle(fontSize: 15, height: 1.45)),
            if (widget.item.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Tags', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final String t in widget.item.tags)
                    Chip(
                      label: Text(t),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_loading) {
      return const ColoredBox(
        color: Colors.black87,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_error != null) {
      return ColoredBox(
        color: Colors.grey.shade300,
        child: Center(child: Text(_error!, style: const TextStyle(color: Colors.black54))),
      );
    }
    final VideoPlayerController c = _controller!;
    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(c),
        IconButton(
          iconSize: 56,
          color: Colors.white,
          icon: Icon(c.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          onPressed: () {
            setState(() {
              if (c.value.isPlaying) {
                c.pause();
              } else {
                c.play();
              }
            });
          },
        ),
      ],
    );
  }
}
