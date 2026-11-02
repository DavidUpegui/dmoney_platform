# dmoney API Contract

Contract between `dmoney_back` (Spring Boot) and `dmoney_front` (Expo / React Native).

> **Sources of truth**
>
> - This file — the cross-repo summary both sides follow: endpoints, models,
>   owner-scoping, error conventions and business meaning. Hand-written and
>   reviewed.
> - `dmoney_back/docs/api.md` — the back-end's detailed HTTP reference, which
>   the front-end agents read locally. Use it for request/response bodies and
>   known deviations.
>
> There is no generated spec and no automation (see ADR 0002). When the two
> documents disagree, fix the deviating side in the same change set.

## Base

| Item          | Value                       |
| ------------- | --------------------------- |
| Base URL      | `http://localhost:8080`     |
| Content type  | `application/json` (UTF-8)  |
| Auth scheme   | `Authorization: Bearer <token>` |
| CORS origin   | `http://localhost:5173` (Vite), `http://localhost:8081` (Expo Web) |

Every `/api/**` endpoint requires a valid JWT. Public (no token): `/auth/**`, `/v3/api-docs/**`, `/swagger-ui/**`.

- Missing / invalid / expired token on a protected endpoint → `401 Unauthorized`.
- All IDs are UUIDs serialized as strings.
- Dates (`date`) use ISO `yyyy-MM-dd` (`LocalDate`).
- `amount` is a positive decimal (`BigDecimal`).
- All resources are scoped to the authenticated user; accessing another user's resource returns `404`.

---

## Auth

### `POST /auth/register`

Create a user. Returns the new user id.

Request:

```json
{ "email": "a@b.com", "password": "secret", "name": "Alice" }
```

| Field      | Type   | Required |
| ---------- | ------ | -------- |
| `email`    | string | yes      |
| `password` | string | yes — at least 8 characters |
| `name`     | string | yes      |

Response `201 Created`:

```json
{ "userId": "0f7b..." }
```

### `POST /auth/login`

Exchange credentials for a JWT.

Request:

```json
{ "email": "a@b.com", "password": "secret" }
```

| Field      | Type   | Required |
| ---------- | ------ | -------- |
| `email`    | string | yes      |
| `password` | string | yes      |

Response `200 OK`:

```json
{ "token": "eyJhbGciOi..." }
```

Use the token on subsequent requests: `Authorization: Bearer <token>`.

---

## Categories — `/api/categories`

### Models

`Category`:

```json
{
  "id": "uuid",
  "name": "Groceries",
  "description": "Food",
  "type": "OUTCOME",
  "icon": "shopping-basket",
  "color": "amber"
}
```

| Field         | Type           | Notes                                     |
| ------------- | -------------- | ----------------------------------------- |
| `id`          | string         | UUID                                      |
| `name`        | string         |                                           |
| `description` | string         |                                           |
| `type`        | string         | `INCOME` \| `OUTCOME`                     |
| `icon`        | string \| null | Opaque client identifier, max 48 chars    |
| `color`       | string \| null | Opaque client token, max 32 chars         |

`Subcategory`:

```json
{
  "categoryId": "uuid",
  "subcategoryId": "uuid",
  "subcategoryName": "Vegetables",
  "subcategoryDescription": "Fresh produce",
  "icon": null,
  "color": null
}
```

| Field                   | Type           | Notes                                  |
| ----------------------- | -------------- | -------------------------------------- |
| `categoryId`            | string         |                                        |
| `subcategoryId`         | string         |                                        |
| `subcategoryName`       | string         |                                        |
| `subcategoryDescription`| string         |                                        |
| `icon`                  | string \| null | `null` = inherit from the category     |
| `color`                 | string \| null | `null` = inherit from the category     |

`icon` and `color` are **opaque to the back-end**: it stores the text the client
sends and returns it unchanged. It does not validate either against a catalog
or a palette, and it supplies no defaults — a client that omits them gets
`null` and applies its own default when rendering.

### Endpoints

