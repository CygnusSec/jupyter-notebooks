# Requirements Document

## Introduction

Dự án này nhằm tái cấu trúc repository hiện tại thành một môi trường Jupyter Notebook self-host thuần túy, sử dụng Docker để triển khai. Tất cả các file, dữ liệu, notebook và tài liệu liên quan đến project KKBOX Churn Prediction sẽ bị loại bỏ. Kết quả là một nền tảng Jupyter Notebook generic, dễ cấu hình và triển khai cho bất kỳ project nào.

## Glossary

- **Jupyter_Server**: Container Docker chạy Jupyter Notebook server, lắng nghe trên cổng được cấu hình
- **Docker_Image**: Image Docker được build từ Dockerfile, chứa Python runtime và Jupyter Notebook
- **Compose_Stack**: Tập hợp services được định nghĩa trong docker-compose.yml để orchestrate việc triển khai
- **Workspace**: Thư mục được mount vào container để người dùng lưu trữ và chỉnh sửa notebook
- **Environment_Config**: File cấu hình (.env) cho phép người dùng tùy chỉnh các tham số triển khai

## Requirements

### Requirement 1: Loại bỏ toàn bộ nội dung KKBOX

**User Story:** Là một developer, tôi muốn loại bỏ tất cả file liên quan đến project KKBOX, để repository chỉ chứa hạ tầng Jupyter Notebook self-host.

#### Acceptance Criteria

1. WHEN the cleanup is performed, THE Workspace SHALL NOT contain any files within the `data/` directory, including all CSV files, .npy files, .pickle files, .scala files, and .ipynb files in that directory and its subdirectories
2. WHEN the cleanup is performed, THE Workspace SHALL NOT contain any .ipynb notebook files or .py script files within the `notebooks/` directory that relate to KKBOX churn prediction (including but not limited to: Exploration_data_analysis.ipynb, Preprocessing.ipynb, Training_model.ipynb, Training_model_advanced.ipynb, Training_model_lite.ipynb, 00_Memory_Optimization_Helper.ipynb, and create_monthly_labels.py)
3. WHEN the cleanup is performed, THE Workspace SHALL NOT contain the following documentation files: INDEX.md, PROJECT_SUMMARY.txt, QUICKSTART.md, SUMMARY.md, and the entire `notebooks/docs/` directory with all its contents
4. WHEN the cleanup is performed, THE Workspace SHALL NOT contain any `.ipynb_checkpoints` directories or `.DS_Store` files anywhere in the repository
5. WHEN the cleanup is performed, THE Workspace SHALL NOT contain any empty directories that previously held KKBOX content (including `data/`, `data/Final/`, `data/Processed/`, `data/chunk/`, and `notebooks/` if empty after file removal)
6. WHEN the cleanup is performed, THE Workspace SHALL retain the Jupyter Notebook infrastructure files: Dockerfile, docker-compose.yml, README.md, and .gitignore

### Requirement 2: Dockerfile generic cho Jupyter Notebook

**User Story:** Là một developer, tôi muốn có một Dockerfile generic cài đặt Jupyter Notebook với các thư viện data science phổ biến, để tôi có thể dùng cho bất kỳ project nào.

#### Acceptance Criteria

1. THE Docker_Image SHALL use Python 3.10-slim as the base image
2. THE Docker_Image SHALL install Jupyter Notebook (notebook package)
3. THE Docker_Image SHALL install the following data science libraries: pandas, numpy, matplotlib, seaborn, scikit-learn
4. THE Docker_Image SHALL expose port 8888 for the Jupyter Notebook server
5. WHEN the container starts, THE Jupyter_Server SHALL launch in no-browser mode, bind to all interfaces (0.0.0.0), allow root execution, and disable token-based authentication (empty token)
6. THE Docker_Image SHALL NOT contain any application source code, notebooks, or dataset files copied via COPY or ADD instructions; project files SHALL be provided exclusively through volume mounts at runtime
7. THE Docker_Image SHALL define a working directory (WORKDIR) where volume-mounted notebooks and data will be accessible

### Requirement 3: Docker Compose cho triển khai đơn giản

**User Story:** Là một developer, tôi muốn sử dụng docker-compose để khởi chạy Jupyter Notebook với một lệnh duy nhất, để việc triển khai nhanh và nhất quán.

#### Acceptance Criteria

1. THE Compose_Stack SHALL define a single service named "jupyter" for the Jupyter Notebook server
2. THE Compose_Stack SHALL map port ${JUPYTER_PORT:-8888} on the host to port 8888 in the container
3. THE Compose_Stack SHALL mount a local "notebooks" directory into the container at /app/notebooks as the working directory for Jupyter
4. THE Compose_Stack SHALL configure CPU limit (default: 4.0 cores) and memory limit (default: 8G) via deploy.resources.limits
5. THE Compose_Stack SHALL set shared memory size (shm_size) to 2gb by default to support large dataset operations
6. THE Compose_Stack SHALL set environment variables: JUPYTER_ENABLE_LAB=yes, PYTHONUNBUFFERED=1, JUPYTER_IOPUB_DATA_RATE_LIMIT=10000000000, JUPYTER_IOPUB_MSG_RATE_LIMIT=100000

