# Base image
FROM python:3.10-slim

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Working directory
WORKDIR /app/notebooks

# System dependencies for scientific computing
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    libgomp1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    jupyterlab \
    jupyterlab-git \
    notebook \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn

# Expose Jupyter port
EXPOSE 8888

# Start JupyterLab (includes terminal, file browser, notebooks)
# Token is controlled by JUPYTER_TOKEN env var (empty = no auth)
CMD ["sh", "-c", "jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token=\"${JUPYTER_TOKEN:-}\""]
