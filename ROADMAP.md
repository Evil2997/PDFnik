# PDFnik — Roadmap

## P0 — Shipped

- Text → PDF (paragraphs, headings, lists, price tables)
- Photos → PDF (two landscape photos share one page)
- Voice / audio / video → transcript (Whisper, model configurable via env)
- YouTube single video → transcript + PDF (title, channel, date, source link)
- YouTube playlist → per-video transcripts + combined PDF with live progress notifications
- LLM summary block in YouTube PDF (Anthropic / OpenAI / Ollama, opt-in via env)
- Cache-aware batch progress: consecutive cached videos reported as one summary message
- /done, /cancel (with confirmation guard), /start, /help
- Session pause timer with reminder
- Deduplication of concurrent identical requests
- Transcription cache (SQLite, keyed by content hash + model config)
- Retry logic (up to 3 attempts per job) + Dead Letter Queue (txt.dead / pdf.dead)
- Health check endpoint — GET /health checks RabbitMQ, files_storage, runs DB
- CI (GitHub Actions): lint → test → docker build
- pre-commit: ruff, detect-secrets
- Coverage: Backend ≥70%, TelegramBot ≥65%

---

## P2 — Features

- [ ] Batch YouTube — accept multiple URLs in one message → one combined PDF
- [ ] OCR — extract text from images (approach TBD: frame-by-frame model scan)

---

## P3 — Platform

### Internal dashboard (FastAPI)
Browser-based control panel:
- Queue depth and message rates (RabbitMQ management API)
- Transcription job history and cache hit rate
- Storage usage graph
- Whisper model selector without restarting the service
- Manual retry for DLQ messages

### VTT (separate repo)
Independent project growing out of PDFnik's transcription layer:
- SaaS transcription API with usage tracking
- Voice assistant — speech recognition + action execution + voice response
- Multi-model routing (Whisper, cloud STT fallback)

### PDFnik API
- REST endpoints for PDF generation without Telegram
- Subscription model and usage tracking
- GitHub/GitLab integration (commit summaries → PDF)
- S3 storage backend (replace local Docker volume)
