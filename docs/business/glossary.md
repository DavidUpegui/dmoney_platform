# Domain Glossary

Shared vocabulary for `dmoney`. When code, specs, or docs use these terms, they
mean this.

| Term | Meaning |
| ---- | ------- |
| **User** | The authenticated owner of all data. Identified by a UUID. |
| **Movement** | A single financial event (income, outcome, or transfer) belonging to a user. |
| **Category** | Top-level classification of movements. Has a `type` of `INCOME` or `OUTCOME`. |
| **Subcategory** | Second-level classification, always nested under exactly one category. |
| **Tag** | Free-form, cross-cutting label; a movement can have many tags and a tag many movements. |
| **Type** | One of `INCOME`, `OUTCOME`, `TRANSFER`. Categories use `INCOME`/`OUTCOME`; movements also allow `TRANSFER`. |
| **Amount** | A positive decimal (`BigDecimal` on the back-end). Sign comes from `type`, never from the amount. |
| **Owner-scoping** | Every read/write is filtered by the authenticated `UserId`. Another user's resource behaves as `404`. |

## Type semantics

- `INCOME` — money coming in.
- `OUTCOME` — money going out.
- `TRANSFER` — movement between the user's own contexts; valid on movements,
  not on categories.

## Identifiers & formats

- All IDs are UUIDs serialized as strings.
- Dates are ISO `yyyy-MM-dd` (`LocalDate`).
- Timestamps in errors are ISO-8601 instants.
- Error bodies share one shape: `{ status, error, message, timestamp }`.
