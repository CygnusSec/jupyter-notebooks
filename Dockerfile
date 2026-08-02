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
    vim \
    nano \
    cmake \
    gdb \
    clang \
    clang-format \
    valgrind \
    texlive-xetex \
    texlive-fonts-recommended \
    latexmk \
    && rm -rf /var/lib/apt/lists/*

# Mark all directories as safe for git
RUN git config --global --add safe.directory '*'

# Install conda (for C++ and R kernels)
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh -o /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh
ENV PATH="/opt/conda/bin:$PATH"

# Install C++ and R kernels via conda (also install jupyter in conda for kernelspec)
RUN conda install -y -c conda-forge xeus-cling r-irkernel r-base jupyter && \
    conda clean -afy

# xeus-cling kernels are auto-registered by conda, no manual install needed

# Register R kernel
RUN Rscript -e "IRkernel::installspec(user = FALSE)"

# Python packages, JupyterLab & extensions (installed AFTER conda to ensure pip jupyter wins)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    jupyterlab \
    jupyterlab-lsp \
    python-lsp-server[all] \
    jupyterlab_code_formatter \
    black \
    isort \
    jupyterlab-drawio \
    jupyterlab-execute-time \
    jupyter-resource-usage \
    jupyter-ai \
    lckr-jupyterlab-variableinspector \
    pygwalker \
    jupyterlab-latex \
    jupyterlab-github \
    jupyterhub \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn

# Verify extensions are registered
RUN jupyter server extension list

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Show hidden files & allow server to serve them
# Production hardening config
RUN mkdir -p /root/.jupyter/lab/user-settings/\@jupyterlab/filebrowser-extension && \
    echo '{"showHiddenFiles": true}' > /root/.jupyter/lab/user-settings/\@jupyterlab/filebrowser-extension/browser.jupyterlab-settings && \
    mkdir -p /root/.jupyter/lab/user-settings/\@jupyterlab/extensionmanager-extension && \
    echo '{"enabled": false}' > /root/.jupyter/lab/user-settings/\@jupyterlab/extensionmanager-extension/plugin.jupyterlab-settings && \
    mkdir -p /root/.jupyter && \
    cat > /root/.jupyter/jupyter_server_config.py << 'EOF'
# === Production Hardening ===

# Allow hidden files in file browser
c.ContentsManager.allow_hidden = True

# Disable Extension Manager UI (prevent installing untrusted extensions at runtime)
c.LabApp.extensions_in_dev_mode = False

# Disable open-in-new-browser-tab behavior
c.ServerApp.open_browser = False

# Trust all origins (handled by reverse proxy)
c.ServerApp.allow_origin = '*'

# Disable XSRF for API behind reverse proxy (if needed)
# c.ServerApp.disable_check_xsrf = True

# Rate limiting
c.ServerApp.iopub_data_rate_limit = 10000000000
c.ServerApp.iopub_msg_rate_limit = 100000
EOF

# Expose Jupyter port
EXPOSE 8888

# Start via entrypoint
CMD ["/entrypoint.sh"]
