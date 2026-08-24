# Feature 8: Whisper logging to Docker terminal

## Problem
Whisper currently produces no logs to Docker stdout/stderr.
When processing long videos (1–4 hours), there is no visibility into:
- Whether processing is running at all
- Which video is being processed
- How long it's taking
- Whether errors occurred

---

## Expected behavior
All Whisper-related activity logs to Docker stdout (standard Python logging),
visible via `docker logs` or `docker compose logs -f`.

---

## Log events to implement

### INFO level
- Processing started:
  `[INFO] Whisper | Starting transcription: "VIDEO TITLE" (duration: 1:23:45)`
- Processing finished:
  `[INFO] Whisper | Done: "VIDEO TITLE" — elapsed: 4m 32s`
- Cache hit (skipped transcription):
  `[INFO] Whisper | Cache hit for "VIDEO TITLE", skipping transcription`
- Audio download started/finished:
  `[INFO] Whisper | Downloading audio: "VIDEO TITLE"`
  `[INFO] Whisper | Audio downloaded (12.4 MB)`

### DEBUG level
- Whisper model loaded:
  `[DEBUG] Whisper | Model loaded: medium`
- Audio chunk progress (if Whisper processes in segments):
  `[DEBUG] Whisper | Segment 00:01:23 → 00:01:45 transcribed`
- Raw Whisper output snippet or segment count:
  `[DEBUG] Whisper | Total segments: 142`

### WARNING level
- Video longer than threshold (e.g. >2 hours):
  `[WARNING] Whisper | Long video detected (3:12:00), processing may take a while`
- Retrying after transient error:
  `[WARNING] Whisper | Retrying transcription (attempt 2/3): "VIDEO TITLE"`

### ERROR level
- Transcription failed:
  `[ERROR] Whisper | Transcription failed for "VIDEO TITLE": <exception message>`
- Audio download failed:
  `[ERROR] Whisper | Audio download failed: <exception message>`
- Unexpected exception with traceback:
  `[ERROR] Whisper | Unexpected error: <traceback>`

---

## Implementation notes
- Use Python standard `logging` module — outputs to stdout by default in Docker
- Logger name: `whisper` (so logs are filterable: `docker logs bot | grep Whisper`)
- Format: `%(asctime)s [%(levelname)s] %(name)s | %(message)s`
- Timestamp format: `YYYY-MM-DD HH:MM:SS`
- Log level controlled via env variable `LOG_LEVEL` (default: `INFO`)
- No file handlers — stdout only
- If a root logger already exists in the project — attach Whisper logger as child,
  don't override root config

---

## Questions for Claude Code
- Is there already a logging setup in the project (root logger, config file, etc.)?
- Where exactly is Whisper called — one place or multiple?
- Does Whisper library itself emit any logs that can be captured/redirected?
- Is audio downloaded separately before passing to Whisper, or streamed?
- Are there existing try/except blocks around Whisper calls to extend?
