import '../accounts/connected_social_account.dart';
import '../content/content_asset.dart';
import '../scheduler/publish_target.dart';

class PublishRequest {
  const PublishRequest({
    required this.workspaceId,
    required this.scheduledPostId,
    required this.contentAssets,
    required this.connectedAccount,
    required this.target,
    required this.metadata,
    required this.dryRun,
  });

  final String workspaceId;
  final String scheduledPostId;
  final List<ContentAsset> contentAssets;
  final ConnectedSocialAccount connectedAccount;
  final PublishTarget target;
  final Map<String, Object?> metadata;
  final bool dryRun;
}
