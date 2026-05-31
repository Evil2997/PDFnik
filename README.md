# PDFnik

Telegram bot that turns voice messages, YouTube links, and photos into PDF documents.

## What it does

- **Voice messages** - transcribes audio with Whisper and delivers a PDF with the full transcript
- **YouTube links** - downloads audio, transcribes it, optionally summarizes with an LLM, produces a PDF
- **Photos** - packs images into a PDF; two landscape photos share a single page automatically
- **Documents** - forwards files back to the user as-is

## Services

| Service | Description |
|---|---|
| `PDFnik-TelegramBot` | Telegram frontend - receives messages, routes tasks |
| `PDFnik-Backend` | PDF generation, audio transcription, YouTube processing |
| `PDFnik-files_cleaner` | Scheduled cleanup of expired files on the shared volume |
| `PDFnik-Schemes` | Shared Pydantic contracts (published as a package) |

Services communicate through RabbitMQ. Redis handles session state and deduplication.

## Requirements

- Docker and Docker Compose
- A Telegram bot token from [@BotFather](https://t.me/BotFather)
- Optionally: Anthropic or OpenAI API key for YouTube transcript summarization

## Setup

**1.** Clone the service repositories into this directory:

```bash
git clone https://github.com/Evil2997/PDFnik-TelegramBot
git clone https://github.com/Evil2997/PDFnik-Backend
git clone https://github.com/Evil2997/PDFnik-files_cleaner
```

**2.** Copy the example env file and set your values:

```bash
cp .env.example .env
```

At minimum, set `BOT_TOKEN`. Everything else has sensible defaults.

**3.** Start all services:

```bash
docker compose up -d
```

**4.** Stop:

```bash
docker compose down
```

## Configuration

All settings live in a single `.env` file at the root. See `.env.example` for the full list with descriptions.

Key settings:

| Variable | Default | Description |
|---|---|---|
| `BOT_TOKEN` | - | Telegram bot token, required |
| `TRANSCRIBE_MODEL` | `base` | Whisper model: `tiny` / `base` / `small` / `medium` / `large-v3` |
| `TRANSCRIBE_DEVICE` | `cpu` | `cpu` or `cuda` |
| `SUMMARY_PROVIDER` | `disabled` | LLM provider for YouTube summaries: `anthropic` / `openai` / `ollama` |
| `PDF_TTL_HOURS` | `24` | How long generated PDFs are kept on the shared volume |

## Development

The root `pyproject.toml` defines a [uv workspace](https://docs.astral.sh/uv/concepts/projects/workspaces/). Install all dependencies with:

```bash
uv sync
```

Run tests for a specific service:

```bash
cd PDFnik-Backend && uv run pytest
cd PDFnik-TelegramBot && uv run pytest
```

Each service has its own `README.md` with service-specific development notes.
