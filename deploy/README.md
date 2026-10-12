# Deploy

Environment recipes for `dmoney`.

Today only **local** exists. There is no remote dev or production host yet, so
there is no deployment pipeline — see ADR 0001 and the platform `AGENTS.md`.

## local

Brings up Postgres and the Spring Boot back-end. The front-end runs separately
through Expo.

### Prerequisites

- Docker with the Compose plugin.
- The `dmoney_back` repo cloned as a sibling of this repo (the compose file
  mounts it read-write):

  ```
  projects/dmoney/
    dmoney_back/
    dmoney_front/
    dmoney_platform/
  ```

### Run the back-end

```bash
# from dmoney_platform/
docker compose -f deploy/local/docker-compose.yml up
```

- API: <http://localhost:8080>
- OpenAPI JSON: <http://localhost:8080/v3/api-docs>
- Swagger UI: <http://localhost:8080/swagger-ui/index.html>
- Postgres: `localhost:5432`, db `dmoney`, user `postgres`, password `root`

### Configuration

The back-end reads `JWT_SECRET` from the environment. Compose supplies a
throwaway default; override it with a `.env` file next to the compose file
(copy `deploy/local/.env.example` to `deploy/local/.env`).

Compose env vars override `dmoney_back/src/main/resources/application.yaml`:

| Variable | Overrides |
| -------- | --------- |
| `SPRING_DATASOURCE_URL` | `spring.datasource.url` |
| `SPRING_DATASOURCE_USERNAME` | `spring.datasource.username` |
| `SPRING_DATASOURCE_PASSWORD` | `spring.datasource.password` |
| `JWT_SECRET` | `jwt.secret` |

### Run the front-end

```bash
# from dmoney_front/
npm install
npm run web      # or: npm start (Expo Go)
```

The front-end expects the API at `http://localhost:8080` (see
`dmoney_front/src/constants.ts`).

### Stop / reset

```bash
docker compose -f deploy/local/docker-compose.yml down          # stop
docker compose -f deploy/local/docker-compose.yml down -v       # stop + wipe DB
```
