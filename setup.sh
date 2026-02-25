#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# Personal Agent Setup for Claude Code (ddclaw)
# Creates a persistent, context-aware agent repo with
# memory, project tracking, people files, and custom skills.
#
# Skills and hooks are provided by the ddclaw plugin.
# This script only scaffolds the folder structure and seed files.
# ─────────────────────────────────────────────────────────

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

step() { echo -e "\n${BOLD}${CYAN}[$1/5]${RESET} ${BOLD}$2${RESET}"; }
created() { echo -e "  ${GREEN}+${RESET} $1"; }
skipped() { echo -e "  ${DIM}skip${RESET} $1 (already exists)"; }

write_file() {
  local path="$1"
  local content="$2"
  mkdir -p "$(dirname "$path")"
  if [ -f "$path" ]; then
    skipped "$path"
    return 0
  fi
  echo "$content" > "$path"
  created "$path"
  return 0
}

expand_home_path() {
  local input="$1"
  if [ "$input" = "~" ]; then
    printf '%s' "$HOME"
  elif [[ "$input" == "~/"* ]]; then
    printf '%s' "$HOME/${input#"~/"}"
  else
    printf '%s' "$input"
  fi
}

json_escape() {
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

# ─────────────────────────────────────────────────────────
# Gather info
# ─────────────────────────────────────────────────────────

echo -e "${BOLD}Personal Agent Setup (ddclaw)${RESET}"
echo "Answer a few questions to personalize your agent."
echo ""

read -rp "Your name: " USER_NAME
read -rp "Your role (e.g. EM, Staff Engineer, PM): " USER_ROLE
read -rp "Your company/team: " USER_COMPANY
read -rp "Your timezone (e.g. US/Eastern, Europe/London): " USER_TZ

DEFAULT_DIR="$HOME/my-agent"
read -rp "Directory to create [${DEFAULT_DIR}]: " AGENT_DIR
AGENT_DIR="${AGENT_DIR:-$DEFAULT_DIR}"
AGENT_DIR="$(expand_home_path "$AGENT_DIR")"

echo ""
echo -e "Will create agent at: ${BOLD}${AGENT_DIR}${RESET}"
read -rp "Continue? [Y/n] " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

# ─────────────────────────────────────────────────────────
step 1 "Initialize git repo"
# ─────────────────────────────────────────────────────────

if [ -d .git ]; then
  skipped ".git (already initialized)"
else
  git init -q
  created ".git"
fi

# ─────────────────────────────────────────────────────────
step 2 "Create folder structure"
# ─────────────────────────────────────────────────────────

for dir in memory context/projects context/people context/org context/self context/sprints jira; do
  mkdir -p "$dir"
done
created "memory/ context/ jira/"

# ─────────────────────────────────────────────────────────
step 3 "Write CLAUDE.md + AGENTS.md"
# ─────────────────────────────────────────────────────────

AGENT_INSTRUCTIONS="# CLAUDE.md -- Personal Agent

## Who You Are
Direct, resourceful, opinionated. No filler. Figure things
out before asking. If you're uncertain, say so -- don't
bullshit.

## Who I Am
- ${USER_NAME} -- ${USER_ROLE} @ ${USER_COMPANY}
- Timezone: ${USER_TZ}
- I'm time-constrained
- I prefer action over discussion
- When I say \"yes,\" move fast -- don't re-discuss

## Memory Protocol

### Session start
1. Read LONG_TERM.md - curated lasting knowledge
2. Read memory/YYYY-MM-DD.md (today + yesterday)
3. Read context/projects/README.md for current priorities
4. If I mention a person, read their file from context/people/

### Write as you go -- don't wait
After any of these, immediately append to memory/YYYY-MM-DD.md:
- A decision is made
- An action item is created or completed
- I share context about a person, project, or situation
- Feedback given or received
- Something worth remembering later comes up
- I say \"remember this\" -- write it immediately

Don't ask permission. Just write it.
No \"mental notes\" -- if it matters, it goes in a file

### What goes where
- **memory/YYYY-MM-DD.md** -- daily raw log. what happened today. Append-only.
- **LONG_TERM.md** -- curated knowledge that stays relevant across weeks/months. Actively maintained, not append-only.

### LONG_TERM.md triggers -- update immediately when:
- Codebase location shared (e.g., \"web-ui is at ~/dd/web-ui\")
- Tool/workflow preference expressed
- Recurring context that will be useful in future sessions
- Lesson learned from a mistake

### Manual save
When I say \"save\", \"done\", or \"wrap up\":
- Review the conversation for anything not yet logged
- Append remaining items to memory/YYYY-MM-DD.md
- Confirm what you saved

### Curation
If I say \"curate memory\":
- Review recent memory/ files
- Distill lasting knowledge into LONG_TERM.md
- Remove stale info from LONG_TERM.md
- Keep LONG_TERM.md under 3KB

## Context Files (read on demand, not every session)
- \`context/CODING.md\` -- coding rules (MUST read before any coding task)
- \`context/org/README.md\` -- team mission, OKRs, org structure
- \`context/projects/*/README.md\` -- active work, sprint status (one folder per project)
- \`context/people/*/README.md\` -- one folder per person
- \`context/people/README.md\` -- index of who's who
- \`context/self/feedback.md\` -- personal feedback tracker
- \`jira/README.md\` -- board structure, conventions

Read the relevant file when context is needed. Don't guess.

## Behavioral Triggers

### \"prep for [name]\"
- Read their person file from context/people/
- Check recent memory for anything involving them
- Surface: open action items, growth goals, things to
  discuss, any flags
- Draft an agenda

### \"prep for [meeting]\"
- Pull relevant project/org context
- Draft talking points and questions
- Flag any decisions needed

### \"catch me up\"
- Open PRs needing review (via \`gh\`)
- Action items from recent memory
- Any blockers noted in memory

### \"research [topic]\"
- Go deep, cite sources
- Lead with the insight, not the methodology
- Give your opinion, not just a summary

### \"draft [something]\"
- Match the audience (exec = concise, team = detailed)
- First draft should be sendable, not a starting point
- Don't ask me to confirm the approach -- just write it

### When I share meeting notes or 1:1 summaries
- After processing the content, review my management approach
- Read \`context/self/feedback.md\` for existing patterns
- Note what I did well and what I missed
- Append findings to the feedback log
- Be honest and specific -- no cheerleading

## Rules
- Ask before destructive actions
- Shorter is almost always better
- If I send one word (\"yes\", \"do it\", \"go\") -- execute,
  don't ask for clarification
- Push back when you see flaws, but don't be contrarian
  for sport
- No \"Great question!\" or \"I'd be happy to help!\" -- just help
- When writing code: read \`context/CODING.md\` first
- Flag incomplete or inconsistent information upfront"

write_file "CLAUDE.md" "$AGENT_INSTRUCTIONS"

# AGENTS.md is the same content (for Codex/other agent compatibility)
write_file "AGENTS.md" "$AGENT_INSTRUCTIONS"

# ─────────────────────────────────────────────────────────
step 4 "Write templates and seed files"
# ─────────────────────────────────────────────────────────

write_file "LONG_TERM.md" "# Long Term Memory

## Lessons Learned

## Codebases

## Active Projects
"

write_file "context/CODING.md" "# Coding Rules

Read this file when doing any coding task (bug fixes, features, refactoring).

## Principles
[Add coding principles specific to your work here]

## Test Design
[Add test conventions and patterns here]

## PR Readiness
[Add your PR checklist here]
"

write_file "context/org/README.md" "# Org Context

## Team
- **Team:** [Your team name]
- **Mission:** [What your team does]
- **Manager:** [Your manager]

## Key People
[Fill in as you go -- or use /add-person]
"

write_file "context/projects/README.md" "# Projects

## Active
[Use /add-project to add projects here]

## Blocked

## Paused

---

One folder per project: \`project-name/README.md\`
"

write_file "context/projects/_TEMPLATE.md" "# [Project Name]

**Status:** active | paused | blocked
**People:** [key people involved]
**Goal:** [one-line description]

## Current Priorities
- [ ] [priority item]

## Notes
[context, blockers, decisions pending]

## History
[major milestones, decisions made]
"

write_file "context/people/README.md" "# People

## Direct Reports

## Key Partners

## Leadership

---

One folder per person: \`firstname-lastname/README.md\`
"

write_file "context/people/_TEMPLATE.md" "# [Name]

**Role:** [Title]
**Team:** [Team name]
**Reports to:** [Manager]

## Working Style
- [How they communicate, what they value]

## Strengths
- [What they're good at]

## Growth Areas
- [What they're working on developing]

## Current Focus
- [What they're heads-down on right now]

## Open Items
- [ ] [Action items, things to follow up on]

## Things to Discuss
- [Topics to raise in next conversation]

## Flags
- [Concerns, risks, things to watch]
"

write_file "context/self/feedback.md" "# Feedback Tracker

## Strengths (patterns across feedback)

## Growth Areas (patterns across feedback)

## Raw Feedback Log
"

write_file "context/sprints/README.md" "# Sprint Planning Tracker

One file per sprint, named by planning date: \`YYYY-MM-DD.md\`

## Conventions

- **File created** during or right after sprint planning
- **Outcomes section** filled at sprint end (retro or next planning)
- Carryover for next sprint = items that slipped from this one
- Tickets link to Jira where possible

## Template

\`\`\`markdown
# Sprint YYYY-MM-DD → YYYY-MM-DD

## Capacity
- [availability notes, PTO, reduced capacity, onboarding]

## Carryover
- [what didn't land last sprint + why]

## Commitments
| Ticket | Owner | Goal | Status |
|--------|-------|------|--------|
| PROJ-XXX | Name | description | planned |

## Decisions
- [prioritization calls, scope changes, trade-offs]

## Risks / Flags
- [dependencies, blockers, things that might slip]

## Outcomes (sprint end)
- [what landed, what didn't, surprises]
\`\`\`
"

write_file "jira/README.md" "# Jira

## Boards
[List your team's Jira boards]

## Conventions
[Ticket naming, labels, workflow states]

## Notes
[Board-specific context, triage process, etc.]
"

# ─────────────────────────────────────────────────────────
step 5 "Write .gitignore and settings"
# ─────────────────────────────────────────────────────────

write_file ".gitignore" "# Daily memory logs (personal)
memory/

# People notes (personal -- keep template and index)
context/people/*/*.md
context/self/*
!context/people/_TEMPLATE.md
!context/people/README.md

# Local settings
.claude/settings.local.json

# OS
.DS_Store
*.swp
*.swo
*~"

AGENT_DIR_TILDE=$(echo "$AGENT_DIR" | sed "s|$HOME|~|")
AGENT_DIR_TILDE_JSON=$(json_escape "$AGENT_DIR_TILDE")

write_file ".claude/settings.json" "{
  \"permissions\": {
    \"allow\": [
      \"Read ${AGENT_DIR_TILDE_JSON}/**\",
      \"Edit ${AGENT_DIR_TILDE_JSON}/**\",
      \"Write ${AGENT_DIR_TILDE_JSON}/**\"
    ]
  }
}"

# ─────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}${GREEN}Done!${RESET} Your agent is ready at ${BOLD}${AGENT_DIR}${RESET}"
echo ""
echo -e "${BOLD}What was created:${RESET}"
echo ""
echo "  CLAUDE.md              Your agent's instructions"
echo "  AGENTS.md              Same instructions (Codex/agent compatibility)"
echo "  LONG_TERM.md           Curated cross-session memory"
echo "  memory/                Daily session logs (auto-managed)"
echo "  context/CODING.md      Coding rules template"
echo "  context/projects/      One folder per project"
echo "  context/people/        One folder per person"
echo "  context/sprints/       Sprint planning tracker (one file per sprint)"
echo "  context/self/          Personal feedback tracker"
echo "  context/org/README.md         Team/org structure"
echo "  jira/                  Jira board conventions"
echo "  .claude/settings.json  Permissions"
echo ""
echo -e "${BOLD}Install the ddclaw plugin (skills + hooks):${RESET}"
echo ""
echo "  cd '${AGENT_DIR}'"
echo "  claude"
echo "  # Then inside Claude Code:"
echo "  /install-plugin https://github.com/DavyBello/ddclaw-plugin"
echo ""
echo -e "${BOLD}Or install from marketplace (once available):${RESET}"
echo ""
echo "  /plugin marketplace add DavyBello/ddclaw-marketplace"
echo "  /plugin install ddclaw@ddclaw-marketplace"
echo ""
echo -e "${BOLD}Skills provided by the plugin:${RESET}"
echo ""
echo "  /prep <name>             Prep for a 1:1 or meeting"
echo "  /save                    Save session context to memory"
echo "  /catch-me-up             Get a status briefing (PRs, blockers, action items)"
echo "  /action-items            See all open action items"
echo "  /add-person <name>       Add someone you work with"
echo "  /add-project <name>      Track a project"
echo "  /sync-context            Sync index files with folder contents"
echo "  /weekly-review           End-of-week review and health check"
echo "  /peer-feedback <name>    Generate structured peer feedback"
echo ""
echo -e "${BOLD}Optional next steps:${RESET}"
echo ""
echo "  - Add MCP servers for Jira, Datadog, etc:"
echo "    claude mcp add datadog -- npx -y @anthropic/datadog-mcp-server"
echo "    claude mcp add atlassian -- npx -y @anthropic/atlassian-mcp-server"
echo ""
echo "  - Customize CLAUDE.md with your preferences and behavioral triggers"
echo "  - Fill in context/org/README.md with your team structure"
echo "  - Fill in context/CODING.md with your coding conventions"
echo "  - git add -A && git commit -m 'Initial agent setup'"
echo ""
