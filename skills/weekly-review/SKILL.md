---
name: ddclaw:weekly-review
description: End-of-week review — what happened, what's stale, what needs attention next week
---

Run through this checklist and present findings. Be honest — flag what's slipping, not just what got done.

**Important: weekends are not working days.** When counting how long something has been stuck or stale, count only weekdays (Mon-Fri). "Three days stuck" means three workdays, not calendar days. Don't inflate urgency by counting weekends. Frame durations in workdays when flagging staleness.

## 0. Sync context indexes
Run `/sync-context` first to ensure all index files (people, projects) are up to date before auditing them. Include the sync results at the top of the output.

## 1. Week in review
Read all memory files from the past 7 days (`memory/YYYY-MM-DD.md`). Summarize:
- Key decisions made
- Action items completed (`- [x]`)
- Meetings held and outcomes

## 2. Stale action items
Run `/action-items` to get the full list. Flag any items that:
- Have been open for more than 7 days (check when they first appeared in memory or project files)
- Were carried over from last week without progress
- Are assigned to the user specifically (not delegated)

## 3. Person file health check
For each direct report in `context/people/README.md`:
- Read their person file
- Flag if Working Style, Strengths, or Current Focus are empty stubs
- Flag if "Open Items" or "Things to Discuss" haven't been updated in over 2 weeks
- List who had a 1:1 this week (check memory files) vs who didn't

## 4. Project status drift
For each active project in `context/projects/README.md`:
- Read the individual project README
- Check if the status/phase in the index table still matches the project file
- Flag any project with no history entry in the past 2 weeks

## 5. Sprint check
Read the latest sprint file in `context/sprints/`. Flag:
- Commitments at risk
- Items with no progress noted this week
- Any new risks surfaced in memory

## 6. Feedback tracker
Read `context/self/feedback.md`. Check:
- Were any growth area actions practiced this week? (cross-reference with memory)
- Any new patterns to add from this week's interactions?

## Output format

```
## Week of YYYY-MM-DD

### Done
- [bullet list of completed items and decisions]

### Stale (needs attention)
- [item] — open since [date], source: [file]

### People Files
| Report | Last Updated | Gaps |
|--------|-------------|------|
| name   | date or "stub" | what's missing |

### Projects
| Project | Index Status | Actual Status | Drift? |
|---------|-------------|---------------|--------|

### Sprint Risks
- [any flagged items]

### Self-Development
- [growth areas practiced or missed this week]

### Recommended Actions for Next Week
1. [top 3-5 things to prioritize]
```

After presenting, ask: "Want me to update any stale files or the projects index?"
