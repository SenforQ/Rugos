import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'magic_ai_consent_dialog.dart';
import 'magic_image_generation_page.dart';
import 'magic_video_generation_page.dart';
import 'wallet_balance_store.dart';
import 'wallet_economy.dart';

class MagicPage extends StatefulWidget {
  const MagicPage({super.key});

  @override
  State<MagicPage> createState() => _MagicPageState();
}

class _MagicPageState extends State<MagicPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Generate'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Text to image'),
            Tab(text: 'Image to video'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TextToImageTab(),
          _ImageToVideoTab(),
        ],
      ),
    );
  }
}

class _TextToImageTab extends StatefulWidget {
  const _TextToImageTab();

  @override
  State<_TextToImageTab> createState() => _TextToImageTabState();
}

class _TextToImageTabState extends State<_TextToImageTab> {
  final TextEditingController _promptController = TextEditingController();
  String _aspectRatio = '1:1';
  String _resolution = '1K';
  String _outputFormat = 'png';

  static const String _promptStreetHipHop =
      'Street dance / hip-hop photography: powerful freeze pose, baggy streetwear, concrete or studio with colored gel lights, breakdance or freestyle energy, dynamic low angle, sweat and motion, urban night city bokeh, high contrast, cinematic 4K, vertical poster composition.';
  static const String _promptClassicalDance =
      'Classical dance scene: flowing silk sleeves or long dress, restrained elegant posture, traditional or neoclassical stage, soft golden spotlight, misty backdrop, poetic slow motion feel, fine fabric texture, museum-quality lighting, ultra detailed horizontal wide frame.';
  static const String _promptBallet =
      'Professional ballet on stage: pointe shoes, tutu, arabesque or grand jeté mid-air, mirrored barre hints, theatre proscenium arch, warm stage lights and cool shadows, powder and rosin dust in the air, graceful lines, crisp focus, 4K cinematic wide banner.';

  void _applyExample(String prompt, String aspectRatio) {
    setState(() {
      _promptController.text = prompt;
      _aspectRatio = aspectRatio;
    });
  }