| Method   | Path                                                | Auth | Success          | Body                                          |
| -------- | --------------------------------------------------- | ---- | ---------------- | --------------------------------------------- |
| `POST`   | `/api/categories`                                   | yes  | `201 Created`    | `{ name, description?, type, icon?, color? }`  |
| `GET`    | `/api/categories`                                   | yes  | `200 OK`         | —                                             |
| `GET`    | `/api/categories/{id}`                              | yes  | `200 OK`         | —                                             |
| `PATCH`  | `/api/categories/{id}`                              | yes  | `200 OK`         | `{ name?, description?, type?, icon?, color? }` |
| `DELETE` | `/api/categories/{id}`                              | yes  | `204 No Content` | —                                             |
| `POST`   | `/api/categories/{categoryId}/subcategories`        | yes  | `201 Created`    | `{ name, description?, icon?, color? }`        |
| `GET`    | `/api/categories/{categoryId}/subcategories`        | yes  | `200 OK`         | —                                             |
| `PATCH`  | `/api/categories/{categoryId}/subcategories/{subcategoryId}` | yes | `200 OK` | `{ name?, description?, icon?, color? }`  |
| `DELETE` | `/api/categories/{categoryId}/subcategories/{subcategoryId}` | yes | `204 No Content` | —                             |

Deleting a category or subcategory that still has movements returns `409`.

Create category request:

```json
{ "name": "Groceries", "description": "Food", "type": "OUTCOME", "icon": "shopping-basket", "color": "amber" }
```

- `name` required (max 255), `type` required (`INCOME` | `OUTCOME`), `description` optional (max 255).
- `icon` optional, trimmed, max 48 chars; blank → `null`.
- `color` optional, trimmed, max 32 chars; blank → `null`.

Edit category request (all fields optional):

```json
{ "name": "Food", "description": null, "type": "OUTCOME", "icon": "utensils", "color": "orange" }
```

- An absent `icon`/`color` keeps the current value; an empty string clears it
  to `null`.

Create subcategory request:

```json
{ "name": "Vegetables", "description": "Fresh produce", "icon": "carrot", "color": null }
```

- `name` required, `description` optional.
- `icon`/`color` optional; `null` means the subcategory inherits its category's
  value. The back-end never resolves or copies the inherited value.

Edit subcategory request (all fields optional):

```json
{ "name": "Frozen vegetables", "description": null, "icon": null, "color": "" }
```

- An absent field keeps the current value; an empty `icon`/`color` clears it to
  `null` (inherit).

---

## Tags — `/api/tags`

### Model

```json
{ "id": "uuid", "name": "vacation", "description": "Trip to Italy" }
```

| Field         | Type   |
| ------------- | ------ |
| `id`          | string |
| `name`        | string |
| `description` | string |

### Endpoints

| Method   | Path           | Auth | Success          | Body                           |
| -------- | -------------- | ---- | ---------------- | ------------------------------ |
| `POST`   | `/api/tags`    | yes  | `201 Created`    | `{ name, description? }`       |
| `GET`    | `/api/tags`    | yes  | `200 OK`         | —                              |
| `GET`    | `/api/tags/{id}` | yes | `200 OK`        | —                              |
| `PATCH`  | `/api/tags/{id}` | yes | `200 OK`         | `{ name?, description? }`      |
| `DELETE` | `/api/tags/{id}` | yes | `204 No Content` | —                            |

Create tag request:

```json
{ "name": "vacation", "description": "Trip to Italy" }
```

- `name` required, `description` optional.

---

## Movements — `/api/movements`

### Model

```json
{
  "movementId": "uuid",
  "categoryId": "uuid",
  "subcategoryId": "uuid",
  "amount": 42.5,
  "type": "OUTCOME",
  "description": "Lunch",
  "date": "2026-10-08",
  "tagIds": ["uuid", "uuid"]
}
```

