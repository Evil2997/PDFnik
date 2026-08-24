# Feature 11: Closeable inline messages (delete button)

## Problem
Bot messages with inline buttons (mode selection, format choice, menus)
accumulate in chat history and clutter it. There is no way to dismiss them
without scrolling past. Main menu sent repeatedly fills the entire chat.

## Inspiration
A checkers game bot shows a leaderboard with two buttons: "Next page" and "Close".
"Next page" deletes the current message and sends the next one.
"Close" simply deletes the message. Clean, no clutter.

---

## Expected behavior

### Add "✖ Close" button to applicable messages
When user presses Close:
- Delete the bot message (via `delete_message` Telegram API)
- No replacement message sent
- Chat stays clean

### Which messages should have Close button
- Mode selection prompt (Summary / Learn / Commands / Pipeline / Tips / Raw transcript)
- Format selection prompt (PDF / TXT / MD / Split)
- Any paginated list (future: cache viewer navigation)
- Main menu (if sent as inline keyboard)
- Any informational message that doesn't require action

### Which messages should NOT have Close button
- Processing status messages ("Transcribing video 3/20...") — ephemeral anyway
- Error messages — user may need to read them
- Final result (text output) — user needs it for copying

---

## Pagination pattern (for lists)
When content has multiple pages (e.g. cache list, long output split):
- Buttons: `◀ Back` | `▶ Next` | `✖ Close`
- Each navigation deletes current message, sends new one (no message stack)
- Close deletes without replacement

---

## Implementation notes
- Telegram: `bot.delete_message(chat_id, message_id)` — straightforward
- Callback data for close button: e.g. `action:close`
- Single universal close handler: receives `message_id` from callback, deletes it
- No confirmation needed for closing (it's non-destructive)

## Questions for Claude Code
- Is there a central inline keyboard builder to extend with Close button?
- Are callback handlers centralized or per-feature?
- Is `delete_message` already used anywhere in the codebase?
