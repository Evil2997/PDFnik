# PDFnik — monorepo task runner
# Usage: make <target>  |  make help

GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
RESET  := \033[0m

.PHONY: help init submodule-add up down restart logs build test update clean status

help: ## List all available commands
	@echo "PDFnik — available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-14s$(RESET) %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Prereq checks (internal, not shown in help)
# ---------------------------------------------------------------------------

_check_git:
	@which git > /dev/null 2>&1 || \
		(printf "$(RED)✗ git not found$(RESET)\n" && exit 1)

_check_docker:
	@which docker > /dev/null 2>&1 || \
		(printf "$(RED)✗ docker not found$(RESET)\n" && exit 1)
	@docker compose version > /dev/null 2>&1 || \
		(printf "$(RED)✗ docker compose plugin not found$(RESET)\n" && exit 1)

_check_uv:
	@which uv > /dev/null 2>&1 || \
		(printf "$(RED)✗ uv not found — install: curl -LsSf https://astral.sh/uv/install.sh | sh$(RESET)\n" && exit 1)

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

init: _check_git ## Initialize submodules and .env (idempotent)
	@printf "$(YELLOW)→ Checking submodules...$(RESET)\n"
	@if [ -f .gitmodules ]; then \
		git submodule update --init --recursive && \
		printf "$(GREEN)✓ Submodules ready$(RESET)\n"; \
	else \
		printf "$(YELLOW)⚠  .gitmodules not found — run 'make submodule-add' to register$(RESET)\n"; \
	fi
	@if [ ! -f .env ]; then \
		cp .env.example .env && \
		printf "$(YELLOW)⚠  .env created from .env.example — fill in BOT_TOKEN and secrets$(RESET)\n"; \
	else \
		printf "$(GREEN)✓ .env already exists$(RESET)\n"; \
	fi

submodule-add: _check_git ## Register GitHub repos as git submodules (run once)
	git submodule add https://github.com/Evil2997/PDFnik-Backend PDFnik-Backend
	git submodule add https://github.com/Evil2997/PDFnik-TelegramBot PDFnik-TelegramBot
	git submodule add https://github.com/Evil2997/PDFnik-Schemes PDFnik-Schemes
	git submodule add https://github.com/Evil2997/PDFnik-files_cleaner PDFnik-files_cleaner
	git submodule update --init --recursive
	@printf "$(GREEN)✓ Submodules registered$(RESET)\n"

# ---------------------------------------------------------------------------
# Docker
# ---------------------------------------------------------------------------

up: _check_docker ## Start all services in detached mode
	docker compose up -d
	@printf "$(GREEN)✓ Services started$(RESET)\n"

down: _check_docker ## Stop all services
	docker compose down
	@printf "$(GREEN)✓ Services stopped$(RESET)\n"

restart: down up ## Stop then start all services

logs: _check_docker ## Follow logs from all services (Ctrl-C to stop)
	docker compose logs -f

build: _check_docker ## Rebuild all images without cache
	docker compose build --no-cache
	@printf "$(GREEN)✓ Images built$(RESET)\n"

# ---------------------------------------------------------------------------
# Development
# ---------------------------------------------------------------------------

test: _check_uv ## Run unit tests in all submodules that have tests/
	@printf "$(YELLOW)→ Running tests...$(RESET)\n"
	@failed=0; \
	for dir in PDFnik-Backend PDFnik-TelegramBot; do \
		if [ -d "$$dir/tests" ]; then \
			printf "$(YELLOW)→ $$dir$(RESET)\n"; \
			(cd $$dir && uv run pytest tests/unit -q) \
				&& printf "$(GREEN)✓ $$dir passed$(RESET)\n" \
				|| { printf "$(RED)✗ $$dir failed$(RESET)\n"; failed=1; }; \
		fi; \
	done; \
	exit $$failed

update: _check_git ## Pull latest changes in root and all submodules
	git pull
	git submodule update --remote --merge
	@printf "$(GREEN)✓ All up to date$(RESET)\n"

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean: _check_docker ## Stop services + volumes, remove __pycache__ and .pyc
	docker compose down --volumes
	find . -type d -name __pycache__ -not -path './.venv/*' -exec rm -rf {} + 2>/dev/null || true
	find . -name '*.pyc' -not -path './.venv/*' -delete 2>/dev/null || true
	@printf "$(GREEN)✓ Cleaned$(RESET)\n"

# ---------------------------------------------------------------------------
# Info
# ---------------------------------------------------------------------------

status: _check_git ## Show git status in root and each submodule
	@printf "$(YELLOW)→ Root:$(RESET)\n"
	@git status --short
	@for dir in PDFnik-Backend PDFnik-TelegramBot PDFnik-Schemes PDFnik-files_cleaner; do \
		if [ -d "$$dir/.git" ]; then \
			printf "$(YELLOW)→ $$dir:$(RESET)\n"; \
			git -C $$dir status --short; \
		fi; \
	done
