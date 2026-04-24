import '../common/release_result.dart';
import 'scheduled_post.dart';
import 'scheduled_post_filters.dart';

abstract class ScheduledPostRepository {
  Future<ReleaseResult<List<ScheduledPost>>> listScheduledPosts(
    String workspaceId,
  );

  Future<ReleaseResult<ScheduledPost?>> getScheduledPost(String postId);

  Future<ReleaseResult<ScheduledPost>> saveScheduledPost(ScheduledPost post);

  Future<ReleaseResult<void>> deleteScheduledPost(String postId);

  Future<ReleaseResult<List<ScheduledPost>>> searchScheduledPosts(
    String workspaceId,
    String query,
    ScheduledPostFilters filters,
  );
}
