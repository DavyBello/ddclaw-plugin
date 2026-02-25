---
name: ddclaw:action-items
description: Show all open action items across projects, people, sprints, and recent memory
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
- [ ] Item description

## People
**person-name/** (context/people/person-name/README.md)
- [ ] Item description

## Sprints
...

## Recent Memory
...
```

After displaying, give a one-line summary: total open count and which area has the most.
