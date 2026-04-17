# Public Repo Boundary

MetaRix uses this repository as a public-safe showcase surface. The public repo should contain:

- UI source
- mocks and demo fixtures
- schemas and interfaces
- docs and public product narrative
- screenshots and other safe showcase assets

Local runtime data must stay outside the public repo. That includes:

- access tokens and OAuth refresh tokens
- personal profile data
- private exports
- watched folders
- generated reports with real metrics
- analytics dumps
- local reports and local logs
- local databases and runtime config

The local runtime folder contract is intentionally git-ignored:

- `local_runtime/`
- `local_data/`
- `local_watch/`
- `local_reports/`

When real connectors are in use, testing should happen locally. Only safe screenshots, summaries, and non-sensitive results should be shown publicly.

The repository boundary is intentionally conservative:

- if a file contains real user data, credentials, or connected state, keep it local-only
- if a file is only needed to run the app on one machine, keep it local-only
- if a file is safe to publish as part of the product story, it can live in the repo

This boundary protects the public showcase while preserving a clear local runtime contract for real integrations.
