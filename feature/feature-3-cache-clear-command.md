# Feature 3: Manual cache clear command for user account

## Problem
Cache auto-expires after 7 days. If a user wants to re-run a scan before 7 days
(e.g. after an interrupted scan), they currently have to manually clear cache via Docker/CLI.
There is no in-bot way to do this.

## Scope
- Cache is per Telegram user_id (one account = one cache scope)
- Available to any user for their own cache only
- No admin interface needed — user clears their own cache via bot

## Command
- Add `/clearcache` command
- Add it to `/help` menu with a short description

## Behavior

### Full clear (all cache)
1. User sends `/clearcache`
2. Bot replies with options:
   - "Clear all" button
   - "Clear by type" (links / images / texts / files)
   - "Clear by date" (older than N days)
   - "Select specific items" (redirects to Feature 5 interface)
3. If user chose "Clear all" — confirmation required:
   *"This will delete all your cached data. Are you sure?"* → Yes / No
4. On confirm — delete all cache for this user_id
5. Bot replies: *"Cache cleared successfully."*

### Selective clear (by type or date)
1. User picks type or date range
2. Bot shows count: *"Found 12 items. Delete?"* → Yes / No
   (No confirmation needed for 1–3 items — configurable threshold, default=3)
3. On confirm — delete selected subset
4. Bot replies: *"Deleted N items."*

### Specific items
- Handled by Feature 5 interface (view cache → select → delete)

## Questions for Claude Code
- Where is cache stored? (Redis keys? DB table? File system?)
- What is the current cache key structure per user_id?
- Is there already a `/help` command handler to extend?
- What cache types currently exist? (links, files, text, images — confirm all)
