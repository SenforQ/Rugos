import 'dart:io';

import 'package:flutter/material.dart';

import 'local_storage_paths.dart';
import 'my_image_store.dart';

class MyImageDetailPage extends StatelessWidget {
  const MyImageDetailPage({super.key, required this.item});

  final UserDanceImage item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<File?>(
              future: LocalStoragePaths.resolveStoredFile(item.imageRelativePath),
              builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                final File? file = snapshot.data;
                if (file != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(file, width: double.infinity, fit: BoxFit.cover),
                  );
                }
                return Container(
                  height: 220,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.broken_image_outlined, size: 48, color: Colors.black38),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(item.experience, style: const TextStyle(fontSize: 15, height: 1.45)),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Tags', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final String t in item.tags)
                    Chip(
                      label: Text(t),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
