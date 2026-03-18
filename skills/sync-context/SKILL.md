---
name: ddclaw:sync-context
description: Sync index README files with their child folders and resolve content discrepancies. Use when user says "sync context", "audit files", or "check consistency".
---

Two passes: first sync indexes with folder contents, then audit for content discrepancies. Fix what's unambiguous, flag what needs a decision.

---

## Pass 1: Index Sync

### 1a. People index (`context/people/README.md`)

- List all folders in `context/people/` (excluding `_TEMPLATE.md`)
- Compare against the "Who's Who" section in `context/people/README.md`
- For each folder NOT in the index: read its `README.md` header (Role, Team, Reports to) and add it to the correct subsection (DNV Team, Managers, or Key Partners)
- For each index entry whose folder doesn't exist: flag for removal
- Preserve the existing grouping structure (DNV Team, Managers, Key Partners)

### 1b. Projects index (`context/projects/README.md`)

- List all folders in `context/projects/` (excluding `_TEMPLATE.md`)
- Compare against the Active/Blocked/Paused tables in `context/projects/README.md`
- For each folder NOT in the index: read its `README.md` header (Status, Goal) and add it to the correct status table
- For each index entry whose folder doesn't exist: flag for removal

### 1c. Sprints (`context/sprints/`)

- List all files in `context/sprints/` (excluding `README.md`)
- Flag if the latest sprint file is more than 2 weeks old

Apply index additions/removals immediately. Report what changed.

---

## Pass 2: Content Discrepancy Audit

Read every context file listed below and cross-reference for inconsistencies. For each discrepancy found, check the last 7 days of memory files (`memory/YYYY-MM-DD.md`) for relevant decisions or context that might resolve it.

### 2a. People: index vs file content

For each person in the people index:
- Read their `README.md` header fields (Role, Team, Reports to, Location)
- Compare against their index line (e.g., `SE3, Remote Virginia`)
- Flag if: role, team, location, or reporting relationship doesn't match
- Flag if: person is in wrong index group (e.g., listed under "Key Partners" but file says "Reports to: Ladi Bello" → should be DNV Team)

### 2b. Projects: index vs file content

For each project in the projects index:
- Read the project `README.md` Status field
- Compare against the index table Status column — flag if drifted
- Compare the "What's Next" column against the project's "Current Priorities" section — flag if the index describes work that's already done or no longer relevant
- Flag if project Status is "active" but the last History entry is older than 3 weeks (stale active project)

### 2c. People ↔ Projects cross-reference

- Check each project's "People" field against the people index — flag anyone listed in a project who doesn't have a person folder
- Check each person's "Current Focus" section — flag if it references a project that no longer exists or has been completed/paused

### 2d. ORG.md consistency

- Read `context/ORG.md`
- Flag if team members listed there don't match the people index
- Flag if products/objectives listed there contradict active project descriptions

---

## Resolution

For **unambiguous fixes** (role title mismatch, status field drift where the project file is clearly more current): apply the fix and report it.

For **ambiguous discrepancies** (conflicting information, unclear which source is correct, missing context):
1. Check memory files from the last 7 days for any related decisions
2. Present each discrepancy with:
   - What the inconsistency is
   - What each source says
   - What memory says (if anything)
   - Your best guess at the right answer
3. Ask me to confirm before making the change

---

## Output format

```
## Sync Results

### Index Sync
**People:** [added X, removed Y, no changes]
**Projects:** [added X, removed Y, no changes]
**Sprints:** latest is [filename] ([age])

### Discrepancies Fixed
- [file]: [what was wrong] → [what it is now]

### Discrepancies Needing Resolution
1. **[short label]**
   - Index says: [X]
   - File says: [Y]
   - Memory says: [Z or "no recent context"]
   - Suggested fix: [recommendation]

### Cross-Reference Issues
- [person/project mismatch details]
```
