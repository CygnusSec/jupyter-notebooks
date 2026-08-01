#!/bin/bash
set -e

# Copy host gitconfig if available (mounted read-only at /etc/gitconfig.host)
if [ -f /etc/gitconfig.host ]; then
    cp /etc/gitconfig.host /root/.gitconfig
fi

# Ensure git trusts all directories (required for Docker volume ownership)
git config --global --add safe.directory '*'
git config --global init.defaultBranch main

# Configure GitHub token for jupyterlab-github extension
if [ -n "${GITHUB_ACCESS_TOKEN:-}" ]; then
    echo "c.GitHubConfig.access_token = '${GITHUB_ACCESS_TOKEN}'" >> /root/.jupyter/jupyter_server_config.py
fi

# Start JupyterLab
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --ServerApp.token="${JUPYTER_TOKEN:-}" \
    --ServerApp.root_dir=/app/workspace \
    --ServerApp.terminado_settings='{"shell_command": ["/bin/bash"]}'
