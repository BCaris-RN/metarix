# Self-Host Quickstart

## What MetaRix Is

MetaRix is a single-user social operations workspace for planning content, organizing local assets, reviewing metrics, tracking mentions, and keeping runtime state on your machine instead of in the public repo.

## Public Repo Mode Vs Local Connected Mode

Public repo mode is the demo-first path. It uses bundled sample data, local persistence, and public-safe fixtures so you can explore the app without real accounts or secrets.

Local connected mode uses your own machine-local configuration, export folders, and account credentials. That runtime stays on your computer and should never be committed.

## Required Tools

- Flutter SDK
- Dart SDK
- PowerShell
- A browser or desktop runner for Flutter

## How To Run Demo Mode

1. Clone the repo.
2. Install dependencies.
3. Run the app with the bundled demo data.
4. Use the in-app `Reset Demo` action if you want to restore the starter state.

The demo bundle includes a starter workspace profile, connected-account placeholders, a content queue, metrics, and a smartlink page example.

## How To Add Local `.env`

Create a local `.env` file beside the repo root and keep real values only on your machine.

Use [`.env.example`](../.env.example) as the template for placeholder keys:

- `INSTAGRAM_APP_ID`
- `INSTAGRAM_APP_SECRET`
- `FACEBOOK_APP_ID`
- `FACEBOOK_APP_SECRET`
- `LINKEDIN_CLIENT_ID`
- `LINKEDIN_CLIENT_SECRET`
- `TIKTOK_CLIENT_KEY`
- `TIKTOK_CLIENT_SECRET`
- `YOUTUBE_CLIENT_ID`
- `YOUTUBE_CLIENT_SECRET`
- `OPENAI_API_KEY`
- `CANVA_EXPORT_ROOT`
- `ADOBE_EXPORT_ROOT`
- `METARIX_SMARTLINK_BASE_URL`
- `METARIX_LOCAL_DB_PATH`

## How To Point Canva And Adobe Export Folders Locally

Set the export roots in your local `.env` so the app can read from folders on your machine:

- `CANVA_EXPORT_ROOT`
- `ADOBE_EXPORT_ROOT`

Keep those paths local-only. Do not publish them or turn them into shared repository references.

## How To Connect Supported Accounts Locally

1. Add your local app credentials to `.env`.
2. Open the app in local connected mode.
3. Authenticate the supported platforms on your machine.
4. Confirm the local runtime created accounts, metrics, and queue records without copying any token material into Git.

Supported public-facing connector families are:

- Instagram
- Facebook
- LinkedIn
- TikTok
- YouTube

## What Never Belongs On GitHub

- API keys
- OAuth tokens
- OAuth refresh tokens
- personal profile data
- private exports
- watched folder paths
- generated reports with real metrics
- analytics dumps
- local databases
- machine-specific runtime config
- proprietary source material copied from other repositories

