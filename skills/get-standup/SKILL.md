---
name: ddclaw:get-standup
description: Fetch team standup updates from Slack, save to context/standups/, and update person/sprint/project files. Use when user says "get standup", "fetch standup", or "standup for [date]".
argument-hint: "[YYYY-MM-DD or 'yesterday' or 'today' -- defaults to yesterday]"
---

Fetch the async standup thread from Slack, extract each person's updates, save a structured summary, and propagate changes to relevant context files.

## 0. Load team config

Read `context/config.md` for:
- `Slack channel ID` -- the channel to fetch from
- `Channel name` -- for display
- `Team members` -- the expected roster (used to flag who's missing)

If `context/config.md` doesn't exist or is missing the standup section, ask the user to provide:
- Slack channel ID (e.g. C08MHL0GFJ7)
- Team member names (comma-separated)

## 1. Parse date

- If an argument is provided, parse it as a date (`YYYY-MM-DD`, or relative: `yesterday`, `today`, day name like `friday`).
- If no argument, default to **yesterday**.
- Store the resolved date as `TARGET_DATE` (YYYY-MM-DD format).
- Check if `context/standups/TARGET_DATE.md` already exists. If it does, skip to step 5 (context update only) and note that the standup file already existed.

## 2. Find the standup message

Use the Slack MCP tool to read recent messages from the channel:

```
slack_read_channel(channel_id=CHANNEL_ID, limit=20, response_format="detailed")
```

Scan the returned messages for the standup bot post matching `TARGET_DATE`:
- Look for a message from the bot (usually `B08NFHF1VCG` or similar bot ID) containing "async daily update"
- Match by the message timestamp date — convert the message's datetime to a date and compare with `TARGET_DATE`
- Note the `Message TS` value — this is needed to read the thread

**If the standup post for TARGET_DATE is not in the first page:** Use the `oldest` parameter to narrow the time range, or paginate with the `cursor` returned. For dates more than a few days back, calculate an approximate Unix timestamp for the start of that day and use it as `oldest`.

**Tip for Unix timestamp calculation:** `TARGET_DATE` at 00:00 CET (Europe/Madrid) can be computed with:
```
date -j -f "%Y-%m-%d %H:%M:%S %z" "TARGET_DATE 00:00:00 +0100" "+%s"
```

## 3. Read the thread

Use the thread's parent message timestamp to fetch all replies:

```
slack_read_thread(channel_id=CHANNEL_ID, message_ts=STANDUP_TS, response_format="detailed")
```

This returns the parent message and all replies with author names, user IDs, timestamps, and full message content.

## 4. Extract thread content

For each reply in the thread (skip the parent — that's the bot prompt):
- **Author:** From the message sender name
- **Time:** From the message timestamp
- **Content:** The full message text, including:
  - Plain text content
  - URLs (PRs, Jira tickets)
  - Bullet points and formatting
  - Any "Yesterday" / "Today" / "Friday" headers within individual updates

Extract each person's update preserving:
- Bullet point structure
- PR numbers and links (e.g., `#273582`, `PROJ-407`)
- Jira ticket references (e.g., `PROJ-393`)

**Note who's missing.** Compare against the team members list from config. Flag anyone not in the thread. Also check the channel messages (from step 2) for separate messages from missing people (e.g., sick notices, OOO).

**Build the Slack URL** from the channel ID and parent message timestamp:
```
https://dd.slack.com/archives/CHANNEL_ID/pTIMESTAMP
```
Where TIMESTAMP is the message_ts with the dot removed (e.g., `1773824415.151599` → `p1773824415151599`).

## 5. Save standup file

Write to `context/standups/TARGET_DATE.md` using this format:

```markdown
# TARGET_DATE Standup

Source: [slack URL from step 4]

## [Name] ([time])
- [bullet points of their update]
- **Yesterday/Today** headers if present in their update

## Missing
- **[Name]** -- [reason if known, e.g., "posted separately that they were sick", or "no post"]
```

Preserve PR links as `#NNNNN`, Jira tickets as `PROJ-NNN`. Keep the content faithful to what was posted -- summarize lightly but don't lose detail.

## 6. Update context files - **PEOPLE, SPRINTS, PROJECTS**

Read each relevant context file before editing. Only update where the standup provides **new information not already captured**.

### 6a. Person files (`context/people/*/README.md`)

For each person who posted in the standup:
- **Current Focus:** Update if the standup reveals new work started, significant progress, or a shift in priorities not already reflected.
- **Open Items:** Check off items that standup shows as completed. Add new items if clearly actionable.
- **Flags:** Add if someone is sick, blocked, or flagged something concerning.
- **Notes:** Append a dated note only if the standup contains significant context (not routine updates).

Skip updating a person file if their standup is routine and everything is already captured.

### 6b. Sprint file (latest in `context/sprints/`)

- Update commitment statuses where standup shows a task moved to done or a new blocker appeared.
- Update risks if standup reveals new information.

Skip if their update is routine and already captured.

### 6c. Project files (`context/projects/*/README.md`)

- Append a dated standup summary to the **History** section of the main relevant project. Keep it concise -- one line per person.
- If the standup reveals a project milestone or completion, update **Current Priorities**.

Skip if their update is routine and already captured.

### 6d. Memory file

Append a brief note to `memory/YYYY-MM-DD.md` (today's date) recording that the standup was fetched and which files were updated.

## 7. Report

Output a summary:

```
## Standup: TARGET_DATE

**Fetched:** X replies from N team members
**Missing:** [names with reason]

### Updates
[Per-person summary]

### Context Updated
- `context/people/name/README.md` -- [what changed]
- `context/sprints/file.md` -- [what changed]
- `context/projects/name/README.md` -- [what changed]

### Skipped (no meaningful update needed)
- [files where standup didn't add new info]
```
