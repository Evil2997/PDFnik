# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Monorepo structure

PDFnik is a uv workspace with four submodules, each a standalone Python package:

```
PDFnik/                      - root (docker-compose, Makefile, justfile)
├── PDFnik-Backend/          - FastAPI + RabbitMQ consumers: PDF generation, audio transcription
├── PDFnik-TelegramBot/      - aiogram bot: user-facing Telegram frontend
├── PDFnik-Schemes/          - shared Pydantic contracts (pdfnik-schemes pip package)
└── PDFnik-files_cleaner/    - scheduled TTL cleanup of the shared files_storage volume
```

Each submodule is a git repository of its own. All four share a Docker volume (`files_storage`) and communicate exclusively through RabbitMQ queues.

## Commands

All commands assume Python 3.13 and `uv` installed.

**Full stack:**
```bash
make up          # start all containers
make down        # stop all containers
make logs        # follow all logs
make build       # rebuild images without cache
make test        # run unit tests in all submodules
make status      # git status across root + all submodules
```

**Per-service tests (run from the service directory):**
```bash
cd PDFnik-Backend && uv run pytest tests/unit -q
cd PDFnik-TelegramBot && uv run pytest tests/unit -q

# single test file
cd PDFnik-Backend && uv run pytest tests/unit/test_run_logic.py -q
```

**Linting / formatting (per service):**
```bash
uv run ruff check .
uv run ruff format .
uv run mypy main_app/
```

Backend tests require `RABBITMQ_URL` to be set (or mocked in conftest) because `Settings` validates it on import. The test `conftest.py` handles this via env patching.

## Architecture

The Telegram bot is the only user-facing component. All heavy work is async via RabbitMQ.

**Queue map:**

| Queue | Direction | Purpose |
|---|---|---|
| `txt.transcribe` | Bot → Backend | Transcription job |
| `txt.done` | Backend → Bot | Transcription result |
| `txt.progress` | Backend → Bot | Per-video progress (playlist/batch only) |
| `txt.cache_summary` | Backend → Bot | Cached-video batch count (playlist/batch only) |
| `txt.dead` | Backend DLQ | Failed transcription jobs |
| `pdf.generate` | Bot → Backend | PDF generation request |
| `pdf.send` | Backend → Bot | PDF ready for delivery |
| `pdf.dead` | Backend DLQ | Failed PDF jobs |

**Transcription target kinds** (`TxtTarget.kind`):
- `storage_key` - uploaded voice/audio/video file on the shared volume
- `url` - single YouTube URL (auto-detected as playlist if it contains playlist params)
- `url_batch` - newline-separated YouTube URLs (multiple links in one message)

**Transcription deduplication:** `make_run_key()` hashes `target_id + model + device + compute_type + threads + workers + beam_size + patience + vad + lang`. Same URL with same config always hits the cache (SQLite on the shared volume).

**In-flight deduplication:** `_inflight_locks` dict keyed by `run_key` prevents concurrent duplicate transcriptions within one process.

**Retry logic:** `TxtTranscribeJob.attempt` / `max_attempts` (default 3). On error, the consumer requeues the job to `txt.transcribe` with `attempt + 1`. After `max_attempts`, publishes error to `txt.done`.

## Key files

| File | Role |
|---|---|
| `PDFnik-Backend/main_app/rabbitmq/txt_orders.py` | Core transcription consumer - routing, locking, retry, progress publishing |
| `PDFnik-Backend/main_app/rabbitmq/pdf_orders.py` | PDF generation consumer |
| `PDFnik-Backend/main_app/domain/work_with_pdf/actions/files/prod_service.py` | `transcribe()`, `transcribe_playlist()`, `transcribe_batch()` |
| `PDFnik-Backend/main_app/domain/work_with_pdf/pdf_normalizer.py` | Text block classification (heading/list/paragraph/price_table) |
| `PDFnik-Backend/main_app/domain/summarize/factory.py` | LLM provider selection (anthropic/openai/ollama/disabled) |
| `PDFnik-TelegramBot/main_app/application/bot/txt_consumer.py` | Handles `txt.done`, `txt.progress`, `txt.cache_summary` |
| `PDFnik-TelegramBot/main_app/application/bot/vtt_message.py` | Entry point for voice/video/audio Telegram messages |
| `PDFnik-TelegramBot/main_app/application/bot/session_manager.py` | Redis-backed PDF session (accumulates blocks before /done) |
| `PDFnik-Schemes/pdfnik_contracts/pdf_content.py` | Shared `PdfOrder`, `BotDocument`, `PdfBlock` subtypes |

## Shared contracts

`PDFnik-Schemes` is installed as a git dependency in both services:
```
pdfnik-schemes @ git+https://github.com/Evil2997/PDFnik-Schemes@v1.2.1
```

In the uv workspace, `[tool.uv.sources]` maps `pdfnik-schemes = { workspace = true }` so local edits are picked up without reinstalling.

## Style rules

- Line length: 100 (ruff, not enforced as error)
- Quote style: double
- Always use `-` not `—` in comments, commit messages, and docstrings
- `asyncio_mode = "auto"` in pytest - no need for `@pytest.mark.asyncio`
- Coverage thresholds: Backend >= 70%, Bot >= 65%
