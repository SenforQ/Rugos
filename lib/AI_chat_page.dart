import 'package:flutter/material.dart';

import 'dismiss_keyboard_on_tap.dart';
import 'teacher_chat_session_store.dart';
import 'dart:io';

import 'generate_chat_service.dart';
import 'wallet_balance_store.dart';
import 'wallet_economy.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({
    super.key,
    required this.teacherName,
    required this.danceType,
    required this.backgroundIntro,
    required this.imagePath,
    required this.presetQuestions,
    this.isAssetImage = true,
    this.avatarRelativePathForStorage,
  });

  final String teacherName;
  final String danceType;
  final String backgroundIntro;
  final String imagePath;
  final List<String> presetQuestions;
  final bool isAssetImage;
  final String? avatarRelativePathForStorage;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GenerateChatService _service = GenerateChatService();

  final List<_ChatMessage> _messages = <_ChatMessage>[];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        role: 'assistant',
        text: 'Hi! I am ${widget.teacherName}. Tell me your dance goal and I will coach you.',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    await _sendMessage(_controller.text.trim());
  }

  Future<void> _persistSessionAfterReply(String lastSnippet) async {
    final String imageRef;
    final bool imageIsAsset;
    if (widget.avatarRelativePathForStorage != null && widget.avatarRelativePathForStorage!.trim().isNotEmpty) {
      imageRef = widget.avatarRelativePathForStorage!.trim();
      imageIsAsset = false;
    } else {
      imageRef = widget.imagePath;
      imageIsAsset = widget.isAssetImage;
    }
    final TeacherChatSession session = TeacherChatSession(
      teacherName: widget.teacherName,
      danceType: widget.danceType,
      backgroundIntro: widget.backgroundIntro,
      imageRef: imageRef,
      imageIsAsset: imageIsAsset,
      presetQuestions: widget.presetQuestions,
      lastSnippet: lastSnippet,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await TeacherChatSessionStore().upsertSession(session);
  }

  Future<void> _sendMessage(String userText) async {
    if (userText.isEmpty || _sending) {
      return;
    }
    final int balance = await WalletBalanceStore.getBalance();
    if (balance < WalletEconomy.chatPerMessageCost) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('每次对话需要${WalletEconomy.chatPerMessageCost} Coins，当前余额不足'),
        ),
      );
      return;
    }

    _controller.clear();
    setState(() {
      _sending = true;
      _messages.add(_ChatMessage(role: 'user', text: userText));
    });
    _scrollToBottom();

    try {
      final List<Map<String, String>> history = _messages
          .sublist(0, _messages.length - 1)
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .map((m) => <String, String>{'role': m.role, 'content': m.text})
          .toList();
      final String reply = await _service.chat(
        teacherName: widget.teacherName,
        danceType: widget.danceType,
        backgroundIntro: widget.backgroundIntro,
        history: history,
        userMessage: userText,
      );
      if (!mounted) {
        return;
      }
      final bool spent = await WalletBalanceStore.deductCoins(WalletEconomy.chatPerMessageCost);
      if (!spent) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('扣费失败，本次回复仍已显示，请稍后在钱包中确认余额')),
        );
      }
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', text: reply));
      });
      await _persistSessionAfterReply(reply);
    } catch (e) {
      if (!mounted) {
        return;
      }
      const String errText = 'Sorry, I cannot reply right now. Please try again.';
      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            text: errText,
          ),
        );
      });
      await _persistSessionAfterReply(errText);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the chat service. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teacherName} · ${widget.danceType}'),
      ),
      body: DismissKeyboardOnTap(
        child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.isAssetImage
                      ? Image.asset(widget.imagePath, width: 52, height: 52, fit: BoxFit.cover)
                      : Image.file(File(widget.imagePath), width: 52, height: 52, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.backgroundIntro,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final _ChatMessage msg = _messages[index];
                final bool isUser = msg.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: isUser ? primary.withValues(alpha: 0.16) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Text(msg.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          if (widget.presetQuestions.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick questions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < widget.presetQuestions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          ActionChip(
                            label: SizedBox(
                              width: 220,
                              child: Text(
                                widget.presetQuestions[i],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, height: 1.25),
                              ),
                            ),
                            onPressed: _sending
                                ? null
                                : () {
                                    _sendMessage(widget.presetQuestions[i]);
                                  },
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ask for dance coaching in English...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.text,
  });

  final String role;
  final String text;
}
