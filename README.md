# MetaRix

MetaRix is a public build in progress focused on making modern marketing operations more structured, visible, and execution-ready.

The product is being shaped as a unified operating workspace for teams that need clearer coordination across campaign strategy, planning, workflow, scheduling, reporting, listening, assets, activity, and admin oversight.

## Current public build

The current MetaRix build now demonstrates a connected walkthrough across the full operating flow:

- Strategy
- Planning
- Workflow
- Schedule
- Reports
- Listening
- Assets
- Activity
- Admin

This matters because many teams still manage these functions across fragmented tools, disconnected approvals, and inconsistent reporting surfaces. MetaRix is being built to bring those motions into a more coherent system with clearer visibility, cleaner handoffs, and stronger execution posture.

## What the public build currently shows

- business goals, audience personas, competitor watchlists, and content pillars
- campaign planning and editorial calendar structure
- workflow state, approval posture, and evidence-style checks
- schedule readiness and publish eligibility visibility
- report summaries and channel-level performance views
- listening queries, mention feeds, and insight routing
- asset organization and usage context
- activity timeline and admin workspace visibility

## Build status

MetaRix is still in active development.

The current milestone is not about claiming a finished platform. It is about demonstrating that the product is taking shape as a real, navigable operating system rather than remaining a concept alone.

## What comes next

Near-term priorities include:

- deeper workflow behavior
- stronger state continuity across surfaces
- more complete public demo polish
- clearer documentation for public-facing progress and investor review

## Development

Keep this repository public-safe.

Local-only proprietary folders such as `caris/` and `phoenix/` are intentionally out of Git scope unless explicitly approved.

## Public Repo Safety

MetaRix is intended to remain a self-hostable public repo. Public code, docs, assets, and fixtures should be independently authored for MetaRix and safe to publish.

Local runtime state stays separate from the public repo. Secrets, tokens, personal data, local exports, watched folders, reports with real metrics, and other machine-specific runtime material belong in local-only storage.

The repo also includes a non-leak scan for provenance safety. Run `python .\scripts\scan_non_leak.py` or `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_repo_safety_checks.ps1` before shipping changes to catch forbidden proprietary names, copied path signatures, and semantic bundle markers early.

## What lives here

- Product-facing documentation
- MetaRix-specific governance contracts and schemas
- Runtime implementation surfaces
- Bounded build plans
- Release evidence and validation notes

## Operating posture

MetaRix follows the 8gentiC | Caris | Phoenix framework:

- `8gentiC` owns governed SDLC orchestration, handoffs, review classes, and build routing.
- `Caris` owns constitutional governance, schemas, policy manifests, permissions, hard gates, and machine-readable truth.
- `Phoenix` owns the bounded runtime, operator workbench, evidence presentation, denial visibility, and controlled execution behavior.

## Current document map

- `docs/PRODUCT_CHARTER.md`
- `docs/V1_SCOPE.md`
- `docs/DOMAIN_MODEL.md`

## Repo structure

- `docs/` contains product and domain docs.
- `caris/` contains MetaRix governance contracts and policy inputs.
- `phoenix/` contains the runnable Flutter runtime shell.

## Run locally

```powershell
cd G:\metarix\phoenix
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Build web release

```powershell
cd G:\metarix\phoenix
flutter build web --release
```

## Demo mode

The default runtime boots in demo mode with public-safe sample data and local persistence. Refreshing the browser keeps the current demo state until the user presses the in-app `Reset Demo` action.

For a newcomer-friendly path from clone to local run, start with [docs/self_host_quickstart.md](docs/self_host_quickstart.md).



## Optional backend path

The bounded backend path for V1 is `Supabase REST`, routed behind Phoenix repository and service interfaces. Local demo runs do not require any secrets.

Example local command with explicit backend config:

```powershell
cd G:\metarix\phoenix
flutter run -d chrome `
  --dart-define=METARIX_BACKEND_MODE=supabase_rest `
  --dart-define=METARIX_SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=METARIX_SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Do not commit real keys, tokens, or workspace-specific connection details.

## Public Repo Safety

MetaRix is meant to stay public-safe, self-hostable, and reproducible.

The public repo contains the app, docs, fixtures, and demo content needed to run without real accounts. Local connected runtime data stays on your machine, including `.env`, export folders, watched paths, and live account tokens.

Use the non-leak scanner before publishing changes:

```powershell
python .\scripts\scan_non_leak.py
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_repo_safety_checks.ps1
```

## Known limitations

- Demo mode persists locally and is intended for single-browser evaluation.
- No live social connector publishing exists in this chunk.
- Caris remains the source of publish, approval, and evidence authority.

## Working principles

- Preserve architecture boundaries.
- Prefer deterministic behavior over cleverness.
- Keep execution bounded and reviewable.
- Treat publish actions as governed operations, not casual UI events.
- Do not fabricate completion.
- Do not widen scope silently.
