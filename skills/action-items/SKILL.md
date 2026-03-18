---
name: ddclaw:action-items
description: Show all open action items across projects, people, sprints, and recent memory. Use when user says "action items", "what's open", "open items", "todos", or "what do I need to do".
---

Aggregate and display all open action items. Search these locations:

1. **Projects** — grep `- [ ]` in `context/projects/*/README.md`
2. **People** — grep `- [ ]` in `context/people/*/README.md`
3. **Sprints** — grep `- [ ]` in `context/sprints/*.md`
4. **Recent memory** — grep `- [ ]` in `memory/` files from the last 7 days

## Output format

Group by source, skip completed items (`- [x]`). Show the file path for each group so I can navigate.

```
## Projects
**dashboard-investigation/** (context/projects/dashboard-investigation/README.md)
- [ ] Customer validation — Mehdi flagged growing uncertainty
- [ ] Sync with cmd+i EM

**webps-7179/** (context/projects/webps-7179-hide-query-bug/README.md)
- [ ] Get PR approved and merged

## People
**marcela-ramirez/** (context/people/marcela-ramirez/README.md)
- [ ] Self-assessment/feedback using Claude

## Sprints
...

## Recent Memory
...
```

After displaying, give a one-line summary: total open count and which area has the most.
