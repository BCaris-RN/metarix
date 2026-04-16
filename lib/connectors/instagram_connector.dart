import '../features/shared/domain/core_models.dart';
import 'base_connector.dart';

class InstagramConnector extends PolicyBackedConnector {
  InstagramConnector({
    required super.canSchedule,
    required super.canPublish,
    required super.canFetchAnalytics,
  }) : super(
          channel: SocialChannel.instagram,
          analyticsPayloadBuilder: (reportPeriodId) => {
            'reportPeriodId': reportPeriodId,
            'followers': 18400,
            'reach': 62000,
            'impressions': 138000,
            'engagement': 9100,
            'clicks': 590,
            'views': 22400,
            'shares': 410,
            'comments': 280,
            'sentiment_score': 0.68,
            'response_time': 4.2,
          },
        );
}
