import '../features/listening/domain/listening_models.dart';

abstract interface class ListeningQueryRepository {
  Future<ListeningSnapshot> loadListeningSnapshot();

  Future<ListeningQuery> saveListeningQuery(ListeningQuery query);

  Future<Mention> updateMention(Mention mention);
}
