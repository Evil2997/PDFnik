# Feature 7: Bot description / welcome screen with metrics and emoji

## What is this
The text shown to a user **before they press Start** in Telegram.
Set via `BotFather → Edit Bot → Edit Description` or via Bot API method `setMyDescription`.
Also shown on the bot's profile page.

There is also a **short description** (shown in search results / sharing),
set separately via `setMyShortDescription`.

---

## Content requirements

### Description (shown before Start, max 512 chars)
- List of bot capabilities with emoji per item
- One metric: number of users (if fetchable dynamically — see notes)
- Friendly, not too technical
- Not too long — 3–6 lines max

**Draft example:**
```
🎙 Transcribe YouTube videos and playlists
📄 Export to PDF or raw text
🔗 Process links, files, images and text
📋 Multiple output modes: Summary, Learn, Commands, Pipeline, Tips
💾 Smart cache — reuse results instantly

👥 Already used by [N] users
```

### Short description (shown in search, max 120 chars)
**Draft example:**
```
Transcribe, summarize and export YouTube content to PDF and text.
```

---

## Dynamic user count metric

### Option A — fetch from DB on bot startup, embed in description
- Query: `SELECT COUNT(DISTINCT user_id) FROM ...` (whatever table tracks users)
- Call `setMyDescription` with updated count on each startup
- Simple, no real-time updates needed

### Option B — static for now, update manually
- Hardcode or set once, update when milestone reached
- Simpler, acceptable at current scale

**Recommendation:** Option A — update on startup, costs nothing extra.

---

## Implementation notes
- Telegram Bot API methods:
  - `setMyDescription(description, language_code)` — long description
  - `setMyShortDescription(short_description, language_code)` — short one
- Can be called once on startup alongside Feature 6 startup hook
- Language: set for default (no language_code) = shown to all users
- If bot is multilingual later — can add `language_code='ru'` variant

---

## Questions for Claude Code
- Is there a users table or any record of registered user_ids to count from?
- Is there already a BotFather-configured description, or is it empty?
- Where to add the startup call — same place as Feature 6 startup hook?
- What language is the bot interface in currently — Russian, English, or both?
