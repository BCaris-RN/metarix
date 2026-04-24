import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/release_result.dart';
import 'scheduled_post.dart';
import 'scheduled_post_filters.dart';
import 'scheduled_post_repository.dart';

class LocalScheduledPostRepository implements ScheduledPostRepository {
  LocalScheduledPostRepository._(this._preferences);

  static const String _postsKey = 'metarix.release.scheduler.posts.v1';

  final SharedPreferences _preferences;

  static Future<LocalScheduledPostRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalScheduledPostRepository._(preferences);
  }

  @override
  Future<ReleaseResult<List<ScheduledPost>>> listScheduledPosts(
    String workspaceId,
  ) async {
    try {
      return ReleaseResult<List<ScheduledPost>>.success(
        _load()
            .where((post) => post.workspaceId == workspaceId)
            .toList(growable: false),
      );
    } catch (error) {
      return ReleaseResult<List<ScheduledPost>>.failure(
        errorCode: 'scheduler.storage_failed',
        userMessage: 'Unable to load scheduled posts.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ScheduledPost?>> getScheduledPost(String postId) async {
    try {
      for (final post in _load()) {
        if (post.id == postId) {
          return ReleaseResult<ScheduledPost?>.success(post);
        }
      }
      return ReleaseResult<ScheduledPost?>.success(null);
    } catch (error) {
      return ReleaseResult<ScheduledPost?>.failure(
        errorCode: 'scheduler.storage_failed',
        userMessage: 'Unable to load scheduled post.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ScheduledPost>> saveScheduledPost(
    ScheduledPost post,
  ) async {
    try {
      final items = _load();
      final index = items.indexWhere((entry) => entry.id == post.id);
      if (index >= 0) {
        items[index] = post;
      } else {
        items.add(post);
      }
      await _persist(items);
      return ReleaseResult<ScheduledPost>.success(post);
    } catch (error) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.storage_failed',
        userMessage: 'Unable to save scheduled post.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<void>> deleteScheduledPost(String postId) async {
    try {
      final items = _load()..removeWhere((entry) => entry.id == postId);
      await _persist(items);
      return ReleaseResult<void>.success(null);
    } catch (error) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.storage_failed',
        userMessage: 'Unable to delete scheduled post.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<List<ScheduledPost>>> searchScheduledPosts(
    String workspaceId,
    String query,
    ScheduledPostFilters filters,
  ) async {
    final normalized = query.trim().toLowerCase();
    final posts = await listScheduledPosts(workspaceId);
    if (!posts.success) {
      return ReleaseResult<List<ScheduledPost>>.failure(
        errorCode: posts.errorCode,
        userMessage: posts.userMessage,
        technicalMessage: posts.technicalMessage,
        retryable: posts.retryable,
      );
    }
    final filtered = posts.value!
        .where(
          (post) =>
              (normalized.isEmpty ||
                  post.title?.toLowerCase().contains(normalized) == true ||
                  post.caption?.toLowerCase().contains(normalized) == true ||
                  post.targets.any(
                    (target) =>
                        target.targetDisplayName.toLowerCase().contains(normalized) ||
                        target.connectedAccountId.toLowerCase().contains(normalized),
                  )) &&
              (filters.status == null || post.status == filters.status),
        )
        .toList(growable: false);
    return ReleaseResult<List<ScheduledPost>>.success(filtered);
  }

  List<ScheduledPost> _load() {
    final encoded = _preferences.getString(_postsKey);
    if (encoded == null || encoded.isEmpty) {
      return <ScheduledPost>[];
    }
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => ScheduledPost.fromJson(item))
        .toList(growable: true);
  }

  Future<void> _persist(List<ScheduledPost> items) async {
    await _preferences.setString(
      _postsKey,
      jsonEncode(items.map((entry) => entry.toJson()).toList()),
    );
  }
}
