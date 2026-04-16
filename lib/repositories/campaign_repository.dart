import '../features/planning/domain/planning_models.dart';

abstract interface class CampaignRepository {
  Future<Campaign> createCampaign(Campaign campaign);

  Future<List<Campaign>> listCampaigns(String brandId);

  Future<void> saveEvergreenItem(EvergreenContentItem item);

  Future<List<EvergreenContentItem>> listEvergreenItems(String brandId);
}
