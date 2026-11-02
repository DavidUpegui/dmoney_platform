# Git workflow

Applies to the three repositories: `dmoney_back`, `dmoney_front` and
`dmoney_platform`. Repo-specific rules in each `AGENTS.md` still win over
anything here that conflicts.

## 1. Branches

- `trunk` is the only long-lived branch and the default branch in all three
  repositories. Do not create `main`, `develop` or release branches.
- All work happens on short-lived branches created from an up-to-date `trunk`
  and merged back through a pull request. No direct pushes to `trunk`.
- Name branches `<type>/<slug>`, lowercase, hyphens, no author or date:

  | Type | Use |
  | ---- | --- |
  | `feature/` | new capability or behaviour |
  | `fix/` | bug fix |
  | `refactor/` | behaviour-preserving restructuring |
  | `docs/` | documentation, specs, ADRs |
  | `chore/` | tooling, dependencies, CI, config |
  | `contract/` | changes to `dmoney_platform/contracts/` |

  Example: `feature/movement-filters`, `fix/tag-owner-scope`.

- Keep branches short: aim to merge within a day or two. Rebase on `trunk` at
  least daily (`git fetch origin && git rebase origin/trunk`). A branch that
  lives for a week is a sign the change should be split.
- Delete the branch after merge (GitHub does this automatically).

## 2. Commits

Conventional Commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`,
  `revert`, or `contract` for contract syncs.
- **scope**: optional, the capability or area — `auth`, `tracker`, `ui`,
  `api`, `specs`, `deps`.
- **subject**: imperative, lowercase after the colon, no trailing period,
  ≤ 72 characters. Say what the commit does, not what you were thinking.
- **body**: wrap at 72, explain *why* when the reason is not obvious from the
  diff. Omit it for trivial commits.
- **footer**: reference the requirement ID and, when relevant, the linked PR
  in another repo:

  ```
  Req: TAG02
  Contract: DavidUpegui/dmoney_platform#12
  ```

- One logical change per commit. Do not mix a refactor with a feature, or a
  formatting pass with a fix.
- Never rewrite `trunk`. Inside your own branch, rebase and amend freely.

Examples:

```
feat(tracker): filter movements by multiple tags
fix(auth): return 404 for another user's resource
docs(contract): document PATCH /movements/{id} response
```

## 3. Pull requests

- Every change reaches `trunk` through a PR, even when working solo.
- One PR = one requirement ID or one coherent unit of work. PRs can be
  reasonably large: as a guide, past roughly 800 changed lines check whether
  the change can be split without tearing a requirement apart.
- PR title is a valid Conventional Commit subject; it becomes the trunk commit
  when squashed.
- PR description answers: **what** changed, **why**, which **requirement ID**
  it closes, whether it touches the **HTTP contract**, and how it was
  **verified**. Each repo ships a template for this.
- Run the local gate before pushing, and do not merge until CI is green:

  | Repo | Local gate | CI |
  | ---- | ---------- | -- |
  | `dmoney_back` | `./gradlew check` | build, tests, JaCoCo ≥ 80%, Sonar |
  | `dmoney_front` | `npm run verify` + `npm test` | typecheck, lint, requirements audit, tests |
  | `dmoney_platform` | manual review of the diff | none |

- Review your own diff before merging: no debug output, no commented code, no
  unrelated files, no TODOs without an entry in `OBSERVATIONS.md`.
- Merge with **squash and merge**; the PR title becomes the commit message on
  `trunk`. Do not merge with a "Merge pull request #N" commit.
- Force-push only to your own branch, and only before review starts.

## 4. Branch protection (GitHub settings)

`trunk` in all three repositories:

- Require a pull request before merging (no direct pushes, admins included).
- Require the repo's CI check to pass.
- Require linear history.
- Disallow force pushes and branch deletion.

These are GitHub settings, not files in the repo: whoever has admin applies
them once and keeps them in sync across the three repositories.

## 5. Cross-repo changes

A change that touches the API surface spans repositories and lands in this
order:

1. **Contract first** — `dmoney_platform` PR updating
   `contracts/API_CONTRACT.md` and `contracts/CHANGELOG.md` (bump the contract
   version when the change is breaking).
2. **Back-end** — implementation plus `dmoney_back/docs/api.md`, referencing
   the contract PR.
3. **Front-end** — consumption, merged only after the contract is on `trunk`.

All PRs in the set cross-link each other in their descriptions. When front and
back disagree, `contracts/` wins.

For a single-sided change, no contract PR is needed — but any endpoint, path,
status code or field name that changes must still be reflected in
`contracts/API_CONTRACT.md` and `docs/api.md` within the same change set.

## 6. What travels with the code

The same PR carries, when applicable:

- The requirement block in `specs/**/spec.md` and its `tasks.md` entry, with
  `Validado` checked only when the sub-items and tests are green.
- Tests named after the requirement ID (`tag02_...`).
- Contract and API-doc updates.
- New `OBSERVATIONS.md` entries for out-of-scope findings.
- An ADR in `dmoney_platform/docs/technical/adr/` for cross-repo decisions.

Never commit secrets or `.env` files, build output, `node_modules`, or
generated artifacts that are not tracked on purpose. Liquibase changesets are
append-only: add a new changeset, never edit an applied one.

## 7. Reverts and hotfixes

- Revert with a `revert:` commit that names the original commit, and state the
  reason in the body.
- A hotfix is a `fix/<slug>` branch off `trunk` following the normal PR path —
  no special branch or bypass.
- Tags are created only for a deployable milestone, as annotated `vX.Y.Z` on
  `trunk`. The contract version lives in `contracts/CHANGELOG.md`, not in git
  tags.
