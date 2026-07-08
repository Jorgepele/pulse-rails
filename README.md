# Pulse (Rails port) — a Ruby on Rails learning project

> The core of [Pulse](https://github.com/Jorgepele/pulse-api) (a feedback &
> roadmap app — teams post feature requests, users upvote them) ported to Ruby
> on Rails, to learn Rails and see how the MVC pattern maps from Django to Rails.
> Work in progress — learning in the open.

> El núcleo de Pulse (app de feedback y hoja de ruta: los equipos publican
> peticiones y los usuarios votan) portado a Ruby on Rails, para aprender Rails
> y ver cómo se traslada el patrón MVC desde Django. En desarrollo.

**Stack:** Ruby 3.4 · Rails 8.1 (API-only) · SQLite

---

## Why this port · Por qué este port

I already built Pulse as a Django REST API. Porting its core to Rails is the
fastest way to actually learn Rails: the domain is familiar, so I can focus on
how Rails does things — conventions, Active Record, the router, generators —
instead of re-inventing the product.

Ya construí Pulse como API REST en Django. Portar su núcleo a Rails es la forma
más rápida de aprender Rails de verdad: el dominio ya lo conozco, así que puedo
centrarme en *cómo* hace las cosas Rails (convenciones, Active Record, el router,
los generadores) en vez de reinventar el producto.

## What it does so far · Qué hace por ahora

- **Multi-tenant** domain: **Organization → Board → Post → Vote → Comment**,
  with users joined to organizations through **memberships** (owner/admin/member).
  Signing up creates your personal organization; boards belong to an org and
  their slug is unique per org.
- Auto-generated slug on boards and orgs, a default `open` status on posts, and
  `vote_count` / `comment_count` on each post.
- **Token authentication** (`has_secure_password` + a per-user API token), with
  `register` / `login` / `me` endpoints, mirroring the Django DRF token auth.
- JSON REST API under `/api` to list public boards, list/create posts,
  **toggle an upvote** (vote once, vote again to remove it), and list/add
  comments, and create a board under your organization. Reads are public;
  **writes require a token** and are attributed to the current user.
- Seed data (`bin/rails db:seed`) so the API has something to show.
- Model and API tests (34 tests).

This now covers the full Django domain, including the multi-tenant core
(organizations + memberships).

Esto cubre ya todo el dominio de Django, incluyendo el núcleo multi-tenant
(organizaciones + membresías).

## How MVC maps from Django to Rails · Cómo se traslada el MVC

| Concept | Django (pulse-api) | Rails (this repo) |
|--------|--------------------|-------------------|
| Model | `models.py` classes | `app/models/*.rb` (Active Record) |
| Schema change | migrations | migrations (`db/migrate`) |
| Controller | DRF views / viewsets | `app/controllers/api/*.rb` |
| Serialization | DRF serializers | hand-written `*_json` helpers |
| URL routing | `urls.py` | `config/routes.rb` |
| Auto slug | `save()` override | `before_validation` callback |
| Password hashing | Django auth (PBKDF2) | `has_secure_password` (bcrypt) |
| Token auth | DRF `TokenAuthentication` | `Authenticatable` concern + header |

## Run it locally · Cómo ejecutarlo

```bash
bundle install
bin/rails db:migrate
bin/rails db:seed        # optional: demo users, board, posts
bin/rails server
```

API at `http://127.0.0.1:3000/api/`. After seeding you can log in with
`demo@pulse.dev` / `demo12345`.

## Main endpoints

Writes require an `Authorization: Token <token>` header, where the token comes
from `register` or `login` (same scheme as the Django API).

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/api/auth/register` | — | Create an account, returns a token |
| `POST` | `/api/auth/login` | — | Exchange email + password for a token |
| `GET`  | `/api/auth/me` | token | The current user |
| `GET`  | `/api/boards` | — | List public boards |
| `GET`  | `/api/boards/:id` | — | A single board |
| `POST` | `/api/boards` | token | Create a board under your organization |
| `GET`  | `/api/posts?board_id=:id` | — | List posts (optionally by board) |
| `POST` | `/api/posts` | token | Create a feature request |
| `POST` | `/api/posts/:id/vote` | token | Toggle your vote |
| `GET`  | `/api/comments?post=:id` | — | List comments on a post |
| `POST` | `/api/comments` | token | Add a comment |

Example — register, then create a post and vote for it:

```bash
TOKEN=$(curl -s -X POST http://127.0.0.1:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"me@example.com","password":"secret123"}' | jq -r .token)

curl -X POST http://127.0.0.1:3000/api/posts \
  -H "Content-Type: application/json" -H "Authorization: Token $TOKEN" \
  -d '{"post":{"board_id":1,"title":"Dark mode"}}'

curl -X POST http://127.0.0.1:3000/api/posts/1/vote \
  -H "Authorization: Token $TOKEN"
```

## Tests

```bash
bin/rails test
```

## Deploy · Despliegue

Set up to deploy on [Render](https://render.com) (Ruby runtime, Puma, SQLite
re-seeded on each build). Step-by-step guide in [DEPLOY.md](DEPLOY.md).

## Ideas for next steps · Siguientes pasos

Add a live demo URL here once deployed, and organization-scoped board listing
(only show boards of the organizations you belong to).

---

MIT licensed. Built by [Jorge](https://github.com/Jorgepele) while learning Rails.
