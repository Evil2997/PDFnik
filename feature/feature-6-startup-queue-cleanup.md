# Feature 6: RabbitMQ queue cleanup on startup + ready notification

## Context
Bot is used primarily by one person (developer/owner) at current stage.
Not a 24/7 production service yet — restarts happen manually (planned) or
due to crashes (unplanned). Both cases handled identically.

The owner needs to know:
1. That the bot is alive and ready to accept input
2. Whether anything was in the queue that got wiped (so they can resend if needed)

---

## Behavior on startup

### On startup — always:
- Clear RabbitMQ queue completely
- Wait 2–5 seconds after full initialization
- Send **one** of two messages (never both):

---

### Message 1 — queue had pending tasks
Sent when: queue contained one or more messages at startup moment.

**Text (example):**
> 🔄 Restarted. Found tasks in the queue — cleared them.
> If you sent something earlier, feel free to send it again.

- Short, 1–2 sentences
- Friendly tone, no technical jargon
- With emoji

---

### Message 2 — queue was empty
Sent when: queue was empty at startup moment.

**Text (example):**
> ✅ Ready to work. You can send something.

- Even shorter
- Just signals "I'm alive and ready"
- With emoji

---

## Who receives the message
- **Only the bot owner** (hardcoded or configured OWNER_CHAT_ID / ADMIN_TELEGRAM_ID)
- No broadcast to all users

---

## Crash scenario notes
If bot crashed mid-processing:
- Message may already be in RabbitMQ (received but not acked)
- Or task may have been partially processed
- On restart: queue is cleared regardless, Message 1 is sent
- Owner understands they may need to resend

---

## Implementation notes
- Startup hook: after all services initialized (DB, Redis, RabbitMQ connections confirmed)
- Delay: `asyncio.sleep(2–5)` or equivalent before sending message
- Queue check: count messages in queue before purging
  - If count > 0 → purge → send Message 1
  - If count == 0 → send Message 2
- Use existing Telegram bot send_message method

## Questions for Claude Code
- Where is the app startup/init sequence? (to hook into)
- Is OWNER_CHAT_ID / admin ID already configured somewhere?
- How is RabbitMQ accessed — what client library? (pika, aio-pika, etc.)
- Are there multiple queues? If yes — check and purge all of them, or only main task queue?
- Is there already a health-check or on_startup handler?
