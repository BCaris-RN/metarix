import '../features/workflow/domain/workflow_models.dart';

abstract interface class ApprovalRepository {
  Future<ApprovalRecord> createApprovalRecord(ApprovalRecord record);

  Future<List<ApprovalRecord>> listApprovalRecords();
}
