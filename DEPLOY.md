# Deploying pulse-rails to Render

A short walkthrough to put this API online on [Render](https://render.com)'s
free tier. It mirrors how `pulse-api` is deployed.

> Heads up: the free tier sleeps after inactivity (first request ~30 s) and its
> disk is reset on each deploy — that's why the build re-seeds demo data.

## What's already set up

- `render.yaml` — a Blueprint describing the web service (Ruby runtime, build
  and start commands, env vars).
- Production runs on **Puma** and listens on the `PORT` Render provides.
- The build runs `bin/rails db:prepare`, which migrates and seeds the SQLite
  database (demo user `demo@pulse.dev` / `demo12345`).

## Steps

1. Push this repo to GitHub (already done: `Jorgepele/pulse-rails`).
2. In Render: **New > Blueprint**, connect the repo. Render reads `render.yaml`.
3. Set the one secret it asks for:
   - **`RAILS_MASTER_KEY`** — paste the contents of your local
     `config/master.key` (this file is intentionally not in git). It lets Rails
     decrypt `config/credentials.yml.enc` for `secret_key_base`.
4. Create the service and wait for the first build/deploy.
5. Verify:
   - `GET /up` returns **200** (Rails health check).
   - `GET /api/boards` returns the seeded board.
   - `POST /api/auth/login` with the demo credentials returns a token.

## Notes

- **Host authorization:** `config.hosts` is left empty in production, so any
  host (including `*.onrender.com`) is accepted.
- **HTTPS:** Render terminates TLS at the edge; the app itself does not force
  SSL, which keeps the health check and local runs simple.
- Once it's live, add the URL to this repo's README (as `pulse-api` does).
