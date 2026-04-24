# MetaRix Plus Backend

Local backend boundary for OAuth callbacks, secrets, and token storage.

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
