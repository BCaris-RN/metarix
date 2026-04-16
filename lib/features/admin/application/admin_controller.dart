import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../repositories/workspace_repository.dart';
import '../../../services/access_control_service.dart';
import '../domain/admin_models.dart';

class AdminController extends ChangeNotifier {
  AdminController(
    this._workspaceRepository,
    this._gateway,
    this._accessControlService,
  ) {
    _gateway.addListener(notifyListeners);
  }

  final WorkspaceRepository _workspaceRepository;
  final LocalMetarixGateway _gateway;
  final AccessControlService _accessControlService;

  List<AppUser> get users => _gateway.snapshot.users;

  List<WorkspaceMembership> get memberships => _gateway.snapshot.memberships;

  AppUser get currentUser => _gateway.currentUser;

  UserRole get currentRole => _gateway.currentUserRole;

  List<RuntimeAction> get visibleActions =>
      _accessControlService.visibleActionsFor(currentRole);

  Future<void> switchUser(String userId) => _gateway.switchUser(userId);

  Future<void> saveMembership(WorkspaceMembership membership) =>
      _workspaceRepository.saveMembership(membership);

  Future<void> resetDemo() => _gateway.resetDemo();

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
