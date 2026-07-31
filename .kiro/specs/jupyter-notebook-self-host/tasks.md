# Implementation Plan: Jupyter Notebook Self-Host

## Overview

Tái cấu trúc repository từ project KKBOX Churn Prediction thành nền tảng Jupyter Notebook self-host thuần túy sử dụng Docker. Quá trình bao gồm xóa toàn bộ file KKBOX, tạo lại Dockerfile, docker-compose.yml, .env.example, README.md, .gitignore, và thư mục notebooks với notebook mẫu.

## Tasks

- [x] 1. Remove all KKBOX-specific files and directories
  - [x] 1.1 Delete the entire `data/` directory and all its contents (CSV, .npy, .pickle, .scala, .ipynb files and subdirectories: Final/, Processed/, chunk/, .ipynb_checkpoints/)
    - Remove data/ recursively
    - _Requirements: 1.1, 1.5_
  - [x] 1.2 Delete all KKBOX notebook files and scripts from `notebooks/` directory
    - Remove: 00_Memory_Optimization_Helper.ipynb, Exploration_data_analysis.ipynb, Preprocessing.ipynb, Training_model.ipynb, Training_model_advanced.ipynb, Training_model_lite.ipynb, create_monthly_labels.py
    - Remove: notebooks/.DS_Store, notebooks/.ipynb_checkpoints/ directory
    - _Requirements: 1.2, 1.4_
  - [x] 1.3 Delete KKBOX documentation files
    - Remove: INDEX.md, PROJECT_SUMMARY.txt, QUICKSTART.md, SUMMARY.md
    - Remove: notebooks/docs/ directory and all its contents
    - _Requirements: 1.3_
  - [x] 1.4 Delete root-level OS artifacts and remaining checkpoint directories
    - Remove: .DS_Store at repository root
    - Verify no .ipynb_checkpoints or .DS_Store remain anywhere
    - _Requirements: 1.4, 1.5_

- [x] 2. Checkpoint - Verify cleanup is complete
  - Ensure no KKBOX files remain. Verify retained files exist: Dockerfile, docker-compose.yml, README.md, .gitignore. Ask the user if questions arise.

- [x] 3. Rewrite Dockerfile for generic Jupyter Notebook
  - [x] 3.1 Rewrite Dockerfile with Python 3.10-slim base, core data science libraries, and Jupyter startup command
    - Base image: python:3.10-slim
    - WORKDIR /app/notebooks
    - Install system dependencies (build-essential, gcc, g++, libgomp1)
    - Install pip packages: notebook, pandas, numpy, matplotlib, seaborn, scikit-learn
    - EXPOSE 8888
    - CMD: jupyter notebook with --ip=0.0.0.0, --port=8888, --no-browser, --allow-root, --NotebookApp.token=''
    - NO COPY or ADD instructions for application code
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_

- [x] 4. Rewrite docker-compose.yml with environment variable substitution
  - [x] 4.1 Rewrite docker-compose.yml with single "jupyter" service, env var substitution, volume mount, and resource limits
    - Service name: jupyter
    - Port mapping: ${JUPYTER_PORT:-8888}:8888
    - Volume: ./notebooks:/app/notebooks
    - Deploy resources: cpus ${CPU_LIMIT:-4.0}, memory ${MEMORY_LIMIT:-8G}
    - shm_size: ${SHM_SIZE:-2gb}
    - Environment variables: JUPYTER_ENABLE_LAB=yes, PYTHONUNBUFFERED=1, JUPYTER_IOPUB_DATA_RATE_LIMIT=10000000000, JUPYTER_IOPUB_MSG_RATE_LIMIT=100000
    - restart: unless-stopped
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.3, 4.4_

- [x] 5. Create .env.example with all configurable parameters
  - [x] 5.1 Create .env.example file with documented parameters and inline comments
    - Parameters: JUPYTER_PORT=8888, CPU_LIMIT=4.0, MEMORY_LIMIT=8G, SHM_SIZE=2gb, JUPYTER_TOKEN=
    - Include inline comments describing each parameter's purpose and valid value format
    - _Requirements: 4.1, 4.2_

- [x] 6. Rewrite README.md as deployment guide
  - [x] 6.1 Rewrite README.md with all required sections: prerequisites, deployment, configuration, access, persistence, stopping/cleanup
    - Title & description section
    - Prerequisites: Docker ≥ 20.10, Docker Compose ≥ 2.0
    - Deployment commands: docker compose up --build
    - Configuration table: all env vars from .env.example with defaults and descriptions
    - Accessing Jupyter: http://localhost:8888, token configuration
    - Data persistence: volume mount explanation (./notebooks:/app/notebooks), restart behavior
    - Stopping & cleanup: docker compose down, docker compose down -v
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

- [x] 7. Rewrite .gitignore for Jupyter self-host project
  - [x] 7.1 Rewrite .gitignore with patterns for Jupyter, Python, environment, data files, and OS artifacts
    - .ipynb_checkpoints/
    - __pycache__/, *.py[cod], *$py.class
    - .env (but NOT .env.example)
    - *.csv, *.npy, *.pickle, *.h5, *.zip, *.gz
    - env/, venv/
    - .DS_Store, Thumbs.db
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [x] 8. Create notebooks/ directory with .gitkeep and hello.ipynb
  - [x] 8.1 Create notebooks/.gitkeep file to preserve directory in version control
    - _Requirements: 7.1_
  - [x] 8.2 Create notebooks/hello.ipynb sample notebook with a single code cell printing "Hello, Jupyter!"
    - Minimal valid .ipynb JSON format
    - One markdown cell: "# Hello, Jupyter!" with setup verification description
    - One code cell: print("Hello, Jupyter!")
    - _Requirements: 7.2_

- [x] 9. Final checkpoint - Verify complete project structure
  - Ensure final file structure matches design: .env.example, .gitignore, Dockerfile, docker-compose.yml, README.md, notebooks/.gitkeep, notebooks/hello.ipynb. Ask the user if questions arise.

## Notes

- This is a purely infrastructure/configuration project — no application code or testable functions
- Property-based testing does NOT apply; verification is via manual checklist and smoke tests
- All configuration uses Docker Compose variable substitution with sensible defaults
- The .env file is optional — docker-compose.yml works without it via ${VAR:-default} syntax
- Checkpoints ensure incremental validation of cleanup and final structure

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4"] },
    { "id": 1, "tasks": ["3.1", "7.1"] },
    { "id": 2, "tasks": ["4.1", "5.1", "8.1", "8.2"] },
    { "id": 3, "tasks": ["6.1"] }
  ]
}
```
