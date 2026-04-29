---
name: ddclaw:sprint
description: Manage Jira sprints — view, close, or create sprints on your team's board. Use when user says "sprint", "sprint view", "sprint close", "sprint create", or "close the sprint".
argument-hint: "[view|close|create] — defaults to view"
---

Manage Jira sprints on your team's board via the Agile REST API.

## 0. Load config

Read `context/config.md` for:
- `Board ID` (e.g., 9232)
- `Sprint cadence` (e.g., 2 weeks)
- `Sprint naming` pattern (e.g., "DD Mon - DD Mon")
- `Jira email` (e.g., you@example.com)
- `Base URL` (e.g., https://yourcompany.atlassian.net)

The API token comes from the `$JIRA_API_TOKEN` environment variable. Verify it is set before proceeding. If not, tell the user: "Set JIRA_API_TOKEN in your shell profile (~/.zshrc). Generate one at https://id.atlassian.com/manage-profile/security/api-tokens"

All API calls use:
```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" -H "Content-Type: application/json" "$BASE_URL/rest/agile/1.0/..."
```

Where `$JIRA_EMAIL` is the email from config.md.

## 1. Parse subcommand

Parse the argument to determine the subcommand:
- `view` (default if no argument) — show current sprint status
- `close` — complete the active sprint
- `create` — create a new sprint

---

## Subcommand: `view`

### 1. Fetch active sprint

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$BASE_URL/rest/agile/1.0/board/BOARD_ID/sprint?state=active" \
  | python3 -m json.tool
```

Find the sprint whose `originBoardId` matches the configured board ID. Ignore sprints from other boards (they may appear if shared).

### 2. Fetch sprint issues

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$BASE_URL/rest/agile/1.0/sprint/SPRINT_ID/issue?maxResults=100&fields=summary,status,assignee,priority" \
  | python3 -m json.tool
```

### 3. Display

Group issues by status category and display:

```
## Sprint: 30 Mar - 13 Apr (active)
Ends: Apr 13

### Done (X)
- PROJ-NNN — Summary (Assignee)

### In Progress (X)
- PROJ-NNN — Summary (Assignee)

### In Review (X)
- PROJ-NNN — Summary (Assignee)

### To Do (X)
- PROJ-NNN — Summary (unassigned)

**Summary:** X total — Y done, Z in progress, W to do
```

---

## Subcommand: `close`

### 1. Fetch active sprint and issues

Same as `view` steps 1-2. Display the summary.

### 2. Ask for meeting notes (optional)

Ask the user:

> Any sprint meeting notes or retro summary to include? (paste text, or "no" to skip)

Wait for the user's response. If they provide notes, store them for step 6.

### 3. Identify target sprint

Check if a future sprint exists:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$BASE_URL/rest/agile/1.0/board/BOARD_ID/sprint?state=future"
```

If a future sprint exists on the configured board, propose it as the target for incomplete issues.

If no future sprint exists, propose creating one:
- Auto-generate name from the closing sprint's end date + cadence (e.g., closing "30 Mar - 13 Apr" → create "13 Apr - 27 Apr")
- Start date = closing sprint's end date
- End date = start date + cadence

Show the user the plan:

```
## Close Sprint: 30 Mar - 13 Apr

**Completed:** 7 issues
**Carrying over:** 5 issues → "13 Apr - 27 Apr" (new sprint)

Incomplete issues to move:
- PROJ-NNN — Summary (In Progress)
- PROJ-NNN — Summary (To Do)
...

Create new sprint "13 Apr - 27 Apr" and close current? (yes/no)
```

Wait for confirmation before proceeding.

### 4. Create target sprint (if needed)

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -X POST "$BASE_URL/rest/agile/1.0/sprint" \
  -d '{
    "name": "SPRINT_NAME",
    "startDate": "YYYY-MM-DDTHH:MM:SS.000Z",
    "endDate": "YYYY-MM-DDTHH:MM:SS.000Z",
    "originBoardId": BOARD_ID
  }'
```

### 5. Move incomplete issues to target sprint

Collect all issue IDs where status category is NOT "Done". Move them:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -X POST "$BASE_URL/rest/agile/1.0/sprint/TARGET_SPRINT_ID/issue" \
  -d '{
    "issues": ["PROJ-NNN", "PROJ-NNN", ...]
  }'
