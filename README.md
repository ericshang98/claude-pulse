# Claude Pulse

**Keep your Claude Code tokens fresh while you sleep.**

[中文文档](README_CN.md)

---

> Tired of Claude Code's 5-hour token quota limit? Do your tokens run out before your ideas do?

Claude Code resets its token quota every **5 hours from your last usage**. That means every night you sleep through a refresh window. Every morning you sit down to code, you're already behind.

**Claude Pulse** fixes this. It automatically triggers a minimal Claude Code request at times you choose — so your token quota is always fresh when you need it.

## How It Works

```
   You sleep          Claude Pulse fires        You wake up
   zzz...      →      03:30 trigger (1 token)  →  Quota is fresh!
                       08:30 trigger (1 token)     Ready to code.
```

Claude Pulse uses macOS `launchd` to schedule lightweight triggers. Each trigger sends a single-word prompt to Claude Code (`"reply with only the word: pulse"`), consuming ~1 token and costing ~$0.01. This resets your 5-hour quota timer.

For nighttime triggers, it can even wake your Mac from sleep using `pmset`.

## Features

- **Zero typing setup** — fully interactive TUI with arrow keys, no text input needed
- **Smart time grid** — 30-minute interval slots with real-time effective window preview
- **Recurring triggers** — set daily schedules (e.g., 03:30, 08:30, 13:30)
- **One-time triggers** — schedule specific date + time (e.g., Feb 10 at 07:30)
- **Cross-day awareness** — shows full date range when effective window spans midnight
- **Auto wake from sleep** — `pmset` integration for nighttime triggers (00:00–06:59)
- **Auto cleanup** — expired one-time triggers and old logs are removed automatically
- **Retry logic** — network check + automatic retry on failure

## The Effective Window

When selecting trigger times, Claude Pulse shows you exactly when your quota will be active:

```
  Select times  Space toggle  Enter confirm  q back

    00:30   01:30   02:30   03:30   04:30   05:30
    06:30  [07:30]  08:30   09:30   10:30   11:30
    12:30   13:30   14:30   15:30   16:30   17:30
    18:30   19:30   20:30   21:30   22:30   23:30

  ▶ 07:30 → 02/10 一 Mon 07:00 - 12:00

  ←→↑↓ navigate
```

Cross-midnight triggers show both dates:
```
  ▶ 22:30 → 02/10 一 Mon 22:00 - 02/11 二 Tue 03:00
```

## Requirements

- macOS (uses `launchd`, `pmset`, `caffeinate`)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Python 3 (pre-installed on macOS)

## Installation

```bash
git clone https://github.com/anthropics/claude-pulse.git
cd claude-pulse
bash install.sh
```

This creates a symlink at `/usr/local/bin/claude-pulse`.

## Quick Start

```bash
claude-pulse setup
```

That's it. Use arrow keys to:

1. Choose **"Add recurring daily triggers"** or **"Add one-time trigger"**
2. Select time slots from the visual grid (Space to toggle, Enter to confirm)
3. Choose **"Apply and finish"**

Claude Pulse handles the rest — config, launchd agents, pmset wake schedules.

## Commands

| Command | Description |
|---------|-------------|
| `claude-pulse setup` | Interactive configuration |
| `claude-pulse start` | Enable all triggers |
| `claude-pulse stop` | Disable all triggers |
| `claude-pulse status` | Show current state |
| `claude-pulse logs` | Recent trigger logs |
| `claude-pulse logs --today` | Today's logs |
| `claude-pulse logs -n 50` | Last 50 entries |
| `claude-pulse logs 2026-02-10` | Logs for specific date |

## Example: Optimal 24h Coverage

To maximize token availability throughout the day, set triggers every 5 hours:

```
Triggers:  03:30  →  08:30  →  13:30  →  18:30  →  23:30
Coverage:  03-08     08-13     13-18     18-23     23-04
```

That's 5 triggers/day at ~$0.01 each = **~$0.05/day** for always-fresh tokens.

## How It Works (Technical)

1. `claude-pulse setup` generates:
   - `~/.claude-pulse/config.json` — your configuration
   - `~/.claude-pulse/trigger.sh` — the trigger script
   - `~/Library/LaunchAgents/com.claude-pulse.*.plist` — one launchd agent per trigger

2. Each launchd agent runs `caffeinate -i trigger.sh` at the scheduled time

3. `trigger.sh`:
   - Checks if pulse is enabled
   - Verifies network connectivity (retries once after 30s)
   - Runs `claude -p "reply with only the word: pulse" --max-turns 1`
   - Logs the result to `~/.claude-pulse/logs/`
   - Retries once on failure
   - Cleans up expired one-time triggers and old logs (>30 days)

## Uninstall

```bash
bash uninstall.sh
```

This removes all agents, config files, and the symlink. To also cancel the pmset wake schedule:

```bash
sudo pmset repeat cancel
```

## Why "Pulse"?

A pulse is the smallest sign of life. That's exactly what Claude Pulse sends — a single heartbeat to keep your token quota alive.

## License

MIT
