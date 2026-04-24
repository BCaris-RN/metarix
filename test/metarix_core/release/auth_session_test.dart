import 'package:flutter_test/flutter_test.dart';
import 'package:metarix/metarix_core/release/release.dart';

void main() {
  test('AppSession round trips and detects expiration', () {
    final session = AppSession(
      sessionId: 'session-1',
      userId: 'user-1',
      workspaceId: 'workspace-1',
      workspaceName: 'Demo Workspace',
      role: 'owner',
      accessTokenPreview: 'demo...',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T00:00:00.000Z',
      expiresAtIso: '1999-01-01T00:00:00.000Z',
    );

    expect(session.isExpired, isTrue);
    expect(AppSession.fromJson(session.toJson()).toJson(), session.toJson());
  });
}
