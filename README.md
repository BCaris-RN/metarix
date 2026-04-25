<p align="center">
  <img src="assets/MetaRix_Internally_Flawless/metarix-readme-top-v2.png" alt="MetaRix wordmark" width="720" />
</p>

# MetaRix

MetaRix is a public-safe, local-first Flutter MVP for governed marketing operations.

This checkout runs as a single Flutter app from the repository root and keeps runtime state on your machine rather than in Git. The current product posture is a structured operating workspace for teams that need clearer coordination across campaign strategy, planning, workflow, scheduling, reporting, listening, assets, activity, and admin oversight.

## Current product posture

- first launch seeds a public-safe starter workspace locally
- later launches reopen the persisted local workspace state until the in-app `Reset Demo` action is used
- reports, listening, and workspace signal surfaces read repository-backed local snapshots
- optional `Supabase REST` wiring stays behind the same repository and service seams

## Current public build surfaces

- Strategy
- Planning
- Workflow
- Schedule
- Reports
- Listening
- Assets
- Activity
- Admin

## What the current MVP shows

- business goals, audience personas, competitor watchlists, and content pillars
- campaign planning and editorial calendar structure
- workflow state, approval posture, and evidence-style checks
- schedule readiness and publish eligibility visibility
- report summaries and channel-level performance views backed by local persistence
- listening queries, mention feeds, and insight routing backed by local persistence
- asset organization and usage context
- activity timeline and admin workspace visibility

## Build status

MetaRix is still in active development, but the current checkout is a runnable MVP rather than a concept-only shell.

- `flutter analyze` passes in this checkout
- `flutter test` passes in this checkout
- the repo is ready for local review and launch-safe human QA
- the app is not yet a production multi-user deployment or live publishing system

## Public-safe assets

- README wordmark: `assets/MetaRix_Internally_Flawless/metarix-readme-top-v2.png`
- showcase screenshots: `docs/assets/metarix-home.png`, `docs/assets/metarix-mobile.png`

## What comes next

Near-term priorities include:

- deeper workflow behavior
- stronger connected-runtime depth
- clearer documentation for public-facing progress and investor review
- final release review before a public checkpoint commit

## Public Repo Safety

MetaRix is intended to remain a self-hostable public repo. Public code, docs, assets, fixtures, and tracked governance contracts should be independently authored for MetaRix and safe to publish.

Local runtime state stays separate from the public repo. Secrets, tokens, personal data, local exports, watched folders, reports with real metrics, and other machine-specific runtime material belong in local-only storage.

If real Meta credentials were ever committed, staged, or shared, rotate the Meta App Secret before continuing. Keep `backend/.env` local-only and never commit it.

Do not commit:

- `.env`
- `local_runtime/`
- `local_data/`
- `local_watch/`
- `local_reports/`
- exported reports with real metrics
- live tokens or machine-specific config

The repo also includes a non-leak scan for provenance safety. Run `python .\scripts\scan_non_leak.py` or `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_repo_safety_checks.ps1` before shipping changes to catch forbidden proprietary names, copied path signatures, and semantic bundle markers early.

## Operating posture

MetaRix is currently presented as a governed local-first workspace:

- policy and contract data remain explicit and reviewable
- runtime behavior is bounded and deterministic
- demo content stays public-safe while local state persists outside the repo narrative

## Current document map

- `docs/PRODUCT_CHARTER.md`
- `V1_SCOPE.md`
- `docs/DOMAIN_MODEL.md`
- `docs/self_host_quickstart.md`
- `docs/public_repo_boundary.md`

## Repo structure

- the Flutter app lives at the repo root in `lib/`, `test/`, and the platform folders
- `docs/` contains product, boundary, and backend notes
- `assets/` contains safe public brand and demo assets
- `caris/` contains tracked governance contract inputs bundled by the app

## Run locally

```powershell
cd G:\metarix
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Build web release

```powershell
cd G:\metarix
flutter build web --release
```

## Demo mode

The default runtime boots with a public-safe sample workspace and local-first persistence through the app's repository layer. Refreshing the browser keeps the current local state until the user presses the in-app `Reset Demo` action.

For a newcomer-friendly path from clone to local run, start with [docs/self_host_quickstart.md](docs/self_host_quickstart.md).

## Optional backend path

The bounded backend path for the current MVP is `Supabase REST`, routed behind the same repository and service interfaces. Local demo runs do not require any secrets.

Example local command with explicit backend config:

```powershell
cd G:\metarix
flutter run -d chrome `
  --dart-define=METARIX_BACKEND_MODE=supabase_rest `
  --dart-define=METARIX_SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=METARIX_SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Do not commit real keys, tokens, or workspace-specific connection details.

## Known limitations

- demo mode persists locally and is intended for single-browser evaluation
- no live social connector publishing exists in this checkout
- human review is still required before any public release commit

## Working principles

- preserve architecture boundaries
- prefer deterministic behavior over cleverness
- keep execution bounded and reviewable
- treat publish actions as governed operations, not casual UI events
- do not fabricate completion
- do not widen scope silently