### Requirement 4: File cấu hình môi trường

**User Story:** Là một developer, tôi muốn có file .env mẫu để dễ dàng tùy chỉnh các tham số triển khai (port, CPU limit, memory limit, token) mà không phải sửa docker-compose.yml.

#### Acceptance Criteria

1. THE Environment_Config SHALL provide a sample .env.example file containing the following parameters with documented default values: JUPYTER_PORT (default: 8888), CPU_LIMIT (default: 4.0), MEMORY_LIMIT (default: 8G), SHM_SIZE (default: 2gb), and JUPYTER_TOKEN (default: empty string)
2. THE Environment_Config SHALL include inline comments in the .env.example file describing each parameter's purpose and valid value format (port: integer 1024–65535, CPU_LIMIT: decimal number 0.5–16.0, MEMORY_LIMIT: integer followed by G or M, SHM_SIZE: integer followed by g/m, JUPYTER_TOKEN: alphanumeric string or empty for no authentication)
3. THE Compose_Stack SHALL reference variables from the .env file using Docker Compose variable substitution syntax with default values (e.g., ${VARIABLE:-default}) for port mapping, deploy resource limits, and shm_size
4. WHEN the .env file is not present, THE Compose_Stack SHALL use the following default values via variable substitution defaults: JUPYTER_PORT=8888, CPU_LIMIT=4.0, MEMORY_LIMIT=8G, SHM_SIZE=2gb, JUPYTER_TOKEN='' (empty string)

### Requirement 5: Tài liệu hướng dẫn triển khai

**User Story:** Là một developer, tôi muốn có README hướng dẫn rõ ràng cách triển khai và sử dụng Jupyter Notebook self-host, để người dùng mới có thể bắt đầu nhanh chóng.

#### Acceptance Criteria

1. THE README.md SHALL contain a prerequisites section listing required software (Docker, Docker Compose) and their minimum supported versions
2. THE README.md SHALL contain a deployment section that includes the exact shell commands to build the Docker image and start the Jupyter Notebook server using Docker Compose (including `docker compose up --build`)
3. THE README.md SHALL document all configurable environment variables defined in .env.example with their default values and a one-sentence description of each
4. THE README.md SHALL include instructions for accessing the Jupyter Notebook interface after deployment, specifying the default URL (http://localhost:8888) and the token authentication configuration
5. THE README.md SHALL include instructions for stopping and removing the container, specifying the exact shell commands (`docker compose down`) and the command to remove associated volumes (`docker compose down -v`)
6. THE README.md SHALL include a section on data persistence that documents volume mounts (./notebooks:/app/notebooks) and explains that files stored in these directories persist across container restarts
7. WHEN a user follows all steps in the README.md sequentially from a machine meeting the documented prerequisites, THE deployment process SHALL result in a running Jupyter Notebook server accessible at the documented URL within 5 minutes (excluding image download time)

### Requirement 6: Gitignore phù hợp

**User Story:** Là một developer, tôi muốn có file .gitignore phù hợp với project Jupyter Notebook self-host, để không track các file không cần thiết.

#### Acceptance Criteria

1. THE Workspace SHALL contain a .gitignore file at the repository root that excludes all `.ipynb_checkpoints/` directories at any depth in the project tree
2. THE .gitignore SHALL exclude the `.env` file from version control AND SHALL NOT contain any pattern that excludes `.env.example`
3. THE .gitignore SHALL exclude `__pycache__/` directories at any depth and all files matching `*.py[cod]` and `*$py.class` patterns
4. THE .gitignore SHALL exclude `.DS_Store` and `Thumbs.db` OS-generated files
5. THE .gitignore SHALL exclude data files matching the following extensions: `*.csv`, `*.npy`, `*.pickle`, `*.h5`, `*.zip`, and `*.gz`
6. THE .gitignore SHALL exclude Python virtual environment directories matching `env/` and `venv/` patterns

### Requirement 7: Thư mục notebooks mặc định

**User Story:** Là một developer, tôi muốn có thư mục notebooks sẵn với một notebook mẫu, để người dùng biết nơi đặt notebook và có thể verify hệ thống hoạt động.

#### Acceptance Criteria

1. THE Workspace SHALL contain a "notebooks" directory with a .gitkeep file to preserve it in version control
2. THE Workspace SHALL contain a sample notebook (notebooks/hello.ipynb) that contains a single code cell printing "Hello, Jupyter!" to verify the setup works correctly
