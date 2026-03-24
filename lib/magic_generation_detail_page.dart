import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:video_player/video_player.dart';

import 'local_storage_paths.dart';
import 'magic_generation_store.dart';
import 'video_local_thumbnail.dart';

class MagicGenerationDetailPage extends StatefulWidget {
  const MagicGenerationDetailPage({super.key, required this.record});

  final MagicGenerationRecord record;

  @override
  State<MagicGenerationDetailPage> createState() => _MagicGenerationDetailPageState();
}

class _MagicGenerationDetailPageState extends State<MagicGenerationDetailPage> {
  VideoPlayerController? _videoController;
  bool _inlineVideoHiddenForFullscreen = false;

  @override
  void initState() {
    super.initState();
    if (widget.record.isVideo && widget.record.isSuccess && widget.record.primaryLocalPath.isNotEmpty) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    try {
      final File? f = await LocalStoragePaths.resolveStoredFile(widget.record.primaryLocalPath);
      if (f == null || !mounted) {
        return;
      }
      final VideoPlayerController c = VideoPlayerController.file(f);
      await c.initialize();
      c.setLooping(true);
      c.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          _videoController = c;
        });
      } else {
        await c.dispose();
      }
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _openVideoFullscreen() async {
    final VideoPlayerController? c = _videoController;
    if (c == null || !c.value.isInitialized || !mounted) {
      return;
    }
    setState(() {
      _inlineVideoHiddenForFullscreen = true;
    });
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) => _FullscreenLocalVideoPage(controller: c),
      ),
    );
    if (mounted) {
      setState(() {
        _inlineVideoHiddenForFullscreen = false;
      });
    }
  }

  bool get _canSaveImagesToGallery {
    final MagicGenerationRecord r = widget.record;
    return r.isSuccess && !r.isVideo && r.mediaRelativePaths.isNotEmpty;
  }

  Future<void> _saveImagesToGallery() async {
    final MagicGenerationRecord r = widget.record;
    final List<String> rels = r.mediaRelativePaths;
    if (rels.isEmpty) {
      return;
    }
    final bool access = await Gal.hasAccess(toAlbum: false);
    if (!access) {
      final bool granted = await Gal.requestAccess(toAlbum: false);
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo library access is required to save images')),
          );
        }
        return;
      }
    }
    int saved = 0;
    try {
      for (int i = 0; i < rels.length; i++) {
        final String rel = rels[i];
        final File? file = await LocalStoragePaths.resolveStoredFile(rel);
        if (file == null || !await file.exists()) {
          continue;
        }
        await Gal.putImage(file.path);
        saved++;
      }
      if (!mounted) {
        return;
      }
      if (saved == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local image file not found')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saved == 1 ? 'Saved to Photos' : 'Saved $saved images to Photos')),
      );
    } on GalException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: ${e.type.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MagicGenerationRecord r = widget.record;
    return Scaffold(
      appBar: AppBar(
        title: Text(r.isVideo ? 'Video detail' : 'Image detail'),
        actions: [
          if (_canSaveImagesToGallery)
            IconButton(
              tooltip: 'Save to Photos',
              icon: const Icon(Icons.download_rounded),
              onPressed: _saveImagesToGallery,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (r.isProcessing) _buildProcessingBlock(r),
            if (r.isFailed || r.isNoResult) _buildErrorBlock(r),
            if (r.isSuccess && !r.isVideo) _buildImageSuccess(r),
            if (r.isSuccess && r.isVideo) _buildVideoArea(r),
            const SizedBox(height: 16),
            Text(
              'Prompt',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),
            SelectableText(r.prompt, style: const TextStyle(fontSize: 14, height: 1.45)),
            const SizedBox(height: 12),
            Text(
              'Parameters',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),
            SelectableText(r.aspectInfo, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
            const SizedBox(height: 8),
            SelectableText('taskId: ${r.taskId}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            if ((r.lastPollState ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              SelectableText('Latest status: ${r.lastPollState}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingBlock(MagicGenerationRecord r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 14),
              const Text('Generating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                r.lastPollState ?? 'Queued or processing',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBlock(MagicGenerationRecord r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  r.failMessage ?? (r.isNoResult ? 'No media URL returned' : 'Generation failed'),
                  style: TextStyle(fontSize: 14, height: 1.4, color: Colors.red.shade900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSuccess(MagicGenerationRecord r) {
    final List<String> paths = r.mediaRelativePaths;
    if (paths.isEmpty) {
      return const SizedBox.shrink();
    }
    if (paths.length == 1) {
      return FutureBuilder<File?>(
        future: LocalStoragePaths.resolveStoredFile(paths.first),
        builder: (BuildContext context, AsyncSnapshot<File?> snap) {
          final File? file = snap.data;
          if (file == null) {
            return const SizedBox(
              height: 220,
              child: Center(child: Icon(Icons.broken_image_outlined, size: 48)),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              minScale: 0.6,
              maxScale: 4,
              child: Image.file(file, fit: BoxFit.contain),
            ),
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Total ${paths.length} images', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700)),
        const SizedBox(height: 10),
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: paths.length,
            itemBuilder: (BuildContext context, int index) {
              final String rel = paths[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FutureBuilder<File?>(
                  future: LocalStoragePaths.resolveStoredFile(rel),
                  builder: (BuildContext context, AsyncSnapshot<File?> snap) {
                    final File? file = snap.data;
                    if (file == null) {
                      return const Center(child: Icon(Icons.broken_image_outlined));
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        minScale: 0.6,
                        maxScale: 4,
                        child: Image.file(file, fit: BoxFit.contain),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoArea(MagicGenerationRecord r) {
    final VideoPlayerController? c = _videoController;
    if (c == null || !c.value.isInitialized) {
      return SizedBox(
        height: 220,
        child: FutureBuilder<File?>(
          future: LocalStoragePaths.resolveStoredFile(r.primaryLocalPath),
          builder: (BuildContext context, AsyncSnapshot<File?> snap) {
            final File? vf = snap.data;
            if (vf == null) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }
            return FutureBuilder<File?>(
              future: VideoLocalThumbnail.ensureThumbnailFile(r.primaryLocalPath),
              builder: (BuildContext context, AsyncSnapshot<File?> t) {
                final File? thumb = t.data;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: thumb != null
                        ? Image.file(thumb, fit: BoxFit.cover)
                        : ColoredBox(
                            color: Colors.black87,
                            child: Icon(Icons.play_circle_outline, color: Colors.white.withValues(alpha: 0.8), size: 56),
                          ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
    final double ar = c.value.aspectRatio;
    if (_inlineVideoHiddenForFullscreen) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: ar == 0 ? 16 / 9 : ar,
          child: ColoredBox(
            color: Colors.black87,
            child: Center(
              child: Text(
                'Playing fullscreen…',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
              ),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: ar == 0 ? 16 / 9 : ar,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                if (c.value.isPlaying) {
                  c.pause();
                } else {
                  c.play();
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VideoPlayer(c),
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        c.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 56,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  tooltip: 'Fullscreen',
                  icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
                  onPressed: _openVideoFullscreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenLocalVideoPage extends StatefulWidget {
  const _FullscreenLocalVideoPage({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_FullscreenLocalVideoPage> createState() => _FullscreenLocalVideoPageState();
}

class _FullscreenLocalVideoPageState extends State<_FullscreenLocalVideoPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    widget.controller.addListener(_onVideoTick);
  }

  void _onVideoTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoTick);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final VideoPlayerController c = widget.controller;
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController c = widget.controller;
    final double ar = c.value.isInitialized && c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9;
    final EdgeInsets pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Center(
              child: AspectRatio(
                aspectRatio: ar,
                child: VideoPlayer(c),
              ),
            ),
          ),
          Positioned(
            top: pad.top + 8,
            left: 8,
            child: IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: pad.bottom + 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 56,
                  color: Colors.white,
                  icon: Icon(c.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  onPressed: _togglePlay,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
