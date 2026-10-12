# ADR 0001 — A platform repository as orchestrator

- **Status:** Accepted
- **Date:** 2026-10-12

## Context

`dmoney` is split into two independent repositories, `dmoney_back` and
`dmoney_front`. Cross-repo concerns — the shared HTTP contract, business and
technical documentation, and environment recipes — had no home. They lived as
loose files in a non-versioned workspace directory (`dmoney/.AGENTS.md`,
`dmoney/API_CONTRACT.md`), outside any repository and therefore outside review,
history, and CI.

## Decision

Create a third, independent repository, `dmoney_platform`, that:

- owns cross-repo documentation and the shared contract;
- owns environment/deployment recipes;
- holds the orchestration/routing rules used by agents and humans.

It contains **no application code** and runs **no service**.

## Consequences

- Cross-repo changes become reviewable and versioned (PRs, history, CI).
- The contract gets a single owner; front and back reference it instead of
  duplicating assumptions.
- One more repository to clone; the local workspace now contains three repos.
- The bridge instructions live inside a repo, so they are subject to the same
  review as everything else.