```

### 6. Complete the sprint

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -X POST "$BASE_URL/rest/agile/1.0/sprint/SPRINT_ID" \
  -d '{
    "state": "closed",
    "completeDate": "YYYY-MM-DDTHH:MM:SS.000Z"
  }'
```

**Note:** The Jira API uses `POST` (not `PUT`) to update sprint state. The `completeDate` should be the current timestamp.

### 6b. Activate the new sprint

The newly created (or selected future) target sprint is in `future` state. Activate it so it becomes the team's current active sprint:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE_URL/rest/agile/1.0/sprint/TARGET_SPRINT_ID" \
  -d '{"state": "active"}'
```

This applies whether the target was newly created in step 4 or was an already-existing future sprint chosen in step 3. Skip this step only if the user explicitly says they want the next sprint to stay in `future` state (e.g., they're closing early and won't start the next sprint until later).

### 7. Save sprint file

Write to `context/sprints/YYYY-MM-DD.md` (using the sprint start date) with this format:

```markdown
# Sprint YYYY-MM-DD → YYYY-MM-DD

**Goal:** [from sprint goal if set, or "No goal set"]

## Results
- **Completed:** X issues
- **Carried over:** Y issues → [target sprint name]

### Completed
- PROJ-NNN — Summary (Assignee)

### Carried Over
- PROJ-NNN — Summary (Assignee) — status

## Notes
[Meeting notes / retro summary if provided by user, otherwise omit this section]
```

If meeting notes were provided, also:
- Extract any action items and add them as `- [ ]` items under a `## Action Items` section
- Propagate relevant updates to person files (`context/people/*/README.md`) and project files (`context/projects/*/README.md`) — same pattern as the standup skill

### 8. Append to memory

Append to `memory/YYYY-MM-DD.md` (today's date):

```
## Sprint closed: [sprint name]
- Completed: X issues
- Carried over: Y issues → [target sprint name]
- Sprint file: context/sprints/YYYY-MM-DD.md
```

### 9. Report

```
## Sprint Closed: 30 Mar - 13 Apr

**Completed:** 7 issues
**Carried over:** 5 issues → 13 Apr - 27 Apr (now active)
**Sprint file saved:** context/sprints/2026-03-30.md

### Context Updated
- context/people/... — [what changed]
- context/projects/... — [what changed]
```

---

## Subcommand: `create`

### 1. Determine sprint parameters

Look at the most recent sprint (active or closed) on the configured board:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$BASE_URL/rest/agile/1.0/board/BOARD_ID/sprint?state=active,closed&maxResults=5"
```

Find the latest sprint by end date. Auto-generate the new sprint:
- **Name:** Next date range following the naming pattern (e.g., "13 Apr - 27 Apr")
- **Start date:** Previous sprint's end date
- **End date:** Start date + cadence

If the user provided arguments beyond "create" (e.g., `/sprint create 14 Apr - 28 Apr`), use those as the sprint name and parse dates from it.

### 2. Confirm

```
## Create Sprint

**Name:** 13 Apr - 27 Apr
**Start:** 2026-04-13
**End:** 2026-04-27
**Board:** [board name] (BOARD_ID)

Create? (yes/no)
```

### 3. Create

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -X POST "$BASE_URL/rest/agile/1.0/sprint" \
  -d '{
    "name": "SPRINT_NAME",
    "startDate": "YYYY-MM-DDTHH:MM:SS.000Z",
    "endDate": "YYYY-MM-DDTHH:MM:SS.000Z",
    "originBoardId": BOARD_ID
  }'
```

### 4. Report

```
## Sprint Created: 13 Apr - 27 Apr
Sprint ID: NNNNN
State: future
```

---

## Error Handling

- If any API call returns a non-200 status, show the full error response and stop.
- If `$JIRA_API_TOKEN` is not set, tell the user: "Set JIRA_API_TOKEN in your shell profile. Generate one at https://id.atlassian.com/manage-profile/security/api-tokens"
- If `Jira email` is missing from `context/config.md`, ask the user to add it.
- If the active sprint is from another board (check `originBoardId`), skip it and note that no sprint is active on the configured board.
