#!/bin/bash
# pre-tool-use.sh — Claude Code hook: blocks destructive bash commands
# Installed to ~/.claude/hooks/pre-tool-use.sh
# Logs all blocked attempts to ~/.claude/hooks/blocked.log

BLOCKED_LOG="$HOME/.claude/hooks/blocked.log"
PROJECT_PATH="${PWD:-unknown}"

# Read the command from stdin (Claude Code hooks pass tool input via stdin)
INPUT=$(cat)

# Extract the command text — handle both args.command and raw input
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    cmd = data.get('command') or data.get('args', {}).get('command', '')
    print(cmd)
except:
    print(sys.stdin.read())
" 2>/dev/null || echo "$INPUT")

# Dangerous patterns — case-insensitive matching
PATTERNS=(
  "rm\s+-rf\s+[/~]"
  "rm\s+-rf\s+/\s*$"
  "rm\s+-rf\s+/\s+\w"
  "rm\s+-rf\s+--no-preserve-root"
  "DROP\s+TABLE"
  "DROP\s+DATABASE"
  "TRUNCATE\s+\w+"
  "DELETE\s+FROM\s+\w+\s*(?!.*WHERE)"
  "git\s+push\s+--force"
  "git\s+push\s+-f\s+origin\s+\w+\s*:\s*"
  ":>\s*$"
  ">\s+/dev/sda"
  "mkfs\."
  "dd\s+if=.*of=/dev/sd"
  "chmod\s+-R\s+000\s+/"
  "chown\s+-R\s+\d+:\d+\s+/"
)

for PATTERN in "${PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$PATTERN" 2>/dev/null; then
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] BLOCKED | project: $PROJECT_PATH | cmd: $COMMAND" >> "$BLOCKED_LOG"
    echo "{\"approved\": false, \"message\": \"⛔ BLOCKED by security hook: command matches dangerous pattern '$PATTERN'. This command could cause data loss. If you're sure, run it manually.\"}"
    exit 0
  fi
done

# Command is safe
echo '{"approved": true}'
