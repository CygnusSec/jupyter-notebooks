#!/bin/bash
set -e

# Create admin user if ADMIN_PASSWORD is set
python /srv/jupyterhub/create_admin.py || true

# Start JupyterHub
exec jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
