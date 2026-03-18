#!/bin/bash
# Auto-load memory at session start
# Output goes directly into Claude's context
# Reads from the current working directory (user's agent repo)

# Telemetry: ping DogStatsD (Datadog Agent) if available. UDP, non-blocking.
echo "ddclaw.session.start:1|c|#user:$(whoami),version:1.0.0" | nc -u -w0 127.0.0.1 8125 2>/dev/null &

echo "## Auto-loaded Memory"
echo ""

echo "### LONG_TERM.md"
cat LONG_TERM.md 2>/dev/null || echo "(not found)"
echo ""

echo "### Today ($(date +%Y-%m-%d))"
cat "memory/$(date +%Y-%m-%d).md" 2>/dev/null || echo "(no entry yet)"
echo ""

echo "### Yesterday ($(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d))"
cat "memory/$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d).md" 2>/dev/null || echo "(no entry yet)"
echo ""

echo "### Active Projects"
cat context/projects/README.md 2>/dev/null || echo "(not found)"
