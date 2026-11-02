# Deploy

Environment recipes for `dmoney`.

Today only **local** exists. There is no remote dev or production host yet, so
there is no deployment pipeline — see ADR 0001 and the platform `AGENTS.md`.

## local

Brings up Postgres and the Spring Boot back-end. The front-end runs separately
through Expo.

### One command (Expo Go over tunnels)

From `dmoney_platform/`:

```bash
deploy/local/dev
```

It does the whole flow:

1. Builds `dmoney_back/build/libs/dmoney-0.0.1-SNAPSHOT.jar` if the sources are
   newer than the jar.
2. Starts Postgres and the back-end with Compose.
3. Waits until the API is ready.
4. Opens a `cloudflared` quick tunnel to the API and verifies the login through
   it.
5. Starts Expo with `EXPO_PUBLIC_API_URL` pointed at that tunnel and prints the
   QR.

Scan the QR with **Expo Go (SDK 58)**. The login is prefilled in development;
just tap **Sign in** with:

```
email:    emailprueba@gmail.com
password: password
```

`Ctrl-C` stops Expo and the API tunnel. The Docker stack stays up for a fast
restart. Use `deploy/local/dev down` to stop it.

### Commands

| Command | What it does |
| --- | --- |
| `deploy/local/dev` | Build if needed, start db + back + tunnel, then Expo |
| `deploy/local/dev up` | Same without Expo; leaves the API tunnel running |
| `deploy/local/dev app` | Start Expo using the current API tunnel |
| `deploy/local/dev down` | Stop Expo, Compose and the API tunnel (keep the DB volume) |
| `deploy/local/dev reset` | Stop everything, including Expo, and wipe the DB volume |
| `deploy/local/dev status` | Containers, ports and current API URL |
| `deploy/local/dev logs` | Follow back-end logs |

`deploy/local/dev-up.sh` is kept as a deprecated wrapper for the old entry
point; it runs `./dev`.

### How the back-end runs

The Compose back-end is a slim JRE container running the prebuilt jar:

```text
eclipse-temurin:21-jre
java -Xmx640m -jar /app/app.jar --server.port=8080
```

The jar is mounted from `../../../dmoney_back/build/libs/`. Building it is the
script's job; Compose does not compile the back-end on every start. If you
change back-end code, run `deploy/local/dev up` again: the script detects the
newer sources and rebuilds.

### Ports

| Service | Host port | Container |
| --- | --- | --- |
| Back-end API | `8090` | `8080` |
| Postgres | `5434` | `5432` |
| Expo | `8083` | host process |

The non-default host ports avoid clashing with other local stacks that own
`5432`/`8080`. The back-end still reaches Postgres over the Compose network at
`db:5432`. Override them in `deploy/local/.env`:

```bash
cp deploy/local/.env.example deploy/local/.env
```

`.env` is git-ignored.

```env
BACKEND_HOST_PORT=8090
DB_HOST_PORT=5434
EXPO_PORT=8083
JWT_SECRET=dev-secret-do-not-use-in-prod-0123456789
```

### Prerequisites

- Docker with the Compose plugin.
- Java 21 and the Gradle wrapper available in `dmoney_back` (to build the jar).
- Node.js and npm (for Expo).
- `cloudflared` in `PATH`.
- The sibling repositories:

  ```text
  projects/dmoney/
    dmoney_back/
    dmoney_front/
    dmoney_platform/
  ```

### Configuration

Compose reads `JWT_SECRET` from the environment and supplies a stable
development default. Keep it stable so tokens survive back-end restarts.

| Variable | Overrides |
| --- | --- |
| `SPRING_DATASOURCE_URL` | `spring.datasource.url` |
| `SPRING_DATASOURCE_USERNAME` | `spring.datasource.username` |
| `SPRING_DATASOURCE_PASSWORD` | `spring.datasource.password` |
| `JWT_SECRET` | `jwt.secret` |

The `local` profile loads Liquibase with the `dev` context, so the test user and
its categories, tags and movements are seeded on the first start. The data
lives in the `dmoney-pgdata` volume and survives `dev down`.

### Manual pieces

If you need the services without Expo:

```bash
deploy/local/dev up
```

Then the API is at `http://localhost:8090`, the OpenAPI docs at
`http://localhost:8090/v3/api-docs`, and the quick-tunnel URL is printed and
stored in `deploy/local/.dev/api-url`.

To run Expo separately:

```bash
deploy/local/dev app
```

For the web build:

```bash
cd dmoney_front
EXPO_PUBLIC_API_URL=http://localhost:8090 npm run web
```

### Stop / reset

```bash
deploy/local/dev down     # stop containers and the tunnel, keep the DB
deploy/local/dev reset    # stop and wipe the DB volume
```

### Troubleshooting

- **The API tunnel URL changes.** Quick tunnels are ephemeral. The script
  injects the current URL into Expo, so run `deploy/local/dev` again after a
  tunnel restart. A stable URL requires a named Cloudflare tunnel and a domain.
- **A port is already in use.** Change `BACKEND_HOST_PORT`, `DB_HOST_PORT` or
  `EXPO_PORT` in `deploy/local/.env`, or stop the process that owns it.
- **The back-end container exits.** Check `deploy/local/dev logs`. The usual
  cause is a missing jar; the script builds it before starting Compose.
- **WSL runs out of memory.** Stop other Docker stacks before starting the
  dmoney one, or use `deploy/local/dev up` when you do not need the phone.
- **Expo Go reports an SDK mismatch.** The project is on SDK 58; update Expo Go.
