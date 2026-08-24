# Feature 9: Smart output format — inline text or file choice

## Problem
Currently output is always sent as a file (PDF/TXT). For short results
(short summary, small transcription) this is inconvenient — user has to
open a file just to copy a few lines.

---

## Expected behavior

### Auto-detect output size
- If result is **short** (threshold to determine in code — e.g. ≤ 4096 chars,
  which is Telegram message limit) → send as plain text directly in chat
- If result is **long** → send as file (current behavior)

### Format choice (optional, after result is ready)
After sending, offer inline buttons:
- 📋 **Copy-friendly** — split into logical blocks, each as separate message
- 📄 **PDF file**
- 📝 **TXT file**
- ✍️ **Markdown file**

User picks one → bot sends in chosen format. Or no action → text in chat is enough.

---

## Split by logical blocks ("сплит по пунктам")
When result has multiple points/sections (e.g. Summary with 5 key points):
- Send each point as a **separate Telegram message**
- No numbering required — just clean text per block
- User can long-press any block in Telegram to copy just that part
- Useful for pasting into other apps point by point

### When to split
- Mode: Summary, Learn, Commands, Tips — natural split by sections
- Mode: Raw transcript — split by time chunks or paragraphs
- Threshold: if result has 3+ distinct sections → offer split option

---

## Questions for Claude Code
- What is current output size threshold for file vs text decision (if any)?
- How are sections/points structured in LLM output — markdown headers? numbered list?
- Is there a message formatter/sender utility to extend, or is send logic scattered?
