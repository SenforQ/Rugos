import 'package:flutter/material.dart';

class DancePage extends StatelessWidget {
  const DancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choreography Lab', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Build your dance story with style, rhythm and emotion.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('Hip-Hop')),
                Chip(label: Text('Contemporary')),
                Chip(label: Text('Jazz Funk')),
                Chip(label: Text('K-Pop')),
                Chip(label: Text('House')),
                Chip(label: Text('Waacking')),
              ],
            ),
            const SizedBox(height: 16),
            _ideaCard(context, 'Midnight Freestyle', '96 BPM', '01:20', 'Intermediate'),
            const SizedBox(height: 10),
            _ideaCard(context, 'Soft Wave Story', '78 BPM', '00:52', 'Beginner'),
            const SizedBox(height: 10),
            _ideaCard(context, 'Sharp Groove Combo', '124 BPM', '01:08', 'Advanced'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_rounded),
                label: const Text('Create New Choreography'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ideaCard(BuildContext context, String title, String bpm, String duration, String level) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              _metaTag(primary, bpm),
              const SizedBox(width: 8),
              _metaTag(primary, duration),
              const SizedBox(width: 8),
              _metaTag(primary, level),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaTag(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
