---
allowed-tools: Bash(uv run pytest *)
description: "Run unit tests for PDFnik-TelegramBot"
---

Run: `uv run pytest PDFnik-TelegramBot/tests/unit -q`

No manual env exports needed - tests/conftest.py provides dummy defaults
(BOT_TOKEN/REDIS_URL/RABBITMQ_URL) via os.environ.setdefault; real env vars
still take precedence.

If tests fail, show the failure output and suggest a fix.
If all pass, print the summary line only.
