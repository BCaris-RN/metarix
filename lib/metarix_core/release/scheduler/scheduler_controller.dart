import 'package:flutter/foundation.dart';

import '../common/release_result.dart';
import '../publishing/publish_status.dart';
import 'publish_target.dart';
import 'scheduled_post.dart';
import 'scheduled_post_filters.dart';
import 'scheduler_service.dart';

class SchedulerController extends ChangeNotifier {
  SchedulerController(this._service);

  final SchedulerService _service;

  List<ScheduledPost> _posts = const <ScheduledPost>[];
  ScheduledPost? _selectedPost;
  List<ScheduledPost> _upcomingPosts = const <ScheduledPost>[];
  bool _loading = false;
  String? _errorMessage;
  ScheduledPostFilters _filters = const ScheduledPostFilters();
  String? _workspaceId;

  List<ScheduledPost> get posts => _posts;
  ScheduledPost? get selectedPost => _selectedPost;
  List<ScheduledPost> get upcomingPosts => _upcomingPosts;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  ScheduledPostFilters get filters => _filters;

  Future<void> loadPosts(String workspaceId) async {
    _workspaceId = workspaceId;
    _loading = true;
    notifyListeners();
    final result = await _service.listUpcoming(workspaceId);
    _applyResult(result);
    _upcomingPosts = _posts.where((post) => post.status == PublishStatus.scheduled).toList(growable: false);
    _loading = false;
    notifyListeners();
  }

  Future<void> createDraft({
    required String workspaceId,
    required List<String> contentAssetIds,
    required List<PublishTarget> targets,
    required String scheduledAtIso,
    required String timezone,
    required String createdByUserId,
  }) async {
    final result = await _service.createDraft(
      workspaceId: workspaceId,
      contentAssetIds: contentAssetIds,
      targets: targets,
      scheduledAtIso: scheduledAtIso,
      timezone: timezone,
      createdByUserId: createdByUserId,
    );
    if (result.success) {
      await loadPosts(workspaceId);
      _selectedPost = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to create draft.';
      notifyListeners();
    }
  }

  Future<void> approveDraft({
    required String postId,
    required String approvedByUserId,
  }) async {
    final result = await _service.approveDraft(
      postId: postId,
      approvedByUserId: approvedByUserId,
    );
    _applySingleResult(result);
  }

  Future<void> scheduleApprovedPost(String postId) async {
    final result = await _service.scheduleApprovedPost(postId);
    _applySingleResult(result);
  }

  Future<void> cancelScheduledPost(String postId, String reason) async {
    final result = await _service.cancelScheduledPost(postId, reason);
    _applySingleResult(result);
  }

  Future<void> searchScheduledPosts() async {
    final workspaceId = _workspaceId;
    if (workspaceId == null) {
      _errorMessage = 'Workspace not loaded.';
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    final result = await _service.searchScheduledPosts(
      workspaceId,
      _filters.query,
      _filters,
    );
    _applyResult(result);
    _loading = false;
    notifyListeners();
  }

  Future<void> updateFilters(ScheduledPostFilters filters) async {
    _filters = filters;
    await searchScheduledPosts();
  }

  void selectPost(ScheduledPost? post) {
    _selectedPost = post;
    notifyListeners();
  }

  void _applyResult(ReleaseResult<List<ScheduledPost>> result) {
    if (result.success) {
      _posts = result.value ?? const <ScheduledPost>[];
      _upcomingPosts = _posts.where((post) => post.status == PublishStatus.scheduled).toList(growable: false);
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to load scheduled posts.';
    }
  }

  void _applySingleResult(ReleaseResult<ScheduledPost> result) {
    if (result.success && result.value != null) {
      final updated = result.value!;
      final index = _posts.indexWhere((entry) => entry.id == updated.id);
      if (index >= 0) {
        _posts = [
          ..._posts.sublist(0, index),
          updated,
          ..._posts.sublist(index + 1),
        ];
      } else {
        _posts = [..._posts, updated];
      }
      _upcomingPosts = _posts.where((post) => post.status == PublishStatus.scheduled).toList(growable: false);
      _selectedPost = updated;
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to update scheduled post.';
    }
    notifyListeners();
  }
}
