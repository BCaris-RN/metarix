import '../../accounts/connected_social_account.dart';
import '../../accounts/social_platform.dart';
import '../../common/release_result.dart';
import '../publish_job.dart';
import '../publish_request.dart';
import '../social_publisher.dart';

class DemoSocialPublisher implements SocialPublisher {
  const DemoSocialPublisher();

  @override
  SocialPlatform get platform => SocialPlatform.demo;

  @override
  Future<ReleaseResult<void>> checkStatus(PublishJob job) async {
    return ReleaseResult<void>.success(null);
  }

  @override
  Future<ReleaseResult<ConnectedSocialAccount>> refreshConnection(
    ConnectedSocialAccount account,
  ) async {
    return ReleaseResult<ConnectedSocialAccount>.success(
      account.copyWith(
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
        lastHealthCheckIso: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  @override
  Future<ReleaseResult<void>> uploadMedia(PublishRequest request) async {
    if (request.dryRun) {
      return ReleaseResult<void>.success(null);
    }
    return ReleaseResult<void>.success(null);
  }

  @override
  Future<ReleaseResult<void>> validate(PublishRequest request) async {
    if (request.contentAssets.isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'publish.validation_failed',
        userMessage: 'No content assets provided.',
      );
    }
    return ReleaseResult<void>.success(null);
  }

  @override
  Future<ReleaseResult<String>> publish(PublishRequest request) async {
    final postId = 'demo-post-${request.scheduledPostId}-${request.target.id}';
    return ReleaseResult<String>.success(postId);
  }
}
