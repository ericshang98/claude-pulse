# Claude Pulse

**Keep your Claude Code tokens fresh — and let Claude work while you sleep.**

[中文文档](README_CN.md)

---

> Tired of Claude Code's 5-hour token quota limit? Want Claude to handle tasks overnight while you rest?

Claude Code resets its token quota every **5 hours from your last usage**. That means every night you sleep through a refresh window. Every morning you sit down to code, you're already behind.

**Claude Pulse** fixes this. It schedules triggers at times you choose — a minimal pulse to keep tokens fresh, **real tasks** that Claude Code executes autonomously, or **auto mode** where Claude plans and executes complex multi-step work with parallel workers. Multiple tasks per trigger, all running in parallel.

## How It Works

```
   You sleep          Claude Pulse fires             You wake up
   zzz...      →      03:30  pulse (token refresh)  →  Quota is fresh!
                       03:30  "Review code changes"     Code reviewed!
                       03:30  "Run all tests"           Tests passed!
                                                        Ready to go.
```

Claude Pulse uses macOS `launchd` to schedule triggers. Each trigger can run one or more tasks **in parallel**:

- **Pulse** — a single-word prompt (~1 token, ~$0.01) to reset your quota timer
- **Prompt** — a custom instruction that Claude Code executes autonomously (with configurable max turns and work directory)
- **Auto** — Claude analyzes your project, decomposes work into sub-tasks, runs them in parallel via separate Claude Code instances, and generates a summary report

For nighttime triggers, it can even wake your Mac from sleep using `pmset`.

## Features

- **Multi-task triggers** — attach multiple tasks (pulse + prompts) to a single trigger time
- **Parallel execution** — all tasks in a trigger run concurrently, not sequentially
- **Custom prompts** — schedule real work for Claude: code reviews, test runs, refactoring
- **Auto mode** — Claude orchestrates complex work: analyze → plan → parallel workers → summary report
- **Scale presets** — Light (3 workers), Standard (5 workers), Heavy (10 workers)
- **Job history** — `claude-pulse jobs` to review auto mode results and summaries
- **Per-task logging** — `Task 1/3 [pulse] SUCCESS: 14s`, `Task 2/3 [prompt] SUCCESS: 42s`
- **Zero typing setup** — fully interactive TUI with arrow keys
- **Smart time grid** — 30-minute interval slots with real-time effective window preview
- **Recurring triggers** — set daily schedules (e.g., 03:30, 08:30, 13:30)
- **One-time triggers** — schedule specific date + time
- **Auto wake from sleep** — `pmset` integration for nighttime triggers (00:00–06:59)
- **Auto cleanup** — expired one-time triggers and old logs are removed automatically
- **Smart retry** — pulse tasks retry on failure; prompt tasks don't (to avoid duplicate work)
- **Auto-migration** — v1 configs are automatically upgraded to v2

## Setup Example

```
  === Claude Pulse Setup ===

  Configured triggers:
    One-time 2026-02-10 01:30:
      - pulse
    One-time 2026-02-10 13:30:
      - prompt: "检查一下这个产品的报错问题" (5 turns)

  What would you like to do?
  ▸ Apply and finish
```

The task configuration flow — after selecting a time, you choose what Claude should do:

```
  Task for 13:30:
    Pulse (token refresh)
    Custom prompt (Claude executes a task)
  ▸ Auto (Claude plans and executes)

  Describe the work for Claude:
  (or @filepath to load from file)
  > Refactor the authentication module and add unit tests

  Scale:
  ▸ Standard — 5 workers, 10 turns each (Recommended)

  Add another task?
  ▸ No, done
```

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
git clone https://github.com/ericshang98/claude-pulse.git
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
3. Configure tasks for each new time — **Pulse** or **Custom prompt**
4. Choose **"Apply and finish"**

Claude Pulse handles the rest — config, launchd agents, pmset wake schedules.

## Commands

| Command | Description |
|---------|-------------|
| `claude-pulse setup` | Interactive configuration (triggers + tasks) |
| `claude-pulse start` | Enable all triggers |
| `claude-pulse stop` | Disable all triggers |
| `claude-pulse status` | Show state and configured tasks |
| `claude-pulse logs` | Recent trigger logs |
| `claude-pulse logs --today` | Today's logs |
| `claude-pulse logs -n 50` | Last 50 entries |
| `claude-pulse logs 2026-02-10` | Logs for specific date |
| `claude-pulse jobs` | List all auto mode jobs |
| `claude-pulse jobs --last` | Show most recent job summary |
| `claude-pulse jobs <job_id>` | Show specific job summary |

## Example: Overnight Code Review + Token Refresh

Set up a nightly trigger at 03:30 with two tasks:

```
  Daily 03:30:
    - pulse
    - prompt: "Review recent changes for bugs" (10 turns)
```

Both tasks run **in parallel**. Logs show per-task results:

```
[2026-02-10 03:30:05] Task 1/2 [pulse] SUCCESS: 8s
[2026-02-10 03:30:47] Task 2/2 [prompt] SUCCESS: 42s "Review recent changes for bugs"
[2026-02-10 03:30:47] Trigger finished: 2 succeeded, 0 failed out of 2 tasks
```

## Example: Auto Mode — Overnight Multi-Task Work

Schedule complex work that Claude decomposes and executes in parallel:

```
  Daily 02:30:
    - auto: "Refactor the auth module, add unit tests, update docs" (standard)
```

Claude Pulse will:
1. **Orchestrator** — analyze the project, break work into 5 independent sub-tasks
2. **Workers** — spawn 5 parallel Claude Code instances, each handling one sub-task (10 turns each)
3. **Summarizer** — read all results, generate a Markdown report

Check results in the morning:
```bash
claude-pulse jobs --last
```

Job files are stored in `~/.claude-pulse/jobs/`:
```
20260210-0230-a1b2/
  ├── input.md        # Your original request
  ├── plan.json       # Orchestrator's task decomposition
  ├── workers/        # Individual worker outputs
  │   ├── 01-refactor-auth.md
  │   ├── 02-add-unit-tests.md
  │   └── 03-update-docs.md
  ├── summary.md      # Final summary report
  └── meta.json       # Job metadata (status, timing, counts)
```

Use `@filepath` for longer inputs:
```
  > @/path/to/spec.md    ← loads file content as input (any length)
```

## Example: 24h Token Coverage

To maximize token availability throughout the day, set triggers every 5 hours:

```
Triggers:  03:30  →  08:30  →  13:30  →  18:30  →  23:30
Coverage:  03-08     08-13     13-18     18-23     23-04
```

That's 5 triggers/day at ~$0.01 each = **~$0.05/day** for always-fresh tokens.

## Config Schema (v2)

```json
{
  "config_version": 2,
  "claude_path": "/Users/you/.local/bin/claude",
  "work_directory": "~",
  "enabled": true,
  "recurring_triggers": [
    {
      "time": "03:30",
      "tasks": [
        {"mode": "pulse"},
        {"mode": "prompt", "prompt": "Review code changes", "max_turns": 10},
        {"mode": "auto", "input": "Refactor auth and add tests", "scale": "standard"}
      ]
    }
  ],
  "onetime_triggers": [
    {
      "date": "2026-02-11",
      "time": "01:00",
      "tasks": [{"mode": "prompt", "prompt": "Run all tests", "max_turns": 5}]
    }
  ]
}
```

Existing v1 configs are automatically migrated on first run.

## How It Works (Technical)

1. `claude-pulse setup` generates:
   - `~/.claude-pulse/config.json` — your configuration (v2 schema)
   - `~/.claude-pulse/trigger.sh` — the trigger script
   - `~/Library/LaunchAgents/com.claude-pulse.*.plist` — one launchd agent per trigger

2. Each launchd agent runs `caffeinate -i trigger.sh <type> <time> [date]`

3. `trigger.sh`:
   - Checks if pulse is enabled
   - Verifies network connectivity (retries once after 30s)
   - Reads tasks for this trigger from config
   - Launches all tasks **in parallel** (background processes)
   - Waits for all to complete, logs per-task results
   - Pulse tasks retry on failure; prompt tasks don't
   - Auto tasks run the 3-phase pipeline (orchestrator → workers → summarizer)
   - Cleans up expired one-time triggers, old logs, and old jobs (>30 days)

## Uninstall

```bash
bash uninstall.sh
```

This removes all agents, config files, and the symlink. To also cancel the pmset wake schedule:

```bash
sudo pmset repeat cancel
```

## Why "Pulse"?

A pulse is the smallest sign of life. That's exactly what Claude Pulse sends — a single heartbeat to keep your token quota alive. And now, it can do real work while it's at it.

## Author

<a href="https://github.com/ericshang98">
  <img src="https://avatars.githubusercontent.com/u/200189264?v=4" width="80" style="border-radius:50%" alt="Eric Shang"/>
</a>

**[Eric Shang](https://github.com/ericshang98)** — Builder of AI-native tools. Also building [Nexting AI](https://github.com/ericshang98) (AEO platform) and [Perfect Web Clone](https://github.com/ericshang98/Perfect-Web-Clone).

- Twitter/X: [@EricShang98](https://twitter.com/EricShang98)

## Contributing

Claude Pulse is open source and welcomes contributions! Whether it's Linux/Windows support, new scheduling features, or better TUI — PRs and issues are welcome.

```bash
# Fork, clone, hack, PR
git clone https://github.com/<your-username>/claude-pulse.git
```

### Contributors

<a href="https://github.com/ericshang98/claude-pulse/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=ericshang98/claude-pulse" />
</a>

## License

MIT
