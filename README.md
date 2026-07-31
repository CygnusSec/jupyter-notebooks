# Jupyter Notebook Self-Host

A Docker-based self-hosted Jupyter Notebook environment for data science and development work.

## Prerequisites

- **Docker** ≥ 20.10
- **Docker Compose** ≥ 2.0

## Quick Start / Deployment

Build the image and start the Jupyter Notebook server:

```bash
docker compose up --build
```

Expected output:

```
[+] Building ...
[+] Running 1/1
 ✔ Container jupyter-notebook  Created
Attaching to jupyter-notebook
jupyter-notebook  | [I ... NotebookApp] Jupyter Notebook is running at:
jupyter-notebook  | [I ... NotebookApp] http://0.0.0.0:8888/
```

To run in detached mode (background):

```bash
docker compose up --build -d
```

## Configuration

All parameters are configurable via a `.env` file. Copy the example and modify as needed:

```bash
cp .env.example .env
```

| Variable | Default | Description |
|----------|---------|-------------|
| `JUPYTER_PORT` | `8888` | Host port for the Jupyter web interface (valid: 1024–65535) |
| `CPU_LIMIT` | `4.0` | CPU core limit for the container (valid: 0.5–16.0) |
| `MEMORY_LIMIT` | `8G` | Memory limit for the container (valid: integer + G or M, e.g., `8G`, `4096M`) |
| `SHM_SIZE` | `2gb` | Shared memory size — prevents kernel crashes with large datasets (valid: integer + g or m, e.g., `2gb`, `512mb`) |
| `JUPYTER_TOKEN` | _(empty)_ | Authentication token. Empty means no password protection — use only in trusted networks |

The `.env` file is optional. If absent, Docker Compose uses the defaults shown above via `${VAR:-default}` substitution in `docker-compose.yml`.

## Accessing Jupyter

Once the container is running, open your browser and navigate to:

```
http://localhost:8888
```

If you changed `JUPYTER_PORT` in your `.env` file, use that port instead (e.g., `http://localhost:9999`).

**Token authentication:** By default, no token is required. To enable token-based authentication, set `JUPYTER_TOKEN` in your `.env` file to any alphanumeric string, then access Jupyter at `http://localhost:8888/?token=<your-token>`.

## Data Persistence

Notebooks and data are stored on your host machine via a volume mount:

```
./notebooks:/app/notebooks
```

This means:

- Files created or modified in the Jupyter interface are saved to the `./notebooks/` directory on your host.
- Files you place in `./notebooks/` on the host are immediately available inside Jupyter.
- Your work **persists across container restarts** — stopping and restarting the container does not delete your files.

The container uses `restart: unless-stopped`, so it will automatically restart after host reboots unless explicitly stopped.

## Stopping & Cleanup

Stop and remove the container:

```bash
docker compose down
```

Stop and remove the container **and** its associated volumes:

```bash
docker compose down -v
```

> **Note:** `docker compose down` does not delete files in `./notebooks/` — those remain on your host. The `-v` flag only removes Docker-managed volumes.

## Customization

### Adding Python packages

To install additional packages, edit the `Dockerfile` and add them to the `pip install` command:

```dockerfile
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    notebook \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn \
    # Add your packages below
    scipy \
    plotly
```

Then rebuild:

```bash
docker compose up --build
```

### Extending the Dockerfile

You can add system-level dependencies or additional configuration:

```dockerfile
# Example: add LaTeX support for matplotlib
RUN apt-get update && apt-get install -y \
    texlive-xetex \
    && rm -rf /var/lib/apt/lists/*
```

Rebuild after any Dockerfile changes with `docker compose up --build`.
