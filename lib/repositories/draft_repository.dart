import '../features/workflow/domain/workflow_models.dart';

abstract interface class DraftRepository {
  Future<PostDraft> createDraft(PostDraft draft);

  Future<List<PostDraft>> listDrafts();

  Future<PostDraft> updateDraft(PostDraft draft);
}
