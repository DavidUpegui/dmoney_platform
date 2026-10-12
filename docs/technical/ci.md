# CI / Contract Pipeline

How the three repos cooperate. All CI runs on **GitHub Actions cloud runners**;
no server is required to run it.

## Workflows

| Repo | Workflow | Trigger | Does |
| ---- | -------- | ------- | ---- |
| `dmoney_back` | `ci.yml` | push/PR `trunk`,`main` | build, test, Sonar |
| `dmoney_back` | `notify-platform.yml` | push `trunk`,`main` | dispatch `openapi-updated` to platform |
| `dmoney_platform` | `contract-sync.yml` | `repository_dispatch` | boot back-end, fetch `/v3/api-docs`, open PR updating `contracts/openapi.json` |
| `dmoney_platform` | `contract-gate.yml` | PR touching `contracts/openapi.json` | `oasdiff` breaking-change check |
| `dmoney_front` | `contract-check.yml` | push/PR `trunk`,`main` | vendor contract, regenerate `src/types/api-schema.d.ts`, fail on drift |

## Flow

```
dmoney_back push → trunk
   ├─ ci.yml (build + test + Sonar)
   └─ notify-platform.yml ──dispatch──▶ dmoney_platform
                                          contract-sync.yml
                                            ├─ boot back-end
                                            ├─ curl /v3/api-docs → contracts/openapi.json
                                            └─ open PR
                                                 └─ contract-gate.yml (oasdiff)
                                                      (on PR)  │
dmoney_front push/PR ────────────────────────────────────────┘
   └─ contract-check.yml (pull contract, regenerate types, fail on drift)
```

## Required repository secrets

| Repo | Secret | Purpose |
| ---- | ------ | ------- |
| `dmoney_back` | `PLATFORM_DISPATCH_TOKEN` | Fine-grained PAT / App token allowed to send `repository_dispatch` to `dmoney_platform`. |
| `dmoney_platform` | `CONTRACT_SYNC_TOKEN` | Read access to `dmoney_back` (to check it out and boot it). |
| `dmoney_front` | `PLATFORM_READ_TOKEN` | Read access to `dmoney_platform` if it is private (`GITHUB_TOKEN` works if it is public). |

`GITHUB_TOKEN` is provided automatically and is used by `create-pull-request`.

## Local equivalents

- Validate a contract change offline: `scripts/validate-contract.sh`.
- Manually trigger a sync: `scripts/dispatch-contract-sync.sh [ref]`.
