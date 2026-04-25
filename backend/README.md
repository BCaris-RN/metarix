# MetaRix Plus Backend

Local backend boundary for OAuth callbacks, secrets, and token storage.

Meta callback completion is still pending in this chunk. The local backend can prepare login URLs and state, but it does not complete the callback exchange yet.

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
3. Set the Valid OAuth Redirect URI to `http://localhost:8787/api/meta/callback`.
4. Copy `.env.example` to `.env`.
5. Fill `META_APP_ID` and `META_APP_SECRET`.
6. Run `npm run dev`.
7. Open `http://localhost:8787/api/meta/login-url?workspaceId=demo-workspace`.
8. Copy the returned `loginUrl` into a browser.
9. Complete auth.
10. Check `http://localhost:8787/api/meta/pages?workspaceId=demo-workspace`.
