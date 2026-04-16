import '../features/shared/domain/core_models.dart';
import 'base_connector.dart';

class XConnector extends PolicyBackedConnector {
  XConnector({
    required super.canSchedule,
    required super.canPublish,
    required super.canFetchAnalytics,
  }) : super(
          channel: SocialChannel.x,
          analyticsPayloadBuilder: (reportPeriodId) => {
            'reportPeriodId': reportPeriodId,
            'followers': 7600,
            'reach': 21400,
            'impressions': 58000,
            'engagement': 2100,
            'clicks': 190,
            'views': 61000,
            'shares': 155,
            'comments': 88,
            'sentiment_score': 0.58,
            'response_time': 6.5,
          },
        );
}
