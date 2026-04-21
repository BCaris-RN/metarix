# Real Backend Cutover Map

This map records the smallest safe path from the current public-safe demo runtime to a real local-connected backend. It is intentionally a seam audit, not a database schema or connector implementation plan.

## Current Demo Seams

| Current demo component | Real target component | Owning surface | Blocking dependencies | Risk level | Cutover order |
| --- | --- | --- | --- | --- | --- |
| `LocalMetarixGateway.bootstrap()` loads `SampleDataPack.initialSnapshot()` when no local snapshot exists | Session-aware workspace bootstrap that chooses an existing persisted workspace or signed-out state | App service bootstrap, workspace repositories, all controllers | Auth/session spine, workspace readiness model, persistent workspace store | High | 1 |
| App shell demo banner and reset action | Optional demo-mode utility clearly isolated from real runtime | Existing app shell and admin controller | Session mode flag, public-safe demo reset guard | Medium | 2 |
| Legacy policy-backed `ConnectorRegistry` in `lib/connectors/` | `ConnectorBundle` selected by backend mode, with platform contracts from `lib/metarix_core/connectors/` | `AppServices`, admin posture, report normalization | Real local-connected connector implementations, account connection state, connector health records | High | 3 |
| `LocalMetarixGateway` builds report snapshots and shared analytics signal summaries from locally persisted workspace data | `AnalyticsConnector` plus analytics repository/service using persisted or service-backed metric snapshots | Reports, analytics normalization, workspace signal summaries | Account IDs, metric sync jobs, period selection, persistence layer | High | 4 |
| `WorkflowController` and `ScheduleScreen` read drafts/schedules from the seeded snapshot | Publish repository/service with persisted campaign/post state and lifecycle transitions | Workflow and schedule surfaces | Publish state models, status transition service, workspace readiness | High | 5 |
| `ListeningQueryRepository` reads locally persisted queries, mentions, spikes, share-of-voice, and shared listening signal summaries | `ListeningConnector` plus listening repository/service with persisted watch and mention state | Listening and workspace signal surfaces | Watch-term persistence, sync job records, connector capability checks | High | 6 |
| Asset and planning screens can create `demo://` asset references | Content intake repository backed by local runtime folders and persisted media records | Planning and asset library surfaces | Local runtime folder config, intake records, media metadata persistence | Medium | 7 |
| Admin demo user selector switches seeded users and roles | Auth-backed current user and workspace membership state | Admin workspace surface | Session spine, workspace membership repository, role persistence | Medium | 8 |
| Demo connector implementations under `lib/metarix_core/connectors/demo/` | Fallback implementations behind the same connector contracts | Connector contract layer | Real adapters that implement the same interfaces | Low | Keep for fallback |

## Cutover Order

1. Add session and workspace bootstrap so app boot can resolve signed-out, signed-in without workspace, and workspace-ready states.
2. Keep the demo banner/reset only behind demo mode, and prevent it from appearing as normal connected-runtime behavior.
3. Register one connector bundle in DI so downstream code asks for contracts instead of concrete demo classes.
4. Move report metric normalization behind an analytics repository/service that can read persisted snapshots first and connector syncs second.
5. Move publish workflow and schedule state into a publish repository/service with explicit lifecycle transitions.
6. Move listening state into a repository/service, then let connector sync jobs populate watch results.
7. Move asset intake paths to local runtime config and persist imported media/content records.
8. Replace the demo user selector with real session user and membership state.

## Dependency Actions

- Keep demo connectors as fallback implementations only.
- Continue replacing any remaining direct screen access to persisted snapshot collections with repositories and services where needed.
- Stub real external connectors behind public contracts until local-only secret-backed adapters exist.
- Do not add live API calls, secrets, database schema, or new navigation structure in this cutover pass.

## Current Chunk Status

- `ConnectorBundle` now defines a single selectable backend capability bundle.
- Demo implementations compile behind the same public connector contracts.
- `AppServices` can select the bundle without screen-level branching.
- Reports, listening, and workspace signal summaries now converge through repository-backed local snapshots.
- Existing UI behavior is preserved while the backend seams are prepared.
