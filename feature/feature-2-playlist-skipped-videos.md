# Feature 2: Skipped videos in playlist processing

## Problem
When processing a 20-video playlist, the bot skipped videos 2 and 3.
Telegram output jumped from "Transcribing video 1/20" directly to "Transcribing video 4/20".
Both videos 2 and 3 are publicly accessible (confirmed manually).

The playlist UI shows "1 недоступное видео скрыто" (1 unavailable video hidden) —
but that accounts for only one skip, not two.

## What needs to be investigated in code
1. **Playlist iteration method** — YouTube Data API or scraping?
   - Does the API return unavailable videos at all, and with what status field?
   - Are private/deleted videos silently excluded from the API response,
     causing index shift in numbering?

2. **Error handling per video** — if one video fails to fetch/transcribe:
   - Does the error propagate and skip the next video too?
   - Is there a try/catch per video or per batch?
   - Are errors logged or silently swallowed?

3. **Numbering in Telegram messages** — "video X/20":
   - Is X the index in the playlist (position) or a counter of successfully started tasks?
   - If it's a counter, then "1 → 4" means videos 2 and 3 failed silently.
   - If it's a playlist index, then they were never fetched from the API.

4. **Logs for videos 2 and 3** — no logs exist anymore, so code review needed:
   - Was there any attempt to process them?
   - Could the YouTube API have returned them with a different index
     (e.g. unavailable video shifts positions)?

## Expected behavior
- All available videos are processed in order.
- Unavailable/private videos are skipped with a log entry and optionally
  a Telegram notification: *"Video 2/20 unavailable, skipping."*
- Numbering in messages reflects actual playlist position, not just success counter.
- One video failing must not affect processing of subsequent videos.

## Fix checklist
- [ ] Wrap per-video processing in individual try/catch
- [ ] Log skip reason for each failed video
- [ ] Verify playlist index vs counter logic in Telegram output
- [ ] Test with playlists containing unavailable videos
