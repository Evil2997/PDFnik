# Feature 5: Cache visualization and selective clear

## Problem
Users have no way to see what's in their cache, manage it selectively,
or understand what will expire soon. The only option is full wipe (Feature 3)
or waiting for auto-expiry.

## Solution
Generate an interactive HTML file showing the user's cache contents.
Bot sends this file in Telegram. User opens it in browser, can view,
sort, select items for deletion, and confirm — changes are sent back to the bot.

## Research notes (to investigate)
How do other projects solve cache visualization for end users?
- Telegram bots with paginated inline keyboards for list management
- Web Apps (Telegram Mini Apps) for richer UI — worth considering as alternative to HTML file
- Static HTML with JS fetch() calls back to a bot webhook

**Key question for Claude Code:** Is Telegram Web App (Mini App) already in the stack
or feasible to add? If yes, it's a better fit than a standalone HTML file.
If not — HTML file with JS is the fallback.

---

## Interface requirements

### Viewing
- Show all cached items for the current user
- Each item displays:
  - Type icon (link 🔗 / image 🖼 / text 📝 / file 📄)
  - Preview (thumbnail for images, first 100 chars for text, URL for links, filename for files)
  - Date added
  - Expiry date (days remaining)
  - Size (if applicable)
- User can interact: view full content, copy text, download file, open link

### Sorting
- Default: by date added, newest first
- Toggle: by expiry date (soonest to expire first)
- Optionally: by type, by size

### Selection for deletion
- Checkbox per item
- "Select all" button
- Group select buttons: "All links" / "All images" / "All texts" / "All files"
- Date filter: "Select all older than N days"
- "Delete selected" button → triggers confirmation flow

### Confirmation flow
- If user made selections (checked items) and tries to close:
  - Prompt: *"You have unsaved changes. Apply deletions before closing?"* → Apply / Discard / Cancel
  - If user closes without confirming → no changes applied
- If user clicks "Delete selected":
  - Show count: *"Delete 5 items?"* → Confirm / Cancel
  - On confirm → send deletion request to bot backend
  - UI shows "Deleting..." state, items removed from list on success

### Concurrency / locking
- One user can only have **one active cache viewer session at a time**
  - If they try to open a second — bot replies: *"You already have an open session. Close it first."*
- While deletion is in progress:
  - Bot replies to any commands: *"Deletion in progress, please wait..."*
  - When done: *"Done! You can open your cache again."* (only sent if user interacted during deletion)
  - If user didn't interact during deletion — no message sent
- Two different users are fully independent

---

## Technical implementation

### HTML file approach (fallback)
- Bot generates HTML file per request with embedded JS
- File contains user's cache data as JSON
- JS renders the UI, handles selection state
- "Apply" button sends POST to bot's webhook endpoint with list of IDs to delete
- Bot validates user_id from session token in the request

### Telegram Mini App approach (preferred if feasible)
- Mini App URL opened via inline button
- Full interactive UI, no file download needed
- Communicates with backend via standard HTTP

### Security
- Each HTML file / Mini App session must include a signed token (user_id + timestamp + HMAC)
- Backend validates token before executing any deletions
- Token expires after session timeout (e.g. 30 minutes of inactivity)

### Session token in HTML file
- Embed one-time token in the generated HTML
- Token is invalidated after use or after timeout
- Prevents replaying old files

---

## Questions for Claude Code
1. What exactly is stored per cache entry? (confirm: text transcript, image, source URL, file binary?)
2. What is the cache key/schema structure per user_id?
3. Is there a web server / HTTP endpoint in the project that can receive deletion requests?
4. Is Telegram Mini App (Web App) feasible in current stack?
5. How large can a user's cache get — any current limits?
6. Is there a session/auth mechanism already that can be reused for token signing?
