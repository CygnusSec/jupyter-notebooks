# JupyterHub Self-Host

Multi-user JupyterLab environment with Docker. Each user gets an isolated container with pre-installed data science tools, C++/R kernels, and extensions.

## Architecture

```
Host Docker Daemon
├── jupyterhub          ← Auth + user management
├── jupyter-user-admin  ← Admin notebook container
├── jupyter-user-bob    ← User notebook container
└── jupyter-user-alice  ← User notebook container
```

- **JupyterHub** handles authentication and spawns user containers
- **User containers** are isolated JupyterLab instances with their own workspace
- Admin users have terminal access and can manage other users

## Prerequisites

- Docker ≥ 20.10
- Docker Compose ≥ 2.0

## Quick Start

### 1. Configure environment

```bash
cp .env.example .env
```

Edit `.env` — at minimum, change `ADMIN_PASSWORD`:

```env
ADMIN_USERS=admin
ADMIN_PASSWORD=your_strong_password
ALLOW_SIGNUP=true
```

### 2. Build the user notebook image

```bash
docker build -t jupyter-notebook-user:latest -f Dockerfile .
```

### 3. Create the network

```bash
docker network create jupyter-network
```

### 4. Start JupyterHub

```bash
docker compose up --build -d
```

### 5. Login

Open `http://localhost:8000` and login with:
- Username: `admin` (or whatever you set in `ADMIN_USERS`)
- Password: value of `ADMIN_PASSWORD` from `.env`

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `HUB_PORT` | `8000` | Port for JupyterHub web interface |
| `ADMIN_USERS` | `admin` | Comma-separated admin usernames |
| `ADMIN_PASSWORD` | _(empty)_ | Admin password (auto-created on first startup) |
| `ALLOW_SIGNUP` | `true` | Allow new user registration via `/hub/signup` |
| `USER_MEM_LIMIT` | `4G` | Memory limit per user container |
| `USER_CPU_LIMIT` | `2.0` | CPU limit per user container |
| `GITHUB_ACCESS_TOKEN` | _(empty)_ | GitHub token for jupyterlab-github extension |

## User Management

### Create users

**Option A** — Self-signup (when `ALLOW_SIGNUP=true`):
- Users visit `http://localhost:8000/hub/signup`
- Create username/password
- Login at `http://localhost:8000/hub/login`

**Option B** — Admin creates users:
- Login as admin → go to `http://localhost:8000/hub/admin`
- Click "Add Users"

### Lock registration

After initial setup, disable signup:

```env
ALLOW_SIGNUP=false
```

Then restart: `docker compose restart`

## Data Persistence

Each user gets a dedicated Docker volume (`jupyter-user-{username}`) mounted at `/app/workspace`. Data persists across container restarts and server stop/start.

Admin can backup volumes:
```bash
docker volume ls | grep jupyter-user
```

## Included Tools

### Kernels
- Python 3.10
- C++11 / C++14 / C++17 (xeus-cling)
- R

### Extensions
- LSP (autocomplete, go-to-definition)
- Code Formatter (black, isort)
- Execute Time
- Resource Usage
- Variable Inspector
- PyGWalker (visual data exploration)
- LaTeX rendering
- GitHub browser
- Jupyter AI
- Draw.io diagrams

### System Tools
- git, vim, nano
- cmake, gdb, clang, clang-format, valgrind
- Node.js, npm

## Stopping & Cleanup

Stop hub (user containers are auto-removed):
```bash
docker compose down
```

Remove hub data (resets users/passwords):
```bash
docker compose down -v
```

Remove all user workspace volumes:
```bash
docker volume ls | grep jupyter-user | awk '{print $2}' | xargs docker volume rm
```

## Reverse Proxy

JupyterHub runs on port 8000. Configure your reverse proxy (Nginx/Caddy/Traefik) to forward traffic:

```nginx
location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # WebSocket support (required for terminals and kernels)
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

## Rebuilding User Image

After modifying `Dockerfile` (adding packages, extensions):

```bash
docker build -t jupyter-notebook-user:latest -f Dockerfile .
```

Existing users need to stop/start their server (via Hub UI or admin panel) to get the new image.

## License

This project is licensed under the [MIT License](LICENSE).
