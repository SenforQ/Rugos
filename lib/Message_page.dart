import 'dart:io';

import 'package:flutter/material.dart';

import 'AI_chat_page.dart';
import 'local_storage_paths.dart';
import 'teacher_chat_session_store.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TeacherChatSessionStore _store = TeacherChatSessionStore();
  bool _loading = true;
  List<TeacherChatSession> _sessions = <TeacherChatSession>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<TeacherChatSession> list = await _store.loadSessionsSorted();
    if (!mounted) {
      return;
    }
    setState(() {
      _sessions = list;
      _loading = false;
    });
  }

  String _formatSessionTime(int ms) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(dt.year, dt.month, dt.day);
    if (day == today) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (today.difference(day).inDays == 1) {
      return 'Yesterday';
    }
    return '${dt.month}/${dt.day}';
  }

  String _ellipsis(String text, int maxLen) {
    final String t = text.trim();
    if (t.length <= maxLen) {
      return t;
    }
    return '${t.substring(0, maxLen)}…';
  }

  Future<void> _openSession(TeacherChatSession session) async {
    String path = session.imageRef;
    bool isAsset = session.imageIsAsset;
    if (!session.imageIsAsset) {
      final File? f = await LocalStoragePaths.resolveStoredFile(session.imageRef);
      if (f != null) {
        path = f.path;
        isAsset = false;
      } else {
        path = 'assets/user_default.png';
        isAsset = true;
      }
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiChatPage(
          teacherName: session.teacherName,
          danceType: session.danceType,
          backgroundIntro: session.backgroundIntro,
          imagePath: path,
          presetQuestions: session.presetQuestions,
          isAssetImage: isAsset,
          avatarRelativePathForStorage: session.imageIsAsset ? null : session.imageRef,
        ),
      ),
    );
    await _load();
  }

  void _goHomeTab() {
    final TabController? tab = DefaultTabController.maybeOf(context);
    if (tab != null) {
      tab.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Messages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'Chats with your dance teachers appear here after you start a conversation.',
                        style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.55)),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_sessions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyTeacherChatState(primary: primary, onGoHome: _goHomeTab),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final TeacherChatSession s = _sessions[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == _sessions.length - 1 ? 0 : 10),
                        child: _TeacherSessionCard(
                          session: s,
                          timeLabel: _formatSessionTime(s.updatedAtMs),
                          preview: _ellipsis(s.lastSnippet, 120),
                          onTap: () => _openSession(s),
                        ),
                      );
                    },
                    childCount: _sessions.length,
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

class _EmptyTeacherChatState extends StatelessWidget {
  const _EmptyTeacherChatState({
    required this.primary,
    required this.onGoHome,
  });

  final Color primary;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 44, color: primary),
          ),
          const SizedBox(height: 18),
          const Text(
            'No teacher chats yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            'Pick a dance teacher on Home and send a message. Your conversation will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.45, color: Colors.black.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: onGoHome,
            child: const Text('Find a teacher on Home'),
          ),
        ],
      ),
    );
  }
}

class _TeacherSessionCard extends StatelessWidget {
  const _TeacherSessionCard({
    required this.session,
    required this.timeLabel,
    required this.preview,
    required this.onTap,
  });

  final TeacherChatSession session;
  final String timeLabel;
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SessionAvatar(session: session),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${session.teacherName} · ${session.danceType}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(timeLabel, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionAvatar extends StatelessWidget {
  const _SessionAvatar({required this.session});

  final TeacherChatSession session;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    if (session.imageIsAsset) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          session.imageRef,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _AvatarFallback(primary: primary),
        ),
      );
    }
    return FutureBuilder<File?>(
      future: LocalStoragePaths.resolveStoredFile(session.imageRef),
      builder: (BuildContext context, AsyncSnapshot<File?> snap) {
        final File? f = snap.data;
        if (f != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(f, width: 40, height: 40, fit: BoxFit.cover),
          );
        }
        return _AvatarFallback(primary: primary);
      },
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.sports_gymnastics_rounded, color: primary, size: 22),
    );
  }
}
