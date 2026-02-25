# ddclaw plugin

Personal-agent plugin for Claude Code focused on memory persistence, meeting prep, and execution tracking.

## Install

### Direct install (recommended)

```bash
/install-plugin https://github.com/DavyBello/ddclaw-plugin
```

### Marketplace install (when published)

```bash
/plugin marketplace add DavyBello/ddclaw-marketplace
/plugin install ddclaw@ddclaw-marketplace
```

## What this plugin includes

- `hooks/session-start-memory.sh`
  - Loads `LONG_TERM.md`, today's memory file, yesterday's memory file, and `context/projects/README.md` into session context on start.
- `skills/`
  - `prep`
  - `save`
  - `catch-me-up`
  - `action-items`
  - `add-person`
  - `add-project`
  - `sync-context`
  - `weekly-review`
  - `peer-feedback`

## Optional scaffold setup

This repo also includes `setup.sh` to scaffold a new personal-agent workspace:

```bash
bash setup.sh
```

The script creates project/context templates and prints plugin install steps at the end.

## Plugin metadata

Plugin manifest: `.claude-plugin/plugin.json`

## License

MIT - see `LICENSE`.
