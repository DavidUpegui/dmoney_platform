# Technical Architecture

Cross-repo view of the `dmoney` system. Per-repo implementation detail lives in
each repo's `AGENTS.md` and `docs/`.

## System shape

```
┌────────────────────┐        ┌────────────────────┐
│    dmoney_front     │        │    dmoney_back      │
│  Expo / React Native│  HTTP  │  Spring Boot (J21)  │
│  TypeScript         │ ─────▶ │  Hexagonal          │
│  React Query + ctx  │  JWT   │  Postgres + Liquibase│
└─────────┬──────────┘        └─────────┬──────────┘
          │                             │ emits OpenAPI
          │ consumes                    │ (SpringDoc)
          ▼                             ▼
      ┌──────────────────────────────────────┐
      │           dmoney_platform             │
      │  contracts/ · docs/ · deploy/         │
      │  (orchestrator, no runtime service)   │
      └──────────────────────────────────────┘
```

The platform is **not** a runtime component. It is a versioned repository that
both sides read from and CI writes to.

## Back-end (`dmoney_back`)

- Spring Boot 3.3.5, Java 21, Gradle.
- **Hexagonal** architecture, three bounded contexts — `auth`, `tracker`,
  `shared` — each split into `domain` / `application` / `infrastructure`.
- Persistence: PostgreSQL + Liquibase (append-only changesets).
- Security: Spring Security + JWT (`jjwt`), BCrypt password hashing.
- Docs: SpringDoc OpenAPI served at `/v3/api-docs`.
- Quality: JaCoCo ≥ 80% coverage, SonarCloud.

## Front-end (`dmoney_front`)

- Expo (React Native), SDK 57, TypeScript.
- Server state via TanStack React Query; auth via React context.
- Navigation: Expo Router.
- JWT stored in `expo-secure-store`.
- Talks to the back-end only through the contract in `contracts/`.

## Contract

The HTTP interface is the seam between the two repos and its source of truth is
`contracts/` in this repo. See `contracts/README.md` for the flow:
back-end generates → platform commits and gates → front-end reads it as a
read-only reference.

## Environments

- **local** — Docker Compose (Postgres + back-end) for the API; Expo for the app.
- dev / production — not defined yet. No remote host; no deployment scaffolding
  until one exists.

## Data flow (a typical request)

1. User authenticates (`POST /auth/login`) → JWT.
2. Front attaches `Authorization: Bearer <token>` to `/api/**` calls.
3. Back resolves the `UserId` from the token, scopes every query by it, and
   returns only that user's data.
4. Errors return the shared error shape; `401` for auth failures, `404` for
   resources not owned by the caller.
