# Laravel Runtime

A project-independent Laravel Sail runtime. Manages multiple Laravel projects through a single shared Docker environment
with automatic service discovery and compose merging.

## Prerequisites

* Bash
* Docker installed and running

## Installation

1. Clone this repository anywhere on your machine.
   > On WSL, avoid cloning under `/mnt` for performance reasons.
2. Copy `.env.example` to `.env` and adjust settings.
3. Run `install.sh` to install and register the runtime in your `~/.bashrc`.

## Adding a Site

1. From your project directory, run `sail-setup` to interactively select services and create a site configuration under
   `sites/`.
2. Run `sail up -d` to start your project.

The runtime resolves your project path automatically to find its site configuration.

## Runtime Services

Located in `runtime/`, selectable per site via `sail-setup`:

- MySQL
- Redis
- Mailpit

## Configuration

### Runtime `.env`

| Variable                     | Description                            |
|------------------------------|----------------------------------------|
| `PHP_VERSION`                | PHP version for the Sail container     |
| `SAIL_INSTALL_CLAUDE_CODE`   | Install Claude CLI in container        |
| `SAIL_INSTALL_GEMINI_CLI`    | Install Gemini CLI in container        |
| `SAIL_INSTALL_PAPLAY`        | Install PulseAudio utilities           |
| `SAIL_INSTALL_PDFTOTEXT`     | Install PDF text extraction tools      |
| `MYSQL_CREATE_TEST_DATABASE` | Auto-create a test database on startup |

Located in `services/`, toggled via `.env`:

| Service                   | `.env` Flag                     | Description                                                         |
|---------------------------|---------------------------------|---------------------------------------------------------------------|
| **local-proxy**           | `SERVICE_LOCAL_PROXY`           | Nginx reverse proxy for `*.local` domains                           |
| **llm-proxy**             | `SERVICE_LLM_PROXY`             | LiteLLM gateway for LLM API routing                                 |
| **update-wsl-hosts-file** | `SERVICE_UPDATE_WSL_HOSTS_FILE` | Syncs Docker hosts to Windows hosts file (WSL only, requires admin) |

### Conditional Feature Compose Files

Feature-specific compose and install files are auto-discovered from `runtime/{service}/{feature}/`.
A feature is included when its corresponding env var is set to `true` in `.env`.

The env var name is derived from the path: `{SERVICE}_{FEATURE}`, uppercased with dashes replaced by underscores.

| Directory | Env var |
|-----------|---------|
| `runtime/sail/install-claude-code/` | `SAIL_INSTALL_CLAUDE_CODE` |
| `runtime/sail/install-gemini-cli/` | `SAIL_INSTALL_GEMINI_CLI` |
| `runtime/sail/install-paplay/` | `SAIL_INSTALL_PAPLAY` |
| `runtime/sail/install-pdftotext/` | `SAIL_INSTALL_PDFTOTEXT` |
| `runtime/mysql/create-test-database/` | `MYSQL_CREATE_TEST_DATABASE` |

Each feature directory can contain:

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Merged into the compose configuration |
| `install.sh` | Build-time install script (sail features) |

To add a new feature: create `runtime/{service}/{feature}/` with a `docker-compose.yml` and add `{SERVICE}_{FEATURE}=true` to `.env`.

### Site Configuration

Each site directory under `sites/` can contain:

| File                          | Purpose                                     |
|-------------------------------|---------------------------------------------|
| `.sail-services`              | Selected services (one per line)            |
| `docker-compose.override.yml` | Overrides merged with runtime service files |
| `docker-compose.custom.yml`   | Full custom compose (replaces all merging)  |

## PHPStorm Integration

1. Open **Settings > PHP > CLI Interpreter**.
2. Add a new **Docker Compose** interpreter.
3. Select the appropriate server type (e.g. **WSL** on Windows, **Docker** on Linux/macOS).
4. Point to the `docker-compose.yml` in your site's directory under `sites/`.
5. Select the `laravel.test` service.
6. Set lifecycle to *Connect to existing container*.
7. (Optional) Use `sail-php` as the PHP executable to run as the sail user.