  Widget _exampleCard({
    required String assetPath,
    required String title,
    required String prompt,
    required String aspectRatio,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _applyExample(prompt, aspectRatio),
          child: SizedBox(
            width: 132,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: Colors.grey.shade300,
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade600),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        aspectRatio,
                        style: TextStyle(fontSize: 10, color: scheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _clearImageForm() {
    _promptController.clear();
    setState(() {
      _aspectRatio = '1:1';
      _resolution = '1K';
      _outputFormat = 'png';
    });
  }

  Future<void> _generate() async {
    final String prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a prompt first')),
      );
      return;
    }
    final int imageBalance = await WalletBalanceStore.getBalance();
    if (imageBalance < WalletEconomy.imageGenerationCost) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建生图需要${WalletEconomy.imageGenerationCost} Coins，余额不足'),
        ),
      );
      return;
    }
    final bool agreed = await showMagicAiConsentDialog(context);
    if (!agreed || !mounted) {
      return;
    }
    final String p = prompt;
    final String ar = _aspectRatio;
    final String res = _resolution;
    final String fmt = _outputFormat;
    _clearImageForm();
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext c) => MagicImageGenerationPage(
          prompt: p,
          aspectRatio: ar,
          resolution: res,
          outputFormat: fmt,
        ),
      ),
    );
    if (mounted && ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Record — open the Record tab to view')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick examples', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            'Tap a card to fill the prompt and aspect ratio.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 168,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _exampleCard(
                  assetPath: 'assets/dance_challenge_cover.png',
                  title: 'Street / hip-hop',
                  prompt: _promptStreetHipHop,
                  aspectRatio: '9:16',
                ),
                _exampleCard(
                  assetPath: 'assets/dance_home_hero.png',
                  title: 'Classical',
                  prompt: _promptClassicalDance,
                  aspectRatio: '16:9',
                ),
                _exampleCard(
                  assetPath: 'assets/dance_message_banner.png',
                  title: 'Ballet',
                  prompt: _promptBallet,
                  aspectRatio: '16:9',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Prompt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _promptController,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Describe the image you want…',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _aspectRatio,
                  decoration: const InputDecoration(
                    labelText: 'Aspect ratio',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '1:1', child: Text('1 : 1')),
                    DropdownMenuItem(value: '3:2', child: Text('3 : 2')),
                    DropdownMenuItem(value: '2:3', child: Text('2 : 3')),
                    DropdownMenuItem(value: '3:4', child: Text('3 : 4')),
                    DropdownMenuItem(value: '4:3', child: Text('4 : 3')),
                    DropdownMenuItem(value: '16:9', child: Text('16 : 9')),
                    DropdownMenuItem(value: '9:16', child: Text('9 : 16')),
                  ],
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() {
                        _aspectRatio = v;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _resolution,
                  decoration: const InputDecoration(
                    labelText: 'Resolution',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '1K', child: Text('1K')),
                    DropdownMenuItem(value: '2K', child: Text('2K')),
                  ],
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() {
                        _resolution = v;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _outputFormat,
            decoration: const InputDecoration(
              labelText: 'Output format',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'png', child: Text('PNG')),
              DropdownMenuItem(value: 'jpeg', child: Text('JPEG')),
            ],
            onChanged: (String? v) {
              if (v != null) {
                setState(() {
                  _outputFormat = v;
                });
              }
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _generate,
              child: const Text('Generate image'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageToVideoTab extends StatefulWidget {
  const _ImageToVideoTab();

  @override
  State<_ImageToVideoTab> createState() => _ImageToVideoTabState();
}

class _ImageToVideoTabState extends State<_ImageToVideoTab> {
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedFrame;
  String _aspectRatio = 'landscape';
  String _nFrames = '10';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickFrameImage() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (file == null) {
      return;
    }
    setState(() {
      _pickedFrame = file;
    });
  }

  void _clearVideoForm() {
    _promptController.clear();
    setState(() {
      _pickedFrame = null;
      _aspectRatio = 'landscape';
      _nFrames = '10';
    });
  }

  Future<void> _generate() async {
    final String prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe the motion first')),
      );
      return;
    }
    if (_pickedFrame == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a first-frame image')),
      );
      return;
    }
    final int videoBalance = await WalletBalanceStore.getBalance();
    if (videoBalance < WalletEconomy.videoGenerationCost) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建视频需要${WalletEconomy.videoGenerationCost} Coins，余额不足'),
        ),
      );
      return;
    }
    final bool agreed = await showMagicAiConsentDialog(context);
    if (!agreed || !mounted) {
      return;
    }
    final String p = prompt;
    final String localPath = _pickedFrame!.path;
    final String ar = _aspectRatio;
    final String nf = _nFrames;
    _clearVideoForm();
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext c) => MagicVideoGenerationPage(
          prompt: p,
          localFrameImagePath: localPath,
          aspectRatio: ar,
          nFrames: nf,
        ),
      ),
    );
    if (mounted && ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Record — open the Record tab to view')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('First frame', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            'Choose one photo from your library as the first frame. It will be uploaded to get a link (max 10 MB).',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Uploaded images are used only for this generation and are not kept long-term on the server.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedFrame == null
                      ? Icon(Icons.add_photo_alternate_outlined, size: 56, color: Colors.grey.shade400)
                      : Image.file(
                          File(_pickedFrame!.path),
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickFrameImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_pickedFrame == null ? 'Choose from library' : 'Choose again'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Motion / camera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _promptController,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Describe how the scene should move…',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _aspectRatio,
                  decoration: const InputDecoration(
                    labelText: 'Aspect ratio',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'landscape', child: Text('Landscape')),
                    DropdownMenuItem(value: 'portrait', child: Text('Portrait')),
                  ],
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() {
                        _aspectRatio = v;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _nFrames,
                  decoration: const InputDecoration(
                    labelText: 'Frames',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '10', child: Text('10')),
                    DropdownMenuItem(value: '15', child: Text('15')),
                  ],
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() {
                        _nFrames = v;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _generate,
              child: const Text('Generate video'),
            ),
          ),
        ],
      ),
    );
  }
}
