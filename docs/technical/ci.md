# CI / Contract Pipeline

How the three repos cooperate. All CI runs on **GitHub Actions cloud runners**;
no server is required to run it.

## Workflows

| Repo | Workflow | Trigger | Does |
| ---- | -------- | ------- | ---- |
| `dmoney_back` | `ci.yml` | push/PR `trunk`,`main` | build, test, Sonar |
| `dmoney_back` | `notify-platform.yml` | push `trunk`,`main` | dispatch `openapi-updated` to platform |
| `dmoney_platform` | `contract-sync.yml` | `repository_dispatch` | run back's OpenAPI export test (H2, no server), open PR updating `contracts/openapi.json` |
| `dmoney_platform` | `contract-gate.yml` | PR touching `contracts/openapi.json` | `oasdiff` breaking-change check |

The front-end has no CI step here. It consumes `contracts/` as a read-only
reference (via `opencode.json`); there is no generated-types drift gate.

## Flow

```
dmoney_back push → trunk
   ├─ ci.yml (build + test + Sonar)
   └─ notify-platform.yml ──dispatch──▶ dmoney_platform
                                          contract-sync.yml
                                            ├─ ./gradlew test --tests OpenApiExportTest (H2, no server/DB)
                                            ├─ back/build/openapi/openapi.json → contracts/openapi.json
                                            └─ open PR
                                                 └─ contract-gate.yml (oasdiff, on PR)
```

## How the spec is generated

SpringDoc produces the spec by inspecting the running Spring context, so the
context must be built once. Rather than starting the full server + Postgres,
`contract-sync` runs `dmoney_back`'s `OpenApiExportTest`, which boots the
context against **in-memory H2** and serializes `GET /v3/api-docs`. No web
server, no database container.

## Required repository secrets

| Repo | Secret | Purpose |
| ---- | ------ | ------- |
| `dmoney_back` | `PLATFORM_DISPATCH_TOKEN` | Fine-grained PAT / App token allowed to send `repository_dispatch` to `dmoney_platform`. |
| `dmoney_platform` | `CONTRACT_SYNC_TOKEN` | Read access to `dmoney_back` (to check it out and run the export test). |
| `dmoney_platform` | `PLATFORM_PR_TOKEN` | Open the sync PR. Must be a PAT: PRs opened with `GITHUB_TOKEN` do not trigger `contract-gate`. |

`GITHUB_TOKEN` is provided automatically by GitHub per workflow run, but it is
scoped to the current repository **and** events it triggers do not start new
workflow runs. That is why cross-repo steps use PATs.

## Local equivalents

- Validate a contract change offline: `scripts/validate-contract.sh`.
- Manually trigger a sync: `scripts/dispatch-contract-sync.sh [ref]`.
