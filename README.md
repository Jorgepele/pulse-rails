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

- Domain model: **Board → Post → Vote**, with an auto-generated slug on boards,
  a default `open` status on posts, and a `vote_count` on each post.
- JSON REST API under `/api` to list public boards, list/create posts, and
  **toggle an upvote** (vote once, vote again to remove it).
- Seed data (`bin/rails db:seed`) so the API has something to show.
- Model and API tests (12 tests).

This is a focused first slice. Comments, authentication and the multi-tenant
Organization model from the Django version are **not** ported yet.

Es un primer corte enfocado. Los comentarios, la autenticación y el modelo
multi-tenant de Organización de la versión Django **todavía no** están portados.

### A note on votes · Nota sobre los votos

In the Django version a vote belongs to a logged-in `User`. This port has no
authentication yet, so a vote is identified by an opaque `voter_token` the
client sends. One vote per `(post, voter_token)` pair, enforced by a unique
index. When auth lands, this becomes a real user reference.

## How MVC maps from Django to Rails · Cómo se traslada el MVC

| Concept | Django (pulse-api) | Rails (this repo) |
|--------|--------------------|-------------------|
| Model | `models.py` classes | `app/models/*.rb` (Active Record) |
| Schema change | migrations | migrations (`db/migrate`) |
| Controller | DRF views / viewsets | `app/controllers/api/*.rb` |
| Serialization | DRF serializers | hand-written `*_json` helpers |
| URL routing | `urls.py` | `config/routes.rb` |
| Auto slug | `save()` override | `before_validation` callback |

## Run it locally · Cómo ejecutarlo

```bash
bundle install
bin/rails db:migrate
bin/rails db:seed        # optional: demo board + posts
bin/rails server
```

API at `http://127.0.0.1:3000/api/`.

## Main endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/api/boards` | List public boards |
| `GET`  | `/api/boards/:id` | A single board |
| `GET`  | `/api/posts?board_id=:id` | List posts (optionally by board) |
| `POST` | `/api/posts` | Create a feature request |
| `POST` | `/api/posts/:id/vote` | Toggle a vote (send `voter_token`) |

Example — create a post and vote for it:

```bash
curl -X POST http://127.0.0.1:3000/api/posts \
  -H "Content-Type: application/json" \
  -d '{"post":{"board_id":1,"title":"Dark mode"}}'

curl -X POST http://127.0.0.1:3000/api/posts/1/vote \
  -H "Content-Type: application/json" \
  -d '{"voter_token":"me"}'
```

## Tests

```bash
bin/rails test
```

## Ideas for next steps · Siguientes pasos

Port the remaining pieces from the Django version — comments, authentication,
and the multi-tenant Organization model — and deploy a live demo.

---

MIT licensed. Built by [Jorge](https://github.com/Jorgepele) while learning Rails.
