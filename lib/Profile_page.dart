import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import 'About_page.dart';
import 'Editor_page.dart';
import 'Feedback_page.dart';
import 'Privacy_Policy_page.dart';
import 'User_Agreement_page.dart';
import 'user_profile_store.dart';
import 'wallet_balance_store.dart';
import 'wallet_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfileData _profile = const UserProfileData(
    nickname: UserProfileStore.defaultNickname,
    signature: UserProfileStore.defaultSignature,
    avatarRelativePath: null,
  );
  int _walletBalance = 0;
  final NumberFormat _walletNumberFormat = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    _refreshProfile();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final int balance = await WalletBalanceStore.getBalance();
    if (!mounted) {
      return;
    }
    setState(() {
      _walletBalance = balance;
    });
  }

  Future<void> _openWalletDetail() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const WalletDetailPage()),
    );
    await _loadWalletBalance();
  }

  Future<void> _refreshProfile() async {
    final UserProfileData data = await UserProfileStore.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = data;
    });
  }

  Future<void> _openFeedback() async {
    final bool? submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const FeedbackPage()),
    );
    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted successfully.')),
      );
    }
  }

  Future<void> _openEditor() async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const EditorPage()),
    );
    if (saved == true) {
      await _refreshProfile();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    }
  }

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    final bool available = await inAppReview.isAvailable();
    if (available) {
      await inAppReview.requestReview();
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating is not available right now.')),
    );
  }

  Future<void> _shareApp() async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Create stories with Rugos.',
      ),
    );
  }

  Future<ImageProvider<Object>> _avatarProvider() async {
    if (_profile.avatarRelativePath != null) {
      final avatarFile = await UserProfileStore.avatarFileFromRelativePath(_profile.avatarRelativePath!);
      if (await avatarFile.exists()) {
        return FileImage(avatarFile);
      }
    }
    return const AssetImage('assets/user_default.png');
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Column(children: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: <Widget>[
                    FutureBuilder<ImageProvider<Object>>(
                      future: _avatarProvider(),
                      builder: (BuildContext context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
                        final ImageProvider<Object> provider =
                            snapshot.data ?? const AssetImage('assets/user_default.png');
                        return CircleAvatar(radius: 32, backgroundImage: provider);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _profile.nickname,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profile.signature,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _sectionTitle('WALLET'),
              _card([
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _openWalletDetail,
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.account_balance_wallet_rounded, size: 22, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Wallet',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          _walletNumberFormat.format(_walletBalance),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.black45),
                      ],
                    ),
                  ),
                ),
              ]),
              _sectionTitle('APP'),
              _card([
                _menuItem(icon: Icons.star_rate_rounded, text: 'Rate App', onTap: _rateApp),
                const Divider(height: 1),
                _menuItem(icon: Icons.feedback_rounded, text: 'Feedback', onTap: _openFeedback),
                const Divider(height: 1),
                _menuItem(icon: Icons.share_rounded, text: 'Share App', onTap: _shareApp),
              ]),
              _sectionTitle('PROFILE'),
              _card([
                _menuItem(icon: Icons.edit_rounded, text: 'Edit Information', onTap: _openEditor),
              ]),
              _sectionTitle('LEGAL'),
              _card([
                _menuItem(
                  icon: Icons.privacy_tip_rounded,
                  text: 'Privacy Policy',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.rule_rounded,
                  text: 'User Agreement',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const UserAgreementPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                _menuItem(
                  icon: Icons.info_rounded,
                  text: 'About Us',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const AboutPage()),
                    );
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
