# ddclaw plugin

Personal-agent plugin for Claude Code focused on memory persistence, meeting prep, and execution tracking.

## Install

### From Datadog marketplace (recommended)

```bash
claude plugin marketplace add https://github.com/DataDog/claude-marketplace
```

Then inside Claude Code:

```bash
/plugin install ddclaw@datadog-claude-plugins
```

### From standalone repo

```bash
/plugin marketplace add DavyBello/ddclaw-plugin
/plugin install ddclaw@DavyBello-ddclaw-plugin
```

## What this plugin includes

- `hooks/session-start-memory.sh`
  - Loads `LONG_TERM.md`, today's memory file, yesterday's memory file, and `context/projects/README.md` into session context on start.
- `skills/`
  - `ddclaw:prep` — Prepare for a 1:1 or meeting
  - `ddclaw:save` — Save session context to memory
  - `ddclaw:catch-me-up` — Status briefing (PRs, blockers, action items)
  - `ddclaw:my-prs` — Fetch PRs assigned to you personally
  - `ddclaw:action-items` — See all open action items
  - `ddclaw:add-person` — Add someone you work with
  - `ddclaw:add-project` — Track a project
  - `ddclaw:sync-context` — Sync index files with folder contents
  - `ddclaw:weekly-review` — End-of-week review and health check
  - `ddclaw:peer-feedback` — Generate structured peer feedback
  - `ddclaw:manager-evaluation` — Write a manager evaluation for a report
  - `ddclaw:get-standup` — Fetch standup from Slack (needs team config)

## Using with other AI tools

The core memory system works with any AI coding tool that reads markdown files. `CLAUDE.md` provides instructions for Claude Code, while `AGENTS.md` contains the same instructions for tools like OpenAI Codex that look for that filename.

However, skills (e.g. `/ddclaw:prep`, `/ddclaw:save`, `/ddclaw:catch-me-up`) are Claude Code-specific and won't be available out of the box in other tools. Each tool has its own skill/command system:

- **Codex** — custom commands
- **Bits (Datadog)** — `.skills/` directory with a different format

If you want the same workflows in another tool, ask your agent to read the generated Claude skills in `.claude/skills/` and port them to the equivalent format for your tool. The skill logic is plain markdown — it translates straightforwardly.

## Recommended plugins

These pair well with ddclaw:

- **[superpowers](https://github.com/obra/superpowers)** — better planning, debugging, code review, and verification skills
  ```bash
  /plugin marketplace add obra/superpowers
  /plugin install superpowers@obra-superpowers
  ```
- **episodic-memory** — vector search across past conversations
  ```bash
  /plugin install episodic-memory@superpowers-marketplace
  ```

## Optional scaffold setup

This repo also includes `setup.sh` to scaffold a new personal-agent workspace:

```bash
bash setup.sh
```

The script creates project/context templates, optionally prompts for team config (Slack channel, team roster), and prints plugin install steps at the end.

## Plugin metadata

Plugin manifest: `.claude-plugin/plugin.json`

## License

MIT - see `LICENSE`.
