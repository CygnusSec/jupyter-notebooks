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
    && rm -rf /var/lib/apt/lists/*

# Mark all directories as safe for git
RUN git config --global --add safe.directory '*'

# Python packages & Jupyter extensions
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    jupyterlab \
    jupyterlab-git \
    jupyterlab-lsp \
    python-lsp-server[all] \
    jupyterlab_code_formatter \
    black \
    isort \
    jupyterlab-drawio \
    jupyterlab-execute-time \
    jupyter-resource-usage \
    jupyter-ai \
    jupyterlab-variableinspector \
    pygwalker \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn

# C/C++ Jupyter kernel (xeus-cling via conda)
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh -o /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh
ENV PATH="/opt/conda/bin:$PATH"
RUN conda install -y -c conda-forge xeus-cling r-irkernel r-base && \
    conda clean -afy
# Register xeus-cling kernels for Jupyter
RUN jupyter kernelspec install /opt/conda/share/jupyter/kernels/xcpp11 --sys-prefix && \
    jupyter kernelspec install /opt/conda/share/jupyter/kernels/xcpp14 --sys-prefix && \
    jupyter kernelspec install /opt/conda/share/jupyter/kernels/xcpp17 --sys-prefix
# Register R kernel
RUN Rscript -e "IRkernel::installspec(user = FALSE)"

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Show hidden files in JupyterLab file browser
RUN mkdir -p /root/.jupyter/lab/user-settings/@jupyterlab/filebrowser-extension && \
    echo '{"showHiddenFiles": true}' > /root/.jupyter/lab/user-settings/@jupyterlab/filebrowser-extension/browser.jupyterlab-settings

# Expose Jupyter port
EXPOSE 8888

# Start via entrypoint
CMD ["/entrypoint.sh"]
