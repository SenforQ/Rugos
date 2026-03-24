import 'dart:async';

import 'package:flutter/material.dart';

import 'generate_media/generate_media_api_config.dart';
import 'generate_media/generate_media_client.dart';
import 'magic_generation_download.dart';
import 'magic_generation_store.dart';
import 'record_refresh_notifier.dart';
import 'wallet_balance_store.dart';
import 'wallet_economy.dart';

class MagicImageGenerationPage extends StatefulWidget {
  const MagicImageGenerationPage({
    super.key,
    required this.prompt,
    required this.aspectRatio,
    required this.resolution,
    required this.outputFormat,
  });

  final String prompt;
  final String aspectRatio;
  final String resolution;
  final String outputFormat;

  @override
  State<MagicImageGenerationPage> createState() => _MagicImageGenerationPageState();
}

class _MagicImageGenerationPageState extends State<MagicImageGenerationPage> {
  String _phase = 'Sending request…';
  String _taskId = '';
  String _pollState = '';
  MagicGenerationRecord? _current;

  final MagicGenerationStore _store = MagicGenerationStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _run();
    });
  }

  Future<void> _persistCurrent() async {
    final MagicGenerationRecord? c = _current;
    if (c == null) {
      return;
    }
    await _store.upsertRecord(c);
    recordLibraryRefreshSignal.value = recordLibraryRefreshSignal.value + 1;
  }

  Future<void> _run() async {
    final int bal = await WalletBalanceStore.getBalance();
    if (bal < WalletEconomy.imageGenerationCost) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建生图需要${WalletEconomy.imageGenerationCost} Coins，余额不足'),
          ),
        );
        Navigator.of(context).pop(false);
      }
      return;
    }
    final bool deducted = await WalletBalanceStore.deductCoins(WalletEconomy.imageGenerationCost);
    if (!deducted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建生图需要${WalletEconomy.imageGenerationCost} Coins，余额不足'),
          ),
        );
        Navigator.of(context).pop(false);
      }
      return;
    }

    Future<void> refundCoins() async {
      await WalletBalanceStore.addCoins(WalletEconomy.imageGenerationCost);
    }

    final String sessionId = 'gen_${DateTime.now().microsecondsSinceEpoch}';
    final String aspectInfo = '${widget.aspectRatio} · ${widget.resolution} · ${widget.outputFormat}';
    _current = MagicGenerationRecord(
      id: sessionId,
      mediaKind: 'image',
      status: MagicGenerationRecord.statusProcessing,
      taskId: '',
      prompt: widget.prompt,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      aspectInfo: aspectInfo,
      mediaRelativePaths: <String>[],
      lastPollState: 'submitting',
    );
    await _persistCurrent();
    try {
      final GenerateMediaApiClient client = GenerateMediaApiClient(apiKey: kGenerateMediaApiKey);
      final String taskId = await client.createNanoBananaProTask(
        prompt: widget.prompt,
        imageInput: <String>[],
        aspectRatio: widget.aspectRatio,
        resolution: widget.resolution,
        outputFormat: widget.outputFormat,
      );
      if (!mounted) {
        return;
      }
      _taskId = taskId;
      _current = _current!.copyWith(taskId: taskId, lastPollState: 'submitted');
      await _persistCurrent();
      setState(() {
        _phase = 'Queued — please wait…';
      });
      final GenerateMediaTaskDetail done = await client.pollUntilComplete(
        taskId,
        onUpdate: (GenerateMediaTaskDetail d) {
          if (_current != null) {
            _current = _current!.copyWith(lastPollState: d.state);
            unawaited(_persistCurrent());
          }
          if (mounted) {
            setState(() {
              _pollState = d.state;
            });
          }
        },
      );
      final List<String> urls = done.parseResultUrls();
      if (!mounted) {
        return;
      }
      if (urls.isEmpty) {
        await refundCoins();
        _current = _current!.copyWith(
          status: MagicGenerationRecord.statusNoResult,
          lastPollState: 'no_urls',
          failMessage: 'No image URL returned',
        );
        await _persistCurrent();
        setState(() {
          _phase = 'Finished, but no image link was returned.';
        });
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(false);
        }
        return;
      }
      setState(() {
        _phase = 'Saving to your library…';
      });
      final List<String> paths = <String>[];
      for (int i = 0; i < urls.length; i++) {
        final String u = urls[i];
        final String ext = guessImageExtensionFromUrl(u);
        final String rel = await downloadBytesToMagicGenerations(u, forcedExtension: ext);
        paths.add(rel);
      }
      _current = _current!.copyWith(
        status: MagicGenerationRecord.statusSuccess,
        mediaRelativePaths: paths,
        lastPollState: 'success',
        clearFailMessage: true,
      );
      await _persistCurrent();
      if (!mounted) {
        return;
      }
      setState(() {
        _phase = 'Saved ${paths.length} image(s). Open Record to view.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on GenerateMediaApiException catch (e) {
      await refundCoins();
      if (_current != null) {
        _current = _current!.copyWith(
          status: MagicGenerationRecord.statusFailed,
          lastPollState: 'failed',
          failMessage: e.message,
        );
        await _persistCurrent();
      }
      if (mounted) {
        setState(() {
          _phase = 'Failed: ${e.message}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      }
    } catch (e) {
      await refundCoins();
      if (_current != null) {
        _current = _current!.copyWith(
          status: MagicGenerationRecord.statusFailed,
          lastPollState: 'failed',
          failMessage: '$e',
        );
        await _persistCurrent();
      }
      if (mounted) {
        setState(() {
          _phase = 'Failed: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generating image')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 28),
            Text(
              _phase,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (_taskId.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectableText(
                'Job ID: $_taskId',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
            if (_pollState.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Progress: $_pollState',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
