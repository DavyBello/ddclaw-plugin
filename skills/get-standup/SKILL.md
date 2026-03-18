---
name: ddclaw:get-standup
description: Fetch team standup updates from Slack, save to context/standups/, and update person/sprint/project files. Use when user says "get standup", "fetch standup", or "standup for [date]".
argument-hint: "[YYYY-MM-DD or 'yesterday' or 'today' -- defaults to yesterday]"
---

Fetch the async standup thread from Slack, extract each person's updates, save a structured summary, and propagate changes to relevant context files.

## 0. Load team config

Read `context/config.md` for:
- `Slack channel ID` -- the channel to fetch from
- `Slack workspace ID` -- the workspace
- `Channel name` -- for display
- `Team members` -- the expected roster (used to flag who's missing)

If `context/config.md` doesn't exist or is missing the standup section, ask the user to provide:
- Slack channel ID (e.g. C08MHL0GFJ7)
- Slack workspace ID (e.g. E023QM6JUS0)
- Team member names (comma-separated)

## 1. Parse date

- If an argument is provided, parse it as a date (`YYYY-MM-DD`, or relative: `yesterday`, `today`, day name like `friday`).
- If no argument, default to **yesterday**.
- Store the resolved date as `TARGET_DATE` (YYYY-MM-DD format).
- Check if `context/standups/TARGET_DATE.md` already exists. If it does, skip to step 7 (context update only) and note that the standup file already existed.

## 2. Navigate to Slack

Open the team channel via Playwright using the channel and workspace IDs from config:

```
browser_navigate -> https://app.slack.com/client/$WORKSPACE_ID/$CHANNEL_ID
```

Wait 3-5 seconds for the page to fully load, then take a snapshot:

```
browser_snapshot -> filename: .tmp-experimental/slack-standup-channel.md
```

## 3. Find the standup message

Search the snapshot for the standup workflow message matching `TARGET_DATE`.

**How to match the date:**
- Slack shows relative dates: "Today", "Yesterday", or full dates like "Feb 20th at 11:00:09 AM"
- Calculate what Slack would show for `TARGET_DATE` relative to today
- Look for a `listitem` containing both:
  - A workflow-style message (button with `WORKFLOW` badge)
  - A timestamp link matching the target date
- The message will have a `button "N replies"` -- note its `ref` attribute

**If the message is not visible:** The channel may need scrolling. Try the "Jump to date" button if present, or scroll up to find older messages.

**If there are multiple standup messages visible** (e.g., today's and yesterday's), match by the timestamp link text or the date separator heading above the message.

## 4. Open the thread

Click the "N replies" button on the matched standup message:

```
browser_click -> ref: [the ref from step 3], element: "N replies button on standup message"
```

Wait 2-3 seconds for the thread panel to load, then take a snapshot:

```
browser_snapshot -> filename: .tmp-experimental/slack-standup-thread.md
```

**Important:** Do NOT try to navigate directly to a thread URL -- Slack often shows "Couldn't load thread". Always click the replies button from the channel view.

## 5. Extract thread content

Read/grep the thread snapshot file. The thread panel appears as:

```
list "Thread in $CHANNEL_NAME (private channel, N replies)"
```

For each `listitem` in the thread (skip the first one -- that's the workflow prompt message):
- **Author:** Look for `button "Name"` in the message header
- **Time:** Look for `link "Yesterday at H:MM:SS PM"` or similar
- **Content:** The `generic` elements after the author/time contain the message text, including:
  - Plain text content
  - `link` elements with URLs (PRs, Jira tickets)
  - `list` / `listitem` elements for bullet points
  - `code` elements for inline code

Extract each person's update preserving:
- Bullet point structure
- PR numbers and links (e.g., `#273582`, `DNV-407`)
- Jira ticket references (e.g., `DNV-393`)
- Any "Yesterday" / "Today" / "Friday" headers within individual updates

**Note who's missing.** Compare against the team members list from config. Flag anyone not in the thread, and check the channel snapshot for separate messages from them (e.g., sick notices).

## 6. Get the Slack URL

Find the source URL of the standup workflow message from its timestamp link in the snapshot. It will be in the format:
```
https://dd.slack.com/archives/$CHANNEL_ID/p[timestamp]
```

## 7. Save standup file

Write to `context/standups/TARGET_DATE.md` using this format:

```markdown
# TARGET_DATE Standup

Source: [slack URL from step 6]

## [Name] ([time])
- [bullet points of their update]
- **Yesterday/Today** headers if present in their update

## Missing
- **[Name]** -- [reason if known, e.g., "posted separately that they were sick", or "no post"]
```

Preserve PR links as `#NNNNN`, Jira tickets as `DNV-NNN`. Keep the content faithful to what was posted -- summarize lightly but don't lose detail.

## 8. Update context files - **PEOPLE, SPRINTS, PROJECTS**

Read each relevant context file before editing. Only update where the standup provides **new information not already captured**.

### 8a. Person files (`context/people/*/README.md`)

For each person who posted in the standup:
- **Current Focus:** Update if the standup reveals new work started, significant progress, or a shift in priorities not already reflected.
- **Open Items:** Check off items that standup shows as completed. Add new items if clearly actionable.
- **Flags:** Add if someone is sick, blocked, or flagged something concerning.
- **Notes:** Append a dated note only if the standup contains significant context (not routine updates).

Skip updating a person file if their standup is routine and everything is already captured.

### 8b. Sprint file (latest in `context/sprints/`)

- Update commitment statuses where standup shows a task moved to done or a new blocker appeared.
- Update risks if standup reveals new information.

### 8c. Project files (`context/projects/*/README.md`)

- Append a dated standup summary to the **History** section of the main relevant project. Keep it concise -- one line per person.
- If the standup reveals a project milestone or completion, update **Current Priorities**.

### 8d. Memory file

Append a brief note to `memory/YYYY-MM-DD.md` (today's date) recording that the standup was fetched and which files were updated.

## 9. Report

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

## Cleanup

After completion, the temporary snapshot files in `.tmp-experimental/` can be left in place (they'll be overwritten on the next run).
