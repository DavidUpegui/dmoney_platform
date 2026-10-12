# dmoney_platform

Orchestrator repository for the **dmoney** project. It owns no application code;
it holds the cross-repo documentation, the shared HTTP contract, the deployment
recipes, and the orchestration rules that connect the front-end and back-end
repositories.

## Repositories

| Repo | What it is |
| ---- | ---------- |
| [`dmoney_back`](https://github.com/DavidUpegui/dmoney_back) | Spring Boot API (Java 21) |
| [`dmoney_front`](https://github.com/DavidUpegui/dmoney_front) | Expo / React Native app (TypeScript) |
| `dmoney_platform` (this repo) | Orchestrator, contract, docs, deploy |

## What lives here

```
docs/            Business and technical documentation shared across repos
contracts/       Shared HTTP contract (hand-maintained) — the source of truth
deploy/local/    Local development stack (Postgres + backend) via Docker Compose
AGENTS.md        Orchestrator rules (routing, contract ownership)
```

## The contract

The contract between front and back is documentation, maintained by hand in
`contracts/`:

- `API_CONTRACT.md` — curated semantics (endpoints, owner-scoping, errors,
  business meaning).
- `CHANGELOG.md` — contract version / breaking-change history.

The back-end also keeps its own API reference at `dmoney_back/docs/api.md`,
which is what the front-end's agents read locally (via
`dmoney_front/opencode.json`). There is no generated spec and no automation.

See `contracts/README.md` for details.

## Local development

```bash
docker compose -f deploy/local/docker-compose.yml up
```

Brings up Postgres and the back-end. Run the front-end with Expo separately.
See `deploy/README.md`.

## Working in this repo

Agents should read `AGENTS.md` first. Application changes belong in the
front/back repositories, not here.
