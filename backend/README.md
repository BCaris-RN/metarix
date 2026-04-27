# MetaRix Plus Backend

Local backend boundary for OAuth callbacks, secrets, token storage, and explicit live Meta Page test calls.

## Setup

```powershell
cd backend
npm install
copy .env.example .env
npm run dev
```

## Smoke checks

```powershell
Invoke-RestMethod http://localhost:8787/health
Invoke-RestMethod http://localhost:8787/api/meta/status
```

## Meta local setup

1. Create a Meta developer app.
2. Add Facebook Login.
3. Set the Valid OAuth Redirect URI to `http://localhost:8787/api/oauth/meta/callback`.
4. Copy `.env.example` to `.env`.
5. Fill `META_APP_ID` and `META_APP_SECRET`.
6. Run `npm run dev`.
7. Open `http://localhost:8787/api/meta/login-url?workspaceId=demo-workspace`.
8. Copy the returned `loginUrl` into a browser.
9. Complete auth.
10. Check `http://localhost:8787/api/meta/pages?workspaceId=demo-workspace`.

## Meta OAuth local test

1. Confirm `backend/.env` exists on your machine.
2. Run `npm run dev`.
3. Generate a login URL with `GET /api/oauth/meta/login-url?workspaceId=demo-workspace`.
4. Open the returned URL in your browser.
5. Complete Meta login.
6. Verify `GET /api/oauth/meta/connection?workspaceId=demo-workspace`.
7. Verify `GET /api/oauth/meta/pages?workspaceId=demo-workspace`.

## Meta Page text post local test

Use the same `workspaceId` that completed Meta OAuth. The response returns the Meta post id only; access tokens remain in `backend/.local/token-store.json`.

```powershell
Invoke-RestMethod `
  -Method Post `
  -Uri "http://localhost:8787/api/meta/pages/105029978978132/post-text" `
  -ContentType "application/json" `
  -Body (@{
    workspaceId = "post-permission-test-1"
    message = "Hello from MetaRix+ live Facebook test"
  } | ConvertTo-Json)
```
