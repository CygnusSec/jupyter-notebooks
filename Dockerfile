# Base image
FROM python:3.10-slim

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV SHELL=/bin/bash
ENV GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# Working directory
WORKDIR /app/workspace

# System dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    libgomp1 \
    git \
    bash \
    curl \
    procps \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Mark all directories as safe for git
RUN git config --global --add safe.directory '*'

# Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    jupyterlab \
    jupyterlab-git \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Jupyter port
EXPOSE 8888

# Start via entrypoint
CMD ["/entrypoint.sh"]
