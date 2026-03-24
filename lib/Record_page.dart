import 'dart:io';

import 'package:flutter/material.dart';

import 'local_storage_paths.dart';
import 'magic_generation_detail_page.dart';
import 'magic_generation_store.dart';
import 'record_refresh_notifier.dart';
import 'video_local_thumbnail.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final MagicGenerationStore _store = MagicGenerationStore();
  List<MagicGenerationRecord> _items = <MagicGenerationRecord>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    recordLibraryRefreshSignal.addListener(_onRefreshSignal);
    _load();
  }

  Future<void> _load() async {
    final List<MagicGenerationRecord> list = await _store.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  void _onRefreshSignal() {
    _load();
  }

  @override
  void dispose() {
    recordLibraryRefreshSignal.removeListener(_onRefreshSignal);
    super.dispose();
  }

  String _formatTime(int ms) {
    if (ms <= 0) {
      return '';
    }
    final DateTime d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(MagicGenerationRecord r) {
    if (r.isProcessing) {
      return 'Generating';
    }
    if (r.isSuccess) {
      return 'Done';
    }
    if (r.isFailed) {
      return 'Failed';
    }
    if (r.isNoResult) {
      return 'No result';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Record', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text(
                        'Your generations',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Each job is saved on this device when you start it. Running jobs stay in the list — pull down to refresh.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No generations yet', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                      const SizedBox(height: 8),
                      Text('Use Magic to create an image or video', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final MagicGenerationRecord item = _items[index];
                      return _RecordTile(
                        record: item,
                        timeLabel: _formatTime(item.createdAtMs),
                        statusLabel: _statusLabel(item),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext c) => MagicGenerationDetailPage(record: item),
                            ),
                          ).then((_) {
                            _load();
                          });
                        },
                      );
                    },
                    childCount: _items.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.timeLabel,
    required this.statusLabel,
    required this.onTap,
  });

  final MagicGenerationRecord record;
  final String timeLabel;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _RecordMediaThumb(record: record),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.isVideo ? 'Image → video' : 'Text → image',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: record.isProcessing
                              ? accent.withValues(alpha: 0.15)
                              : record.isSuccess
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: record.isProcessing
                                ? accent
                                : record.isSuccess
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  if (record.isProcessing && (record.lastPollState ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      record.lastPollState!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, color: accent, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if ((record.isFailed || record.isNoResult) && (record.failMessage ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      record.failMessage!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, height: 1.2, color: Colors.red.shade700),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    record.prompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, height: 1.25, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordMediaThumb extends StatelessWidget {
  const _RecordMediaThumb({required this.record});

  final MagicGenerationRecord record;

  @override
  Widget build(BuildContext context) {
    if (record.isProcessing) {
      return ColoredBox(
        color: Colors.grey.shade200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  record.lastPollState ?? 'Generating',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, height: 1.2, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (record.isFailed || record.isNoResult) {
      return ColoredBox(
        color: Colors.red.shade50,
        child: Center(
          child: Icon(
            record.isNoResult ? Icons.hourglass_disabled_outlined : Icons.error_outline_rounded,
            color: Colors.red.shade400,
            size: 40,
          ),
        ),
      );
    }
    final String path = record.primaryLocalPath;
    if (path.isEmpty) {
      return ColoredBox(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.insert_drive_file_outlined)),
      );
    }
    if (record.isVideo) {
      return _VideoThumb(path: path);
    }
    return _ImageThumb(path: path);
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: LocalStoragePaths.resolveStoredFile(path),
      builder: (BuildContext context, AsyncSnapshot<File?> snap) {
        final File? f = snap.data;
        if (f == null) {
          return ColoredBox(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image_not_supported_outlined)));
        }
        return Image.file(f, fit: BoxFit.cover);
      },
    );
  }
}

class _VideoThumb extends StatelessWidget {
  const _VideoThumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: VideoLocalThumbnail.ensureThumbnailFile(path),
      builder: (BuildContext context, AsyncSnapshot<File?> snap) {
        final File? thumb = snap.data;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (thumb != null)
              Image.file(thumb, fit: BoxFit.cover)
            else
              ColoredBox(color: Colors.black87),
            const Center(
              child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
            ),
          ],
        );
      },
    );
  }
}
