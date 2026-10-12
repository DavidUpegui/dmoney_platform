# dmoney_platform/AGENTS.md

This repository is the **orchestrator** for the `dmoney` project. It owns no
application code. It routes work to the correct sub-repo, owns cross-repo
documentation, and is the single source of truth for the HTTP contract shared
by the front-end and back-end.

## Layout

| Path | What it is | Its own rules |
| ---- | ---------- | ------------- |
| `dmoney_back/` | Spring Boot API (Java 21) | `dmoney_back/AGENTS.md` |
| `dmoney_front/` | Expo / React Native app (TypeScript) | `dmoney_front/AGENTS.md` |
| `contracts/` | Shared HTTP contract | this file |
| `docs/` | Cross-repo business & technical docs | this file |
| `deploy/` | Environment recipes | this file |

Each sub-repo has its own `AGENTS.md` governing work inside that repo
(architecture, conventions, spec-first workflow, tests). This orchestrator
only decides *where* work goes and *how* the two sides stay consistent.

## Routing rules

Before doing anything, classify the request:

- **Back-end only** (API, domain model, persistence, auth, Liquibase, etc.) →
  read `dmoney_back/AGENTS.md`, then work inside `dmoney_back/`.
- **Front-end only** (screens, navigation, state, data fetching, Expo/EAS,
  etc.) → read `dmoney_front/AGENTS.md`, then work inside `dmoney_front/`.
- **Both sides** (a feature touching API + UI) → follow both repo rules, and if
  the API surface changes, update `contracts/` in the same change.
- **Cross-repo docs, contract, or deployment** → work here, in this repo.

If a request does not clearly name a side, ask before assuming.

## Shared contract

`contracts/` is the hand-maintained contract between front and back:

- `contracts/API_CONTRACT.md` — endpoints, models, owner-scoping, error
  conventions, and business meaning.
- `contracts/CHANGELOG.md` — contract version / breaking-change history.

There is no generated spec and no automation. `dmoney_back/docs/api.md` is the
back-end's own API reference, read locally by front-end agents.

Rules:

- Any change to an endpoint, path, status code, or field name must land in
  `contracts/API_CONTRACT.md` (and `dmoney_back/docs/api.md`) in the same change
  set as the code, never as an afterthought.
- The front-end consumes the back-end through this contract only. Do not
  hard-code API assumptions in front-end code that aren't recorded here.
- When front and back disagree, `contracts/` wins; fix the side that deviates
  (or update the contract explicitly and mirror the change).

## Environments

Only **local** exists today. `deploy/local/` brings up Postgres + the back-end
via Docker Compose; the front-end runs through Expo. There is no dev or
production environment yet — do not add deployment scaffolding for them until
a remote host exists.

## Cross-cutting conventions

- **Spec-first** applies on both sides. Each repo has its own `specs/` workflow
  (`dmoney_back/specs/`, `dmoney_front/specs/`); respect the one that owns the
  change.
- **Observations**: each repo keeps its own `OBSERVATIONS.md` for parked
  cross-cutting issues. Record repo-local findings there; do not cross-write
  into another repo's file. Cross-repo concerns belong in `contracts/`.
- Keep the two repos consistent but do not duplicate their rules here — when in
  doubt, the sub-repo's `AGENTS.md` is authoritative for that repo.
