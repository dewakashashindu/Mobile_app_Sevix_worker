import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PendingCompletionPayload {
  final String jobId;
  final String completionPhotoPath;
  final String signatureBase64;
  final int createdAtMillis;

  const PendingCompletionPayload({
    required this.jobId,
    required this.completionPhotoPath,
    required this.signatureBase64,
    required this.createdAtMillis,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'completionPhotoPath': completionPhotoPath,
      'signatureBase64': signatureBase64,
      'createdAtMillis': createdAtMillis,
    };
  }

  factory PendingCompletionPayload.fromJson(Map<String, dynamic> json) {
    return PendingCompletionPayload(
      jobId: (json['jobId'] as String?) ?? '',
      completionPhotoPath: (json['completionPhotoPath'] as String?) ?? '',
      signatureBase64: (json['signatureBase64'] as String?) ?? '',
      createdAtMillis: (json['createdAtMillis'] as int?) ?? 0,
    );
  }
}

class OfflineCompletionBuffer {
  static const String _storageKey = 'pending_job_completions_v1';

  static Future<List<PendingCompletionPayload>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PendingCompletionPayload.fromJson)
          .where(
            (item) =>
                item.jobId.isNotEmpty &&
                item.completionPhotoPath.isNotEmpty &&
                item.signatureBase64.isNotEmpty,
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Future<void> enqueue(PendingCompletionPayload payload) async {
    final existing = await loadAll();
    final updated = [...existing, payload];
    await replaceAll(updated);
  }

  static Future<void> replaceAll(List<PendingCompletionPayload> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
