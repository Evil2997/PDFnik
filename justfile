set dotenv-load
set shell := ["bash", "-cu"]

green  := '\033[0;32m'
yellow := '\033[0;33m'
red    := '\033[0;31m'
reset  := '\033[0m'

# Default: show help
default: help

# List all available commands
help:
    @just --list

# Initialize submodules and .env (idempotent)
init:
    #!/usr/bin/env bash
    set -euo pipefail
    which git > /dev/null || { printf '\033[0;31m✗ git not found\033[0m\n'; exit 1; }
    printf '\033[0;33m→ Checking submodules...\033[0m\n'
    if [ -f .gitmodules ]; then
        git submodule update --init --recursive
        printf '\033[0;32m✓ Submodules ready\033[0m\n'
    else
        printf '\033[0;33m⚠  .gitmodules not found — run: just submodule-add\033[0m\n'
    fi
    if [ ! -f .env ]; then
        cp .env.example .env
        printf '\033[0;33m⚠  .env created from .env.example — fill in BOT_TOKEN and secrets\033[0m\n'
    else
        printf '\033[0;32m✓ .env already exists\033[0m\n'
    fi

# Register GitHub repos as git submodules (run once)
submodule-add:
    #!/usr/bin/env bash
    set -euo pipefail
    which git > /dev/null || { printf '\033[0;31m✗ git not found\033[0m\n'; exit 1; }
    git submodule add https://github.com/Evil2997/PDFnik-Backend PDFnik-Backend
    git submodule add https://github.com/Evil2997/PDFnik-TelegramBot PDFnik-TelegramBot
    git submodule add https://github.com/Evil2997/PDFnik-Schemes PDFnik-Schemes
    git submodule add https://github.com/Evil2997/PDFnik-files_cleaner PDFnik-files_cleaner
    git submodule update --init --recursive
    printf '\033[0;32m✓ Submodules registered\033[0m\n'

# Start all services in detached mode
up:
    docker compose up -d
    @printf "{{green}}✓ Services started{{reset}}\n"

# Stop all services
down:
    docker compose down

# Stop then start all services
restart: down up

# Follow logs from all services (Ctrl-C to stop)
logs:
    docker compose logs -f

# Rebuild all images without cache
build:
    docker compose build --no-cache
    @printf "{{green}}✓ Images built{{reset}}\n"

# Run unit tests in all submodules that have tests/
test:
    #!/usr/bin/env bash
    which uv > /dev/null || { printf '\033[0;31m✗ uv not found — install: curl -LsSf https://astral.sh/uv/install.sh | sh\033[0m\n'; exit 1; }
    printf '\033[0;33m→ Running tests...\033[0m\n'
    failed=0
    for dir in PDFnik-Backend PDFnik-TelegramBot; do
        if [ -d "$dir/tests" ]; then
            printf '\033[0;33m→ %s\033[0m\n' "$dir"
            (cd "$dir" && uv run pytest tests/unit -q) \
                && printf '\033[0;32m✓ %s passed\033[0m\n' "$dir" \
                || { printf '\033[0;31m✗ %s failed\033[0m\n' "$dir"; failed=1; }
        fi
    done
    exit $failed

# Pull latest changes in root and all submodules
update:
    git pull
    git submodule update --remote --merge
    @printf "{{green}}✓ All up to date{{reset}}\n"

# Stop services + volumes, remove __pycache__ and .pyc
clean:
    #!/usr/bin/env bash
    docker compose down --volumes
    find . -type d -name __pycache__ -not -path './.venv/*' -exec rm -rf {} + 2>/dev/null || true
    find . -name '*.pyc' -not -path './.venv/*' -delete 2>/dev/null || true
    printf '\033[0;32m✓ Cleaned\033[0m\n'

# Show git status in root and each submodule
status:
    #!/usr/bin/env bash
    printf '\033[0;33m→ Root:\033[0m\n'
    git status --short
    for dir in PDFnik-Backend PDFnik-TelegramBot PDFnik-Schemes PDFnik-files_cleaner; do
        if [ -d "$dir/.git" ]; then
            printf '\033[0;33m→ %s:\033[0m\n' "$dir"
            git -C "$dir" status --short
        fi
    done
