/// Video Service
/// Handles communication with the backend video conversion API
///
/// Usage:
///   final service = VideoService('http://localhost:3000');
///   final videos = await service.getConvertedVideos();
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class VideoService {
  final String baseUrl;
  final http.Client _httpClient;

  VideoService(this.baseUrl, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Fetch all converted videos from backend
  /// Returns list of VideoInfo objects with URLs
  Future<List<VideoInfo>> getConvertedVideos() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/videos'))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Failed to fetch videos'),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final videos = (json['videos'] as List<dynamic>)
            .map((v) => VideoInfo.fromJson(v))
            .toList();
        debugPrint('✅ Fetched ${videos.length} converted videos');
        return videos;
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching videos: $e');
      rethrow;
    }
  }

  /// Get metadata for a specific video
  Future<VideoInfo> getVideoInfo(String videoId) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/videos/$videoId/info'))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Failed to fetch video info'),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return VideoInfo.fromJson(json);
      } else {
        throw Exception('Failed to load video info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching video info: $e');
      rethrow;
    }
  }

  /// Get direct download/stream URL for a video
  String getVideoUrl(String videoId) {
    return '$baseUrl/videos/$videoId';
  }

  /// Check if backend server is reachable
  Future<bool> healthCheck() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/health'))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Server not responding'),
          );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return false;
    }
  }
}

/// Model for video metadata from backend
class VideoInfo {
  final String id;
  final String fileName;
  final String url;
  final int fileSize;
  final int fileSizeMB;
  final DateTime created;

  VideoInfo({
    required this.id,
    required this.fileName,
    required this.url,
    required this.fileSize,
    required this.fileSizeMB,
    required this.created,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['videoId'] ?? json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      url: json['url'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      fileSizeMB: json['fileSizeMB'] ?? 0,
      created: json['created'] != null
          ? DateTime.parse(json['created'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'url': url,
      'fileSize': fileSize,
      'fileSizeMB': fileSizeMB,
      'created': created.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'VideoInfo(id: $id, fileName: $fileName, size: ${fileSizeMB}MB)';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
