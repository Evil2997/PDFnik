---
allowed-tools: Bash(uv run pytest *)
description: "Run unit tests for PDFnik-Backend"
---

Run: `uv run pytest PDFnik-Backend/tests/unit -q`

No manual env exports needed - tests/conftest.py provides dummy defaults
(RABBITMQ_URL) via os.environ.setdefault; real env vars still take precedence.

If tests fail, show the failure output and suggest a fix.
If all pass, print the summary line only.
