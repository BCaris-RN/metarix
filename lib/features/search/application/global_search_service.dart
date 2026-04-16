import '../../../data/local_metarix_gateway.dart';
import '../domain/search_result_record.dart';

class GlobalSearchService {
  const GlobalSearchService(this._gateway);

  final LocalMetarixGateway _gateway;

  List<SearchResultRecord> search(String query) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) {
      return const [];
    }

    bool matches(String value) => value.toLowerCase().contains(term);

    return [
      ..._gateway.snapshot.campaigns
          .where((campaign) => matches(campaign.name) || matches(campaign.summary))
          .map(
            (campaign) => SearchResultRecord(
              id: 'campaign-${campaign.id}',
              type: SearchObjectType.campaign,
              title: campaign.name,
              subtitle: campaign.summary,
              targetSurface: 1,
              objectId: campaign.id,
            ),
          ),
      ..._gateway.snapshot.drafts
          .where((draft) => matches(draft.title) || matches(draft.copy))
          .map(
            (draft) => SearchResultRecord(
              id: 'draft-${draft.id}',
              type: SearchObjectType.draft,
              title: draft.title,
              subtitle: draft.copy,
              targetSurface: 2,
              objectId: draft.id,
            ),
          ),
      ..._gateway.snapshot.assetRecords
          .where((asset) => matches(asset.name) || asset.tags.any(matches))
          .map(
            (asset) => SearchResultRecord(
              id: 'asset-${asset.id}',
              type: SearchObjectType.asset,
              title: asset.name,
              subtitle: asset.tags.join(', '),
              targetSurface: 6,
              objectId: asset.id,
            ),
          ),
      ..._gateway.snapshot.reportPeriods
          .where((period) => matches(period.label))
          .map(
            (period) => SearchResultRecord(
              id: 'report-${period.id}',
              type: SearchObjectType.report,
              title: period.label,
              subtitle: 'Report period',
              targetSurface: 4,
              objectId: period.id,
            ),
          ),
      ..._gateway.snapshot.listeningQueries
          .where((queryRecord) =>
              matches(queryRecord.name) || matches(queryRecord.queryText))
          .map(
            (queryRecord) => SearchResultRecord(
              id: 'query-${queryRecord.id}',
              type: SearchObjectType.listeningQuery,
              title: queryRecord.name,
              subtitle: queryRecord.queryText,
              targetSurface: 5,
              objectId: queryRecord.id,
            ),
          ),
      ..._gateway.snapshot.activityEvents
          .where(
            (event) =>
                matches(event.objectLabel) ||
                matches(event.reason) ||
                matches(event.actorName),
          )
          .map(
            (event) => SearchResultRecord(
              id: 'activity-${event.id}',
              type: SearchObjectType.activityEvent,
              title: event.objectLabel,
              subtitle: event.reason,
              targetSurface: 7,
              objectId: event.objectId,
            ),
          ),
    ];
  }
}
