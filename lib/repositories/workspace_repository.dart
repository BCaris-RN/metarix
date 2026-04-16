import '../features/admin/domain/admin_models.dart';
import '../features/shared/domain/core_models.dart';

abstract interface class WorkspaceRepository {
  Future<Workspace> createWorkspace(Workspace workspace);

  Future<Workspace?> loadWorkspace(String workspaceId);

  Future<List<Brand>> listBrands(String workspaceId);

  Future<Brand> saveBrand(Brand brand);

  Future<List<AppUser>> listUsers();

  Future<List<WorkspaceMembership>> listMemberships(String workspaceId);

  Future<WorkspaceMembership> saveMembership(WorkspaceMembership membership);
}
