---
name: ddclaw:prep
description: Prepare for a 1:1 or meeting — pull context, surface action items, draft agenda. Use when user says "prep for [name]", "prep for [meeting]", or "prepare for [name]".
argument-hint: <person-name or meeting-name>
---

Prep for $ARGUMENTS:

## If it's a person:
1. Read `context/people/$ARGUMENTS/README.md`
2. Scan recent `memory/` files for mentions of them
3. Surface:
   - Open action items involving them
   - Their growth goals
   - Things queued to discuss
   - Any flags
4. Draft a 1:1 agenda

## If it's a meeting or topic:
1. Pull relevant context from `context/projects/` and `context/org/README.md`
2. Check recent memory for related items
3. Draft:
   - Talking points
   - Questions to ask
   - Decisions needed
