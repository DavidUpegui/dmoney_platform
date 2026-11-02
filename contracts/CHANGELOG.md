# Contract Changelog

All notable changes to the shared HTTP contract. Contract-level semver:
**major** = breaking wire change, **minor** = additive, **patch** = docs only.

## [Unreleased]

### Added
- `Category` and `Subcategory` gained optional `icon` and `color` fields, both
  nullable and opaque to the back-end (max 48 and 32 chars). The back-end
  stores and returns the client's text without validating it against a catalog
  or palette and without supplying defaults. `PATCH` clears a field with an
  empty string; on a subcategory `null` means "inherit from the category".
  Additive, non-breaking (minor).
- Initial contract migrated from the root `API_CONTRACT.md` bridge.

### Notes
- Baseline: contract migrated from the root `API_CONTRACT.md` bridge and
  consolidated as hand-maintained documentation. There is no generated spec and
  no automation.
