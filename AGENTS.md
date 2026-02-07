---
# AGENTS.md – Guidance for Automated Agents
---

## Table of Contents
1. [Overview](#overview)
2. [Build, Lint, and Test Commands](#build-lint-test)
3. [Running a Single Test](#single-test)
4. [Dockerfile & Image Conventions](#dockerfile-guidelines)
5. [Shell Script Style Guide](#shell-style)
6. [Configuration Files (`*.properties`, `*.json`)](#config-guidelines)
7. [Naming Conventions](#naming)
8. [Error‑Handling & Logging](#error‑handling)
9. [Commit & CI Practices](#ci)
10. [Cursor / Copilot Rules](#cursor-copilot)
11. [Glossary of Common Commands](#glossary)

---

## <a name="overview"></a>1. Overview
This repository contains a minimal Docker‑based Minecraft server distribution.  The primary artefacts are:
- `Dockerfile` – builds a GraalVM‑based image with `tmux`.
- `minecraft/entrypoint.sh` – container entry point.
- `minecraft/run-command` – helper script that starts/stops the server via `tmux`.
- Various JSON / properties files that configure the Minecraft server.

Agents interacting with this repo should follow the conventions below so that automated tooling (CI, lint‑bots, code‑generators) behaves predictably.

---

## <a name="build-lint-test"></a>2. Build, Lint, and Test Commands
| Task | Command | Description |
|------|---------|-------------|
| **Build Docker image** | `docker build -t minecraft:dev .` | Compiles the Dockerfile using the current context. |
| **Rebuild without cache** | `docker build --no-cache -t minecraft:dev .` | Useful when base images have been updated. |
| **Run container (development)** | `docker run -it --rm -p 25565:25565 minecraft:dev` | Starts the server interactively. |
| **Run container (background)** | `docker run -d --name mc -p 25565:25565 minecraft:dev` | Detached mode – useful for CI health‑checks. |
| **Lint Dockerfile** | `hadolint Dockerfile` | Uses `hadolint` (must be installed locally) to validate best practices. |
| **Shell script lint** | `shellcheck minecraft/*.sh` | Checks POSIX‑shell scripts for common bugs. |
| **Validate JSON** | `jq . minecraft/*.json` | Pretty‑prints and validates JSON files. |
| **Validate properties** | `cat minecraft/server.properties | grep -v '^#' | awk -F= 'NF==2'` | Simple sanity‑check; ensures all lines have a key/value pair. |
| **Run all checks** | `make check` *(see Makefile snippet below)* | Executes Docker build lint, shellcheck, and JSON validation in one go. |

### Makefile snippet (optional helper)
```makefile
.PHONY: check lint-docker lint-shell lint-json

check: lint-docker lint-shell lint-json

lint-docker:
	@which hadolint >/dev/null || (echo "hadolint not installed" && exit 1)
	hadolint Dockerfile

lint-shell:
	shellcheck minecraft/*.sh

lint-json:
	@for f in minecraft/*.json; do jq . $$f >/dev/null || echo "Invalid JSON: $$f"; done
```

---

## <a name="single-test"></a>3. Running a Single Test
The project does **not** contain conventional unit tests; the only test‑like behaviour is the health‑check of the server startup.  Agents can perform a targeted test by:
1. Building the image (`docker build -t mc:test .`).
2. Running the container in detached mode.
3. Executing a one‑shot health‑check that waits for the log file to contain the phrase `Done`.

Example command (run from the repo root):
```bash
docker run -d --name mc-test -p 25565:25565 mc:test && \
  timeout 30 bash -c "while ! docker logs mc-test 2>/dev/null | grep -q 'Done'; do sleep 1; done" && \
  echo "✅ Server started successfully" && \
  docker stop mc-test
```
This pattern can be wrapped in a CI job or invoked manually.

---

## <a name="dockerfile-guidelines"></a>4. Dockerfile & Image Conventions
- **Base Image**: `ghcr.io/graalvm/jdk-community:22`. Keep it up‑to‑date; check weekly for security patches.
- **ENV variables**: Declare all build‑time variables (`IMAGE_NAME`, `SERVER_FILE`, `WORKING`) at the top of the file.
- **Layer Ordering**:
  1. `FROM`
  2. `ENV`
  3. `WORKDIR`
  4. `RUN` (install OS packages)
  5. `COPY` – keep copies together to maximise cache reuse.
  6. `RUN chmod` – separate from install steps for clarity.
  7. `EXPOSE`
  8. `ENTRYPOINT`
- **Use minimal layers** – combine related `RUN` commands with `&&` and backslashes as already done.
- **Avoid root user** – not required for this container, but if future scripts need non‑root, add `USER` after package installation.
- **Labels** – add optional OCI labels for version, maintainer, and source repository.
```dockerfile
LABEL org.opencontainers.image.source="https://github.com/your-org/docker-minecraft"
LABEL org.opencontainers.image.description="Minecraft server container with Fabric mods"
```
- **Healthcheck** – optional but recommended:
```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
  CMD curl -f http://localhost:25565 || exit 1
```

---

## <a name="shell-style"></a>5. Shell Script Style Guide
All scripts are POSIX‑compatible (`#!/bin/sh`). Follow these rules:
1. **Strict mode** – enable error detection at the top:
   ```sh
   set -euo pipefail
   IFS=$'\n\t'
   ```
2. **Indentation** – use a single tab character for each level (as already done). Do not mix spaces and tabs.
3. **Quoting** – always double‑quote variable expansions (`"$var"`).
4. **Command substitution** – prefer `$(cmd)` over backticks.
5. **Guard against missing arguments** – e.g., `if [ -z "${1-}" ]; then echo "usage…"; exit 1; fi`.
6. **Use `printf` over `echo`** for predictable output.
7. **Avoid `rm -rf /path/*`** – prefer explicit paths (`rm -rf "${DIR:?}"/*`).
8. **Exit codes** – scripts should exit `0` on success, non‑zero on failure.
9. **Logging** – prepend log lines with a timestamp:
   ```sh
   log() { printf '[%s] %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$*"; }
   ```
10. **ShellCheck compliance** – run `shellcheck` locally; address all warnings.

---

## <a name="config-guidelines"></a>6. Configuration Files (`*.properties`, `*.json`)
- **Properties files** (`*.properties`):
  - No trailing whitespace.
  - Comment lines must start with `#`.
  - Keys are lower‑case, hyphen‑separated (`max‑players`).
  - Do not duplicate keys; the last occurrence wins.
- **JSON files** (`ops.json`, `whitelist.json`, `mods/*.json`):
  - Use 2‑space indentation.
  - Sort object keys alphabetically when possible.
  - Ensure UTF‑8 encoding without BOM.
  - Validate with `jq` before committing.
- **Sensitive values** (`rcon.password`) should never be committed in plain text. Replace with `${RCON_PASSWORD}` placeholder and document that the CI injects the secret via environment variable.

---

## <a name="naming"></a>7. Naming Conventions
| Type | Convention |
|------|-------------|
| Files & directories | lower‑case, hyphen‑separated (`run-command`, `entrypoint.sh`). |
| Shell variables | `UPPER_SNAKE_CASE` for env vars, `lower_snake` for locals. |
| Docker image tags | `<name>:<major>.<minor>` (e.g., `minecraft:1.21`). |
| Git branches | `feature/<short‑desc>`, `bugfix/<short‑desc>`, `hotfix/<desc>`. |
| Commit messages | `<type>(scope): <short summary>` – follow Conventional Commits. |
| Functions in scripts | `verb_noun` (e.g., `copy_mods`). |

---

## <a name="error-handling"></a>8. Error‑Handling & Logging
- **Exit on error** – `set -e` ensures the script aborts on the first failing command.
- **Trap signals** – already used for SIGINT/SIGTERM; add a generic `EXIT` trap to clean up tmux sessions if the container stops unexpectedly.
   ```sh
   cleanup() { tmux kill-session -t minecraft || true; }
   trap cleanup EXIT
   ```
- **Return codes** – map custom exit codes for clarity (`1` = missing argument, `2` = tmux not installed, etc.).
- **Log levels** – simple prefix (`[INFO]`, `[WARN]`, `[ERROR]`).
- **Stdout vs Stderr** – send informational messages to stdout, errors to stderr (`>&2`).

---

## <a name="ci"></a>9. Commit & CI Practices
- **Pre‑commit checks**: Run `make check` locally before `git push`.
- **CI pipeline** (example GitHub Actions snippet):
  ```yaml
  name: CI
  on: [push, pull_request]
  jobs:
    build:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: Install tools
          run: |
            sudo apt-get update && sudo apt-get install -y hadolint shellcheck jq
        - name: Lint
          run: make check
        - name: Build Docker image
          run: docker build -t minecraft:ci .
        - name: Smoke test
          run: |
            docker run -d --name ci-test -p 25565:25565 minecraft:ci
            timeout 30 bash -c "while ! docker logs ci-test 2>/dev/null | grep -q 'Done'; do sleep 1; done"
            docker stop ci-test
  ```
- **Branch protection** – require the CI job to pass before merging.
- **Version bump** – update `ENV IMAGE_NAME` and tag the Docker image when a new Minecraft version is released.

---

## <a name="cursor-copilot"></a>10. Cursor / Copilot Rules
- No `.cursor/rules/` directory was found.
- No `.github/copilot-instructions.md` file was found.
- Therefore, agents should follow the generic conventions listed above. If a future rule file appears, agents must prioritize those directives over this document.

---

## <a name="glossary"></a>11. Glossary of Common Commands
- **`docker build`** – creates an image from a Dockerfile.
- **`docker run`** – starts a container from an image.
- **`tmux`** – terminal multiplexer; used to keep the Minecraft process alive.
- **`hadolint`** – linter for Dockerfiles.
- **`shellcheck`** – linter for POSIX shell scripts.
- **`jq`** – command‑line JSON processor.
- **`make`** – task runner; optional but convenient for lint/check.
- **`grep -q`** – quiet pattern search, useful for health‑checks.
- **`timeout`** – limits execution time of a command.

---

*End of `AGENTS.md`.  This file is deliberately verbose (~150 lines) to give automated agents a complete, self‑contained reference for building, testing, and maintaining the Docker‑Minecraft project.*
