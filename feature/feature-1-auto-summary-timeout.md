# Feature 1: Auto-select Summary mode on timeout

## Problem
When a playlist/video link is received, the bot waits for the user to choose a processing mode
via inline buttons (Summary / Learn / Commands / Pipeline / Tips / Raw transcript).
If the user doesn't respond, after ~3.5–4 hours the link/session becomes invalid and
processing never starts. The user gets an error like "link is no longer valid".

## Root cause (to investigate)
- Where is the "waiting for mode selection" state stored? (Redis? DB? RabbitMQ message TTL?)
- Who deletes this state and when — the broker via TTL or backend explicitly?
- Is there an expiry event/hook when TTL runs out, or does it silently disappear?

## Expected behavior
1. If user doesn't select a mode within **10 minutes** — automatically select **Summary**
   and start processing.
2. Notify the user:
   - If auto-selected: *"Mode not selected within 10 minutes. Starting with Summary automatically."*
   - If session already expired by the time auto-select fires: *"Session expired. Please send the link again."*

## Implementation notes
- Need a 10-minute timer per pending session. Options to consider:
  - Delayed message / scheduled task in RabbitMQ (dead letter queue with TTL)
  - Redis key with TTL + expiry notification (keyspace events)
  - Cron job polling DB for sessions older than 10 min
- Timer must be cancelled if user selects mode manually before 10 min.
- If the link itself has a shorter TTL than 10 minutes — fix the link TTL first,
  or reduce auto-select timeout accordingly.

## Questions for Claude Code
- What is the current TTL of the session/link state?
- How are inline button callbacks tied to the original session?
- Is there already a scheduler/cron in the project that can be reused?
