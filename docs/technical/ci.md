# CI

CI runs on **GitHub Actions cloud runners**; no server is required.

## Workflows

| Repo | Workflow | Trigger | Does |
| ---- | -------- | ------- | ---- |
| `dmoney_back` | `ci.yml` | push/PR `trunk`,`main` | build, test, Sonar |

There is no contract pipeline. The API contract is documentation only:

- `dmoney_back/docs/api.md` — the back-end's API reference, read locally by
  front-end agents (via `dmoney_front/opencode.json`).
- `dmoney_platform/contracts/API_CONTRACT.md` — the curated cross-repo contract.

Both are maintained by hand in the same change set as the code they describe.
