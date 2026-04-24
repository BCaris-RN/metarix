import '../accounts/connected_social_account.dart';
import '../accounts/social_platform.dart';
import '../common/release_result.dart';
import '../scheduler/publish_target.dart';
import 'publish_job.dart';
import 'publish_request.dart';

abstract class SocialPublisher {
  SocialPlatform get platform;

  Future<ReleaseResult<void>> validate(PublishRequest request);
  Future<ReleaseResult<void>> uploadMedia(PublishRequest request);
  Future<ReleaseResult<String>> publish(PublishRequest request);
  Future<ReleaseResult<void>> checkStatus(PublishJob job);
  Future<ReleaseResult<ConnectedSocialAccount>> refreshConnection(
    ConnectedSocialAccount account,
  );
}
