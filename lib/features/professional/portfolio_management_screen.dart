import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sevix_worker/features/professional/professional_models.dart';
import 'package:sevix_worker/features/professional/professional_providers.dart';

class PortfolioManagementScreen extends ConsumerWidget {
  const PortfolioManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio Manager')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPortfolioItem(context, ref),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add Project'),
      ),
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Failed to load portfolio')),
        data: (items) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: item.imagePath.isEmpty
                          ? Container(
                              color: const Color(0xFFE2E8F0),
                              child: const Center(
                                child: Icon(Icons.image_outlined, size: 32),
                              ),
                            )
                          : Image.file(
                              File(item.imagePath),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _chip(item.category),
                              _chip(item.verified ? 'Verified' : 'Pending'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }

  Future<void> _addPortfolioItem(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (file == null) {
      return;
    }

    final captionController = TextEditingController();
    final categoryController = TextEditingController(text: 'Plumbing');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Project Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: captionController,
                decoration: const InputDecoration(labelText: 'Caption'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Service Category',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await ref
          .read(portfolioProvider.notifier)
          .addItem(
            PortfolioItem(
              id: 'pf-${DateTime.now().millisecondsSinceEpoch}',
              imagePath: file.path,
              caption: captionController.text.trim().isEmpty
                  ? 'Untitled Project'
                  : captionController.text.trim(),
              category: categoryController.text.trim().isEmpty
                  ? 'General'
                  : categoryController.text.trim(),
              verified: false,
            ),
          );
    }

    captionController.dispose();
    categoryController.dispose();
  }
}
