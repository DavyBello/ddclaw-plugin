---
name: ddclaw:test-drive
description: Create, check, or manage a Rapid test drive for dd-source. Use when user says "test drive", "deploy test drive", "create test drive", or "check test drive".
---

Manage Rapid test drives for dd-source services. (Datadog-internal: requires the `rapid` CLI and access to dd-source.)

## Determine the action

- **create**: User wants to deploy a new test drive
- **status**: User wants to check on an existing test drive
- **list**: User wants to see all active test drives

If unclear, ask which action.

## Create

Required info (ask if not provided):
- **name**: Test drive identifier (used in header, e.g., `ds-roadster-v4`)
- **service**: Rapid service name (e.g., `mcp`)
- **branch**: Remote branch to deploy

### Steps

1. Identify the repo root or worktree where the branch is checked out
2. Verify the branch is pushed and local matches remote:
   ```bash
   git fetch origin <branch>
   git log --oneline origin/<branch>..<branch>
   ```
   If there are unpushed commits, the local ref is ahead of remote. Reset local to match:
   ```bash
   git reset --hard origin/<branch>
   ```
3. Create the test drive (do NOT use `--printer json` — rapid may need interactive prompts):
   ```bash
   cd <repo-root-or-worktree>
   rapid test-drive create --name <name> --service <service> --branch <branch>
   ```
4. Tell the user the header to use: `test-drive-<name>: 1`

## Status / List

```bash
cd <repo-root-or-worktree>
rapid test-drive list --service <service> --printer json 2>&1 | grep -v "debug\|telemetry\|Flushing"
```

Status transitions: `creating` (~10-15 min) -> `running`

## Turbo Updates (fast iteration)

For code-only changes (no config/infra changes), use the `-t` flag:
```bash
rapid test-drive update -t <name>
```

This is significantly faster than a normal update. Use it when:
- Only service code changed (Go, Python, etc.)
- No rapid.json, BUILD.bazel, or infrastructure changes

Use normal `rapid test-drive update <name>` when:
- Service configuration changed
- Testing infrastructure/config changes
- Regression testing

## Common services

- **mcp**: MCP tools service (graphing MCP tools like get_widget)

## Upgrading Rapid CLI

If `rapid` fails with a minimum version error, upgrade via Homebrew:
```bash
brew upgrade rapid
```

## Notes

- Test drives deploy a branch to staging for QA
- The header routes staging requests to the test drive build
- Always run from the repo root or a worktree that has the target branch checked out
- dd-source repo locations: `~/dd-source` (main checkout), worktrees under `~/dd-source/.worktrees/`
