import 'package:flutter/material.dart';

import 'User_Agreement_page.dart';

Future<bool> showMagicAiConsentDialog(BuildContext context) async {
  final bool? ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return const _MagicAiConsentDialogContent();
    },
  );
  return ok == true;
}

class _MagicAiConsentDialogContent extends StatefulWidget {
  const _MagicAiConsentDialogContent();

  @override
  State<_MagicAiConsentDialogContent> createState() => _MagicAiConsentDialogContentState();
}

class _MagicAiConsentDialogContentState extends State<_MagicAiConsentDialogContent> {
  bool _agreeUserAgreement = false;
  bool _agreeContentPolicy = false;

  bool get _canSubmit => _agreeUserAgreement && _agreeContentPolicy;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel_rounded, color: primary, size: 26),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Generation notice',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before you use text-to-image, image-to-video, and other generation features, please confirm that you understand and agree to the following:',
                        style: TextStyle(fontSize: 14, height: 1.45, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• You must follow the User Agreement and platform rules; tap below to read the full text.\n'
                        '• You must not generate, share, or request content that is violent, sexual, gambling-related, terrorist, hateful, illegal, infringing, or otherwise harmful, including material inappropriate for minors.\n'
                        '• Generated content is for your personal lawful use only; you are responsible for how you use it.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade900),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext c) => const UserAgreementPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Open full User Agreement'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _agreeUserAgreement,
                onChanged: (bool? v) {
                  setState(() {
                    _agreeUserAgreement = v ?? false;
                  });
                },
                title: const Text('I have read and agree to the User Agreement', style: TextStyle(fontSize: 13)),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _agreeContentPolicy,
                onChanged: (bool? v) {
                  setState(() {
                    _agreeContentPolicy = v ?? false;
                  });
                },
                title: const Text(
                  'I will not create violent, sexual, illegal, infringing, or otherwise harmful images or videos',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _canSubmit
                          ? () {
                              Navigator.of(context).pop(true);
                            }
                          : null,
                      child: const Text('Agree and continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