| Field          | Type     | Notes                      |
| -------------- | -------- | -------------------------- |
| `movementId`   | string   | UUID                       |
| `categoryId`   | string   | UUID                       |
| `subcategoryId`| string   | UUID                       |
| `amount`       | number   | positive decimal           |
| `type`         | string   | `INCOME` \| `OUTCOME` \| `TRANSFER` |
| `description`  | string   | max 500 chars              |
| `date`         | string   | `yyyy-MM-dd`               |
| `tagIds`       | string[] | UUIDs                      |

### Endpoints

| Method   | Path                | Auth | Success          | Body / query                                        |
| -------- | ------------------- | ---- | ---------------- | --------------------------------------------------- |
| `POST`   | `/api/movements`    | yes  | `201 Created`    | see create request; returns `Location` header       |
| `GET`    | `/api/movements`    | yes  | `200 OK`         | see filter query params                             |
| `GET`    | `/api/movements/{id}` | yes | `200 OK`        | —                                                   |
| `PATCH`  | `/api/movements/{id}` | yes | `200 OK`        | see edit request                                    |
| `DELETE` | `/api/movements/{id}` | yes | `204 No Content` | —                                                  |

### Create movement

```json
{
  "categoryId": "uuid",
  "subcategoryId": "uuid",
  "amount": 42.5,
  "type": "OUTCOME",
  "description": "Lunch",
  "date": "2026-10-08",
  "tagIds": ["uuid"]
}
```

| Field          | Type     | Required |
| -------------- | -------- | -------- |
| `categoryId`   | string   | yes      |
| `subcategoryId`| string   | yes      |
| `amount`       | number   | yes (> 0)|
| `type`         | string   | yes      |
| `description`  | string   | no (≤ 500) |
| `date`         | string   | yes (`yyyy-MM-dd`) |
| `tagIds`       | string[] | no       |

### Edit movement (PATCH)

All fields optional; only provided fields are updated.

```json
{ "amount": 50.0, "description": "Dinner" }
```

| Field          | Type     | Notes     |
| -------------- | -------- | --------- |
| `categoryId`   | string   | optional  |
| `subcategoryId`| string   | optional  |
| `amount`       | number   | optional (> 0) |
| `type`         | string   | optional  |
| `description`  | string   | optional (≤ 500) |
| `date`         | string   | optional (`yyyy-MM-dd`) |
| `tagIds`       | string[] | optional  |

### List / filter query params (`GET /api/movements`)

All optional; combine freely.

| Param           | Type       | Notes                              |
| --------------- | ---------- | ---------------------------------- |
| `categoryIds`   | string[]   | repeatable (e.g. `?categoryIds=a&categoryIds=b`) |
| `subcategoryIds`| string[]   | repeatable                          |
| `tagIds`        | string[]   | repeatable                          |
| `type`          | string     | `INCOME` \| `OUTCOME` \| `TRANSFER` |
| `dateFrom`      | string     | `yyyy-MM-dd` (inclusive)            |
| `dateTo`        | string     | `yyyy-MM-dd` (inclusive)            |
| `search`        | string     | free-text, matches description      |

---

## Errors

All error responses share the same shape:

```json
{
  "status": 404,
  "error": "Not Found",
  "message": "Category not found",
  "timestamp": "2026-10-08T12:34:56Z"
}
```

| Field       | Type   | Notes                                   |
| ----------- | ------ | --------------------------------------- |
| `status`    | number | HTTP status code                        |
| `error`     | string | HTTP reason phrase                      |
| `message`   | string | human-readable detail                   |
| `timestamp` | string | ISO-8601 instant                        |

Status codes you can expect:

| Code | Meaning                 | Trigger                                            |
| ---- | ----------------------- | -------------------------------------------------- |
| 400  | Bad Request             | validation failure, malformed JSON, invalid enum/ID |
| 401  | Unauthorized            | missing/invalid/expired JWT on protected endpoint   |
| 404  | Not Found               | resource doesn't exist or belongs to another user   |
| 409  | Conflict                | duplicate name / already exists                     |
| 500  | Internal Server Error   | unexpected failure                                  |
