# ADR 0002 — Contract as a versioned artifact, not a runtime broker

- **Status:** Accepted
- **Date:** 2026-10-12

## Context

The front-end must stay in sync with the back-end's HTTP API. An initial idea
was for the front-end (or its agent) to ask the platform for the API docs at
runtime, with the platform fetching them from the back-end and relaying them.

## Decision

Publish the contract as a **versioned file artifact** instead of brokering it at
runtime:

- The back-end generates `openapi.json` (SpringDoc) in CI.
- The platform receives it via a push-triggered `repository-dispatch`, gates it
  with `oasdiff`, and commits it under `contracts/`.
- The front-end reads the artifact as a **read-only reference** (no code
  generation, no drift gate).

Agents read the file locally (via `opencode.json` references). No network
round-trip, no broker service.

## Rationale

- The data is fundamentally static and versionable — a runtime proxy adds a
  dependency, a failure point, and nondeterminism for no benefit.
- Local context is reproducible and works offline.
- Breaking changes become explicit and reviewable (diff + gate), which a
  pass-through broker would hide.
- Generated TypeScript types were considered and rejected for now: a blocking
  drift gate adds friction disproportionate to the value for a solo project.
  The contract remains available for reference and can be code-generated later.

## Consequences

- The contract lives in one place (platform); the front-end points at it rather
  than keeping a synced copy.
- Consumers see a change only once the sync PR is merged, so there is a small
  lag between a back-end change and the front-end noticing it — acceptable and
  intentional.
- If dynamic tooling is ever genuinely needed (e.g. live deploy status or
  generated types), it can be added later without changing this contract flow.
