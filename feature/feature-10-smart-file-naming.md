# Feature 10: Smart file naming based on content or source

## Problem
Transcription/output files currently get generic or UUID-based names
(e.g. `transcript_6d6e98fb-72cc-4aa9-ac23-6135e58b3885.txt`).
This makes files hard to identify without opening them.

---

## Expected behavior

### If LLM is connected
Generate a meaningful name based on:
- Processing mode (summary, study, commands, pipeline, tips, raw)
- Content — ask LLM to produce a short title (3–6 words) based on the output

**Format:** `{mode}_{llm_title}.pdf`
**Example:** `summary_claude_code_skills_course.pdf`

### If LLM is not connected
Use source metadata:

| Source type | File name |
|---|---|
| Single video | `{video_title}.txt` |
| Playlist | `{playlist_title}.txt` |
| Channel | `{channel_name}.txt` |
| File input | `transcript_{original_filename}.txt` |
| Text input | `transcript_{first_8_words}.txt` |

### General rules
- Sanitize name: lowercase, spaces → underscores, remove special chars
- Max length: 60 chars (truncate if needed)
- Always append extension based on format (.pdf / .txt / .md)
- If title unavailable → fallback to current UUID name (don't break)

---

## Questions for Claude Code
- Where is file naming currently handled?
- Is LLM connection optional/configurable or always present?
- Is YouTube video/playlist title already fetched during processing (reuse it)?
- What file formats are currently generated (PDF only, or also TXT/MD)?
