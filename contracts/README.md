# Contracts

The HTTP interface shared by `dmoney_back` and `dmoney_front`.

## Files

| File | Role |
| ---- | ---- |
| `API_CONTRACT.md` | Curated, hand-maintained contract: endpoints, models, owner-scoping, errors, business meaning. |
| `CHANGELOG.md` | Contract version / breaking-change history. |

This is a **documentation-only** contract. There is no generated spec and no
automation — `API_CONTRACT.md` is written and reviewed by hand.

`dmoney_back` also keeps its own API reference at `dmoney_back/docs/api.md`,
which is what the front-end's agents read locally (via
`dmoney_front/opencode.json`).

## Keeping it in sync

- When the API changes, update `API_CONTRACT.md` in the same change set.
- The front-end consumes the back-end through this contract only; do not
  hard-code API assumptions that aren't recorded here.
- When front and back disagree, the contract wins.

## Versioning

Contract versions are recorded in `CHANGELOG.md`:

- **major** — breaking change (removed/renamed endpoint or field, tightened type).
- **minor** — additive, backward-compatible (new endpoint or optional field).
- **patch** — docs/semantics only, no wire change.
