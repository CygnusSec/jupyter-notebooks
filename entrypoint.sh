#!/bin/bash
set -e

# Ensure git is configured for the workspace
git config --global --add safe.directory '*'
git config --global init.defaultBranch main

# Start JupyterLab
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --ServerApp.token="${JUPYTER_TOKEN:-}" \
    --ServerApp.root_dir=/app/workspace \
    --ServerApp.terminado_settings='{"shell_command": ["/bin/bash"]}'
