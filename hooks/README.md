# Pre-Tool-Use Security Hook for Claude Code

**Blocks dangerous bash commands before they execute.**

## Installation

```bash
# One-command install
curl -fsSL https://raw.githubusercontent.com/YOUR-FORK/claude-builders-bounty/main/hooks/pre-tool-use.sh \
  -o ~/.claude/hooks/pre-tool-use.sh && chmod +x ~/.claude/hooks/pre-tool-use.sh
```

Or manually:

```bash
git clone https://github.com/YOUR-FORK/claude-builders-bounty
cp claude-builders-bounty/hooks/pre-tool-use.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/pre-tool-use.sh
```

The hook is automatically picked up by Claude Code — no settings.json changes needed.

## What It Blocks

| Pattern | Example |
|---------|---------|
| `rm -rf /` or `rm -rf ~` | `rm -rf / --no-preserve-root` |
| SQL destructive statements | `DROP TABLE`, `TRUNCATE`, `DELETE FROM` without WHERE |
| Force git pushes | `git push --force`, `git push -f origin main:`` |
| Disk destruction | `mkfs.*`, `dd if=... of=/dev/sd*` |
| Permission abuse | `chmod -R 000 /`, `chown -R 0:0 /` |

## Logs

Every blocked command is logged to `~/.claude/hooks/blocked.log` with:
- Timestamp
- Project path
- Attempted command

## How It Works

The hook reads the tool invocation as JSON from stdin, extracts the command,
and checks it against a list of dangerous patterns. Safe commands pass through
with `{"approved": true}`. Blocked commands return `{"approved": false}` with
an explanation.

## Compatibility

Works with Claude Code's `pre-tool-use` hook system on Linux, macOS, and Windows (Git Bash/WSL).
