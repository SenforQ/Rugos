import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AI_chat_page.dart';
import 'custom_teacher_create_page.dart';
import 'custom_teacher_store.dart';
import 'home_search_page.dart';
import 'local_storage_paths.dart';
import 'recommended_characters_data.dart';
import 'wallet_balance_store.dart';
import 'wallet_economy.dart';
import 'my_image_create_page.dart';
import 'my_image_detail_page.dart';
import 'my_image_store.dart';
import 'my_video_create_page.dart';
import 'my_video_detail_page.dart';
import 'my_video_store.dart';
import 'video_local_thumbnail.dart';

const String _kRugosHomeBgmPromptDoneKey = 'rugos_home_bgm_prompt_done_v1';
const String _kRugosHomeBgmUserAgreedKey = 'rugos_home_bgm_user_agreed_v1';
const String _kRugosHomeBgmAssetPath = 'assets/RugosDance.mp3';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final CustomTeacherStore _customTeacherStore = CustomTeacherStore();
  final MyImageStore _myImageStore = MyImageStore();
  final MyVideoStore _myVideoStore = MyVideoStore();
  List<CustomTeacher> _customTeachers = <CustomTeacher>[];
  List<UserDanceImage> _userImages = <UserDanceImage>[];
  List<UserDanceVideo> _userVideos = <UserDanceVideo>[];

  late final AnimationController _bgmRotateController;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  StreamSubscription<bool>? _bgmPlayingSub;
  bool _bgmPromptDone = false;
  bool _bgmInfraReady = false;

  @override
  void initState() {
    super.initState();
    _bgmRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _loadCustomTeachers();
    _loadUserImages();
    _loadUserVideos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapHomeBgm());
    });
  }

  @override
  void dispose() {
    _bgmPlayingSub?.cancel();
    _bgmRotateController.dispose();
    unawaited(_bgmPlayer.dispose());
    super.dispose();
  }

  Future<void> _bootstrapHomeBgm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool done = prefs.getBool(_kRugosHomeBgmPromptDoneKey) ?? false;
    final bool agreed = prefs.getBool(_kRugosHomeBgmUserAgreedKey) ?? false;
    if (!mounted) {
      return;
    }
    setState(() {
      _bgmPromptDone = done;
    });
    if (agreed && done) {
      try {
        await _prepareBgmPlayer();
        if (mounted) {
          await _bgmPlayer.play();
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Background music could not be played.')),
          );
        }
      }
    }
    if (!mounted) {
      return;
    }
    if (!done) {
      await _showHomeBgmConsentDialog();
    }
  }

  Future<void> _prepareBgmPlayer() async {
    if (_bgmInfraReady) {
      return;
    }
    final AudioSession session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _bgmPlayer.setLoopMode(LoopMode.one);
    await _bgmPlayer.setAsset(_kRugosHomeBgmAssetPath);
    _bgmPlayingSub = _bgmPlayer.playingStream.listen((bool playing) {
      if (!mounted) {
        return;
      }
      if (playing) {
        _bgmRotateController.repeat();
      } else {
        _bgmRotateController.stop();
        _bgmRotateController.reset();
      }
      setState(() {});
    });
    _bgmInfraReady = true;
  }

  Future<void> _toggleHomeBgm() async {
    try {
      await _prepareBgmPlayer();
      if (_bgmPlayer.playing) {
        await _bgmPlayer.pause();
      } else {
        await _bgmPlayer.play();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Background music could not be played.')),
        );
      }
    }
  }

  Future<void> _showHomeBgmConsentDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Immersive background music'),
          content: const Text(
            'For a more immersive experience, we may play background music using background audio. If you agree, playback will start automatically and may continue while the app is in the background. You can pause or resume anytime with the circular button at the bottom right.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await prefs.setBool(_kRugosHomeBgmPromptDoneKey, true);
                await prefs.setBool(_kRugosHomeBgmUserAgreedKey, false);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  setState(() {
                    _bgmPromptDone = true;
                  });
                }
              },
              child: const Text('Decline'),
            ),
            FilledButton(
              onPressed: () async {
                await prefs.setBool(_kRugosHomeBgmPromptDoneKey, true);
                await prefs.setBool(_kRugosHomeBgmUserAgreedKey, true);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  setState(() {
                    _bgmPromptDone = true;
                  });
                }
                try {
                  await _prepareBgmPlayer();
                  if (mounted) {
                    await _bgmPlayer.play();
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Background music could not be played.')),
                    );
                  }
                }
              },
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCustomTeachers() async {
    final List<CustomTeacher> teachers = await _customTeacherStore.loadTeachers();
    if (!mounted) {
      return;
    }
    setState(() {
      _customTeachers = teachers;
    });
  }

  Future<void> _loadUserImages() async {
    final List<UserDanceImage> list = await _myImageStore.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _userImages = list;
    });
  }

  Future<void> _loadUserVideos() async {
    final List<UserDanceVideo> list = await _myVideoStore.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _userVideos = list;
    });
  }

  Future<void> _openCreateImagePage() async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const MyImageCreatePage()),
    );
    if (saved == true) {
      await _loadUserImages();
    }
  }

  void _openImageDetail(UserDanceImage item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => MyImageDetailPage(item: item)),
    );
  }

  Future<void> _openCreateVideoPage() async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const MyVideoCreatePage()),
    );
    if (saved == true) {
      await _loadUserVideos();
    }
  }

  void _openVideoDetail(UserDanceVideo item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => MyVideoDetailPage(item: item)),
    );
  }

  Future<void> _openCreateTeacherPage() async {
    final List<CustomTeacher> teachers = await _customTeacherStore.loadTeachers();
    if (teachers.length >= WalletEconomy.freeCustomTeacherSlots) {
      final int balance = await WalletBalanceStore.getBalance();
      if (balance < WalletEconomy.extraTeacherOverFreeCost) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'After ${WalletEconomy.freeCustomTeacherSlots} teachers, each additional one costs ${WalletEconomy.extraTeacherOverFreeCost} Coins. Your balance is insufficient.',
            ),
          ),
        );
        return;
      }
    }
    if (!mounted) {
      return;
    }
    final bool? created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const CustomTeacherCreatePage()),
    );
    if (created == true) {
      await _loadCustomTeachers();
    }
  }

  Future<void> _openHomeSearch() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HomeSearchPage(
          customTeachers: _customTeachers,
          onOpenCustomTeacher: _openCustomTeacherChat,
        ),
      ),
    );
  }

  Future<void> _openCustomTeacherChat(CustomTeacher teacher) async {
    String path = 'assets/user_default.png';
    bool isAsset = true;
    if (teacher.avatarRelativePath.isNotEmpty) {
      final File? file = await LocalStoragePaths.resolveStoredFile(teacher.avatarRelativePath);
      if (file != null) {
        path = file.path;
        isAsset = false;
      }
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiChatPage(
          teacherName: teacher.name,
          danceType: teacher.danceType,
          backgroundIntro: teacher.backgroundIntro,
          imagePath: path,
          presetQuestions: teacher.presetQuestions,
          isAssetImage: isAsset,
          avatarRelativePathForStorage: teacher.avatarRelativePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TopHero(onSearchTap: _openHomeSearch),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionTitle(
                      title: 'Recommended dance teachers',
                      showArrow: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _PopularCharacters(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionTitle(title: 'My custom dance teachers'),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CustomTeachersSection(
                      teachers: _customTeachers,
                      onAdd: _openCreateTeacherPage,
                      onOpenTeacher: _openCustomTeacherChat,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionTitle(title: 'My Image'),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _MyImagesSection(
                      images: _userImages,
                      onAdd: _openCreateImagePage,
                      onOpenImage: _openImageDetail,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionTitle(title: 'My Video'),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 28 + (_bgmPromptDone ? 72 : 0)),
                    child: _MyVideosSection(
                      videos: _userVideos,
                      onAdd: _openCreateVideoPage,
                      onOpenVideo: _openVideoDetail,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_bgmPromptDone)
            Positioned(
              right: 16,
              bottom: 16 + bottomSafe,
              child: Material(
                color: Colors.black,
                shape: const CircleBorder(),
                elevation: 6,
                shadowColor: Colors.black45,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggleHomeBgm,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _bgmRotateController,
                        builder: (BuildContext context, Widget? child) {
                          return Transform.rotate(
                            angle: _bgmRotateController.value * 6.283185307179586,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopHero extends StatelessWidget {
  const _TopHero({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Image(
            image: AssetImage('assets/home_top_banner.png'),
            fit: BoxFit.cover,
          ),
          const _HeroShade(),
          _HeroContent(onSearchTap: onSearchTap),
        ],
      ),
    );
  }
}

class _HeroShade extends StatelessWidget {
  const _HeroShade();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.10),
            Colors.black.withValues(alpha: 0.56),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 6),
            _SearchBar(onTap: onSearchTap),
            const Spacer(),
            const Text(
              'Chat with your custom anime characters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.15,
                shadows: <Shadow>[
                  Shadow(
                    blurRadius: 10,
                    color: Color(0x7A000000),
                    offset: Offset(0, 2),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(34),
        onTap: onTap,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(34),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Row(
            children: <Widget>[
              Icon(Icons.search_rounded, color: Color(0xA0000000), size: 34),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search my teachers & recommended characters',
                  style: TextStyle(
                    color: Color(0x9A000000),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.showArrow = false,
  });

  final String title;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        if (showArrow)
          Icon(
            Icons.arrow_forward,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }
}

class _PopularCharacters extends StatelessWidget {
  const _PopularCharacters();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kRecommendedCharacters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          final RecommendedCharacter item = kRecommendedCharacters[index];
          return _CharacterCard(
            imagePath: item.imagePath,
            name: item.name,
            danceType: item.danceType,
            backgroundIntro: item.backgroundIntro,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AiChatPage(
                    teacherName: item.name,
                    danceType: item.danceType,
                    backgroundIntro: item.backgroundIntro,
                    imagePath: item.imagePath,
                    presetQuestions: item.presetQuestions,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.imagePath,
    required this.name,
    required this.danceType,
    required this.backgroundIntro,
    required this.onTap,
  });

  final String imagePath;
  final String name;
  final String danceType;
  final String backgroundIntro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 170,
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(imagePath, fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 22, 10, 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              danceType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              backgroundIntro,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTeachersSection extends StatelessWidget {
  const _CustomTeachersSection({
    required this.teachers,
    required this.onAdd,
    required this.onOpenTeacher,
  });

  final List<CustomTeacher> teachers;
  final VoidCallback onAdd;
  final ValueChanged<CustomTeacher> onOpenTeacher;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 174,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: teachers.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _AddTeacherCard(onTap: onAdd);
          }
          final CustomTeacher teacher = teachers[index - 1];
          return _CustomTeacherCard(
            teacher: teacher,
            onTap: () => onOpenTeacher(teacher),
          );
        },
      ),
    );
  }
}

class _AddTeacherCard extends StatelessWidget {
  const _AddTeacherCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        width: 156,
        height: 156,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: accent, width: 4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 14),
            Text(
              'Add Teacher',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTeacherCard extends StatelessWidget {
  const _CustomTeacherCard({
    required this.teacher,
    required this.onTap,
  });

  final CustomTeacher teacher;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 156,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 156,
                height: 110,
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
            const SizedBox(height: 8),
            Text(
              teacher.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              teacher.danceType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyImagesSection extends StatelessWidget {
  const _MyImagesSection({
    required this.images,
    required this.onAdd,
    required this.onOpenImage,
  });

  final List<UserDanceImage> images;
  final VoidCallback onAdd;
  final ValueChanged<UserDanceImage> onOpenImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 198,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _MediaSection(
              addLabel: 'Add Image',
              icon: Icons.add_photo_alternate_rounded,
              onAdd: onAdd,
            );
          }
          final UserDanceImage item = images[index - 1];
          return _UserImageCard(
            item: item,
            onTap: () => onOpenImage(item),
          );
        },
      ),
    );
  }
}

class _UserImageCard extends StatelessWidget {
  const _UserImageCard({
    required this.item,
    required this.onTap,
  });

  final UserDanceImage item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 156,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 140,
                height: 100,
                child: FutureBuilder<File?>(
                  future: LocalStoragePaths.resolveStoredFile(item.imageRelativePath),
                  builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                    final File? file = snapshot.data;
                    if (file != null) {
                      return Image.file(file, fit: BoxFit.cover);
                    }
                    return ColoredBox(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade500),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            if (item.tags.isNotEmpty)
              Text(
                item.tags.take(2).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: Colors.black45, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }
}

class _MyVideosSection extends StatelessWidget {
  const _MyVideosSection({
    required this.videos,
    required this.onAdd,
    required this.onOpenVideo,
  });

  final List<UserDanceVideo> videos;
  final VoidCallback onAdd;
  final ValueChanged<UserDanceVideo> onOpenVideo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 198,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: videos.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _MediaSection(
              addLabel: 'Add Video',
              icon: Icons.video_call_rounded,
              onAdd: onAdd,
            );
          }
          final UserDanceVideo item = videos[index - 1];
          return _UserVideoCard(
            item: item,
            onTap: () => onOpenVideo(item),
          );
        },
      ),
    );
  }
}

class _UserVideoCard extends StatefulWidget {
  const _UserVideoCard({
    required this.item,
    required this.onTap,
  });

  final UserDanceVideo item;
  final VoidCallback onTap;

  @override
  State<_UserVideoCard> createState() => _UserVideoCardState();
}

class _UserVideoCardState extends State<_UserVideoCard> {
  late Future<File?> _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = _loadThumb();
  }

  @override
  void didUpdateWidget(covariant _UserVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.videoRelativePath != widget.item.videoRelativePath) {
      _thumbFuture = _loadThumb();
    }
  }

  Future<File?> _loadThumb() async {
    final File? video = await LocalStoragePaths.resolveStoredFile(widget.item.videoRelativePath);
    if (video == null) {
      return null;
    }
    return VideoLocalThumbnail.ensureThumbnailFile(widget.item.videoRelativePath);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: widget.onTap,
      child: Container(
        width: 156,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 140,
                height: 100,
                child: FutureBuilder<File?>(
                  future: _thumbFuture,
                  builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return ColoredBox(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      );
                    }
                    final File? thumb = snapshot.data;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        if (thumb != null)
                          Image.file(
                            thumb,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: Colors.black87,
                              child: Icon(Icons.play_circle_fill, color: Colors.white.withValues(alpha: 0.75), size: 44),
                            ),
                          )
                        else
                          ColoredBox(
                            color: Colors.grey.shade300,
                            child: Icon(Icons.videocam_off_outlined, color: Colors.grey.shade500),
                          ),
                        if (thumb != null)
                          ColoredBox(
                            color: Colors.black.withValues(alpha: 0.22),
                          ),
                        if (thumb != null)
                          const Center(
                            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 44),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            if (widget.item.tags.isNotEmpty)
              Text(
                widget.item.tags.take(2).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: Colors.black45, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({
    required this.addLabel,
    required this.icon,
    required this.onAdd,
  });

  final String addLabel;
  final IconData icon;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onAdd,
          child: Container(
            width: 156,
            height: 156,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accent, width: 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  addLabel,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
