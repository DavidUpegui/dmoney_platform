# dmoney — Business Overview

## What it is

`dmoney` is a **personal money tracker**. A single user records what they earn
and spend, organizes it, and later reviews where their money went.

## Who it's for

- Individuals tracking their own personal finances.
- Primary market/currency: **COP** (Colombian peso). Currency is a UI concern;
  the back-end stores positive decimal amounts.

## Core concepts

- **Movement** — a single financial event: `INCOME`, `OUTCOME`, or `TRANSFER`,
  with an amount, a date, a category (and subcategory), an optional description,
  and optional tags.
- **Category / Subcategory** — a two-level classification of movements
  (e.g. *Groceries → Vegetables*). A category has a type (`INCOME` | `OUTCOME`).
- **Tag** — a free-form cross-cutting label (e.g. *vacation*), many-to-many with
  movements, used for filtering.

## Capabilities (current scope)

- **Accounts & auth** — register and log in; JWT-based sessions.
- **Categories** — CRUD for categories and their subcategories.
- **Tags** — CRUD.
- **Movements** — create, read, update, delete, and filter by category,
  subcategory, tag, type, date range, and free-text search.

## Principles

- **Owner-scoped by default.** Every resource belongs to one user. A user can
  only ever see or change their own data; another user's resource is
  indistinguishable from a missing one (`404`).
- **Spec-first.** Business rules are written as testable specifications before
  implementation, on both the front and back repositories.
- **One contract.** The front-end talks to the back-end only through the shared
  HTTP contract in `contracts/`.

## Out of scope (for now)

- Budgets, accounts/wallets with balances, shared/household finances,
  recurring movements, reporting/analytics beyond listing, and multi-currency.
