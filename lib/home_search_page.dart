import 'dart:io';

import 'package:flutter/material.dart';

import 'AI_chat_page.dart';
import 'custom_teacher_store.dart';
import 'local_storage_paths.dart';
import 'recommended_characters_data.dart';

class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({
    super.key,
    required this.customTeachers,
    required this.onOpenCustomTeacher,
  });

  final List<CustomTeacher> customTeachers;
  final Future<void> Function(CustomTeacher teacher) onOpenCustomTeacher;

  @override
  State<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    setState(() {
      _query = _queryController.text.trim();
    });
  }

  @override
  void dispose() {
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    super.dispose();
  }

  bool _matchesRecommended(RecommendedCharacter c, String q) {
    if (q.isEmpty) {
      return true;
    }
    return c.name.toLowerCase().contains(q) ||
        c.danceType.toLowerCase().contains(q) ||
        c.backgroundIntro.toLowerCase().contains(q);
  }

  bool _matchesCustom(CustomTeacher t, String q) {
    if (q.isEmpty) {
      return true;
    }
    return t.name.toLowerCase().contains(q) ||
        t.danceType.toLowerCase().contains(q) ||
        t.backgroundIntro.toLowerCase().contains(q);
  }

  void _openRecommended(RecommendedCharacter c) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiChatPage(
          teacherName: c.name,
          danceType: c.danceType,
          backgroundIntro: c.backgroundIntro,
          imagePath: c.imagePath,
          presetQuestions: c.presetQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String q = _query.toLowerCase();
    final List<RecommendedCharacter> recommended =
        kRecommendedCharacters.where((RecommendedCharacter c) => _matchesRecommended(c, q)).toList();
    final List<CustomTeacher> custom =
        widget.customTeachers.where((CustomTeacher t) => _matchesCustom(t, q)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: _queryController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search my teachers & recommended characters',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _queryController.clear();
                      },
                    ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          if (recommended.isEmpty && custom.isEmpty && _query.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  'No matching teachers or characters.',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ),
            ),
          if (recommended.isNotEmpty) ...<Widget>[
            const Text(
              'Recommended',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
            ),
            const SizedBox(height: 10),
            ...recommended.map(
              (RecommendedCharacter c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SearchResultRecommendedTile(character: c, onTap: () => _openRecommended(c)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (custom.isNotEmpty) ...<Widget>[
            const Text(
              'My custom dance teachers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
            ),
            const SizedBox(height: 10),
            ...custom.map(
              (CustomTeacher t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SearchResultCustomTile(
                  teacher: t,
                  onTap: () => widget.onOpenCustomTeacher(t),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResultRecommendedTile extends StatelessWidget {
  const _SearchResultRecommendedTile({
    required this.character,
    required this.onTap,
  });

  final RecommendedCharacter character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(character.imagePath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      character.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.danceType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.backgroundIntro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.25),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultCustomTile extends StatelessWidget {
  const _SearchResultCustomTile({
    required this.teacher,
    required this.onTap,
  });

  final CustomTeacher teacher;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: teacher.avatarRelativePath.isEmpty
                      ? Image.asset('assets/user_default.png', fit: BoxFit.cover)
                      : FutureBuilder<File?>(
                          future: LocalStoragePaths.resolveStoredFile(teacher.avatarRelativePath),
                          builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                            final File? file = snapshot.data;
                            if (file != null) {
                              return Image.file(file, fit: BoxFit.cover);
                            }
                            return Image.asset('assets/user_default.png', fit: BoxFit.cover);
                          },
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      teacher.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      teacher.danceType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.backgroundIntro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.25),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
