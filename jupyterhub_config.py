import os

# === Spawner: Docker ===
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
c.DockerSpawner.image = os.environ.get('DOCKER_NOTEBOOK_IMAGE', 'jupyter-notebook-user:latest')
c.DockerSpawner.network_name = os.environ.get('DOCKER_NETWORK_NAME', 'jupyter-network')
c.DockerSpawner.remove = True  # Remove container when user stops

# Mount user workspace (each user gets their own directory)
c.DockerSpawner.volumes = {
    'jupyter-user-{username}': '/app/workspace',
}

# Resource limits per user
c.DockerSpawner.mem_limit = os.environ.get('USER_MEM_LIMIT', '4G')
c.DockerSpawner.cpu_limit = float(os.environ.get('USER_CPU_LIMIT', '2.0'))

# Environment for spawned containers
c.DockerSpawner.environment = {
    'GIT_DISCOVERY_ACROSS_FILESYSTEM': '1',
    'JUPYTER_ENABLE_LAB': 'yes',
}

# === Authentication ===
# Native authenticator (username/password)
c.JupyterHub.authenticator_class = 'nativeauthenticator.NativeAuthenticator'
c.NativeAuthenticator.open_signup = True  # Allow signup
c.NativeAuthenticator.ask_email_on_signup = False

# Admin users (have terminal access + manage other users)
# First admin must signup, then set open_signup=False after setup
c.Authenticator.admin_users = set(os.environ.get('ADMIN_USERS', 'admin').split(','))
c.JupyterHub.admin_access = True

# Admin can create/manage users via /hub/admin
# After initial setup, set ALLOW_SIGNUP=false to lock registration
if os.environ.get('ALLOW_SIGNUP', 'true').lower() == 'false':
    c.NativeAuthenticator.open_signup = False

# === Hub Settings ===
c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.hub_port = 8081
c.JupyterHub.bind_url = 'http://0.0.0.0:8000'

# Hub must be accessible from spawned containers
c.JupyterHub.hub_connect_ip = 'jupyterhub'

# === Security ===
c.JupyterHub.cookie_secret_file = '/srv/jupyterhub/cookie_secret'
c.JupyterHub.db_url = '/srv/jupyterhub/jupyterhub.sqlite'

# Shutdown idle servers after 1 hour
c.JupyterHub.services = []
c.ServerApp.shutdown_no_activity_timeout = 3600
