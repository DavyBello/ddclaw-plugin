---
name: ddclaw:catch-me-up
description: Quick briefing — PRs, action items, blockers, and anything that needs attention. Use when user says "catch me up", "what did I miss", or "briefing".
---

Run through this checklist and present a concise briefing:

## 1. PRs
Run the `/my-prs` skill to get PRs personally assigned to me (filtered from team assignments) and my own open PRs.

## 2. Open action items
Run the `/action-items` skill to get all pending items across projects, people, sprints, and recent memory.

## 3. Blockers and flags
- Scan today's and yesterday's memory files for anything tagged as blocked, flagged, or at risk
- Check `context/projects/README.md` for projects with "blocked" status

## 4. Sprint commitments
- Read the latest file in `context/sprints/` for current sprint goals and risks

## Output format

Keep it tight — scannable, not verbose:

```
## PRs
**Review requested:**
- [title](url) — repo, updated X ago

**Your PRs with updates:**
- [title](url) — status/decision

## Action Items (X open)
[top 10 most urgent, grouped by area]
(Run /action-items for the full list)

## Blockers
- [item] — [source]

## Sprint
Goal: [one line]
Risks: [any flagged]
```

If everything is clear, say so. Don't pad.
