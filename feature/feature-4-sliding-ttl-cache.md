# Feature 4: Sliding TTL — refresh cache date on access

## Problem
Cache currently has a fixed 7-day TTL from the moment of creation.
If a user re-uses cached content (link, file, text), the TTL is not reset,
so frequently used content can still expire.

## Expected behavior
Every time a cached item is accessed (i.e. a hit — bot returns result from cache),
the TTL for that item is reset to 7 days from **now** (sliding TTL).

## Scope
Applies to all cache types:
- YouTube / web links
- Files (PDF, documents, etc.)
- Text inputs
- Images
- (Any other types found in codebase)

## Implementation

### If cache is in Redis
- On cache hit: call `EXPIRE <key> 604800` (7 days in seconds) immediately after read
- This extends the TTL without modifying the cached value

### If cache is NOT in Redis (DB or filesystem)
- Migrate cache storage to Redis with TTL support
- Or add `last_used_at` field to DB + update it on every cache hit
  + scheduled job to purge records where `last_used_at < now - 7 days`

### Preferred approach
Use Redis if not already used. Set TTL on write, refresh TTL on read.

## Questions for Claude Code
- Is Redis already in the stack? If yes, is cache stored there?
- If cache is in DB — what is the schema? Is there a `created_at` or `expires_at` field?
- Where in the code does cache lookup happen? (to add TTL refresh in one place)
- Is there a single cache service/repository class or is cache access scattered?

## Notes
- TTL value (7 days) should be a configurable constant, not hardcoded in multiple places
- Refresh should happen only on actual cache hit, not on miss or write
