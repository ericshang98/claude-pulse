# Claude Pulse

**保持 Claude Code token 配额常新——还能让 Claude 趁你睡觉干活。**

[English](README.md)

---

> 你是不是总为 Claude Code 五小时的 token 限额而发愁？想让 Claude 在你休息的时候自动完成任务？

Claude Code 的 token 配额从**上次使用起每 5 小时刷新一次**。这意味着每晚睡觉时你都在浪费刷新窗口。每天早上坐到电脑前，配额还没恢复好。

**Claude Pulse** 解决这个问题。它在你设定的时间自动触发——可以是极简的 pulse 保持配额新鲜，**真正的任务**让 Claude Code 自主执行，或者 **Auto 模式**让 Claude 自动规划并用多个并行 worker 执行复杂的多步骤工作。每个触发时间支持多任务，全部并行运行。

## 工作原理

```
   你在睡觉          Claude Pulse 触发              你醒了
   zzz...      →     03:30  pulse (刷新配额)     →  配额已满！
                      03:30  "Review code changes"    代码已审！
                      03:30  "Run all tests"          测试通过！
                                                      直接开干。
```

Claude Pulse 利用 macOS 的 `launchd` 调度触发。每次触发可以运行一个或多个任务，**全部并行**：

- **Pulse** — 单词级提示（约 1 token，约 $0.01），重置配额计时器
- **Prompt** — 自定义指令，Claude Code 自主执行（可设置最大轮次和工作目录）
- **Auto** — Claude 分析项目、分解任务、启动多个并行 Claude Code 实例执行、最终生成汇总报告

对于凌晨的触发，它甚至能通过 `pmset` 把你的 Mac 从睡眠中唤醒。

## 特性

- **多任务触发** — 同一时间点挂载多个任务（pulse + 自定义 prompt）
- **并行执行** — 一个触发器里的所有任务同时运行，不排队
- **自定义 Prompt** — 调度真正的工作：代码审查、测试、重构
- **Auto 模式** — Claude 自动编排复杂工作：分析 → 规划 → 并行执行 → 汇总报告
- **规模预设** — Light（3 worker）、Standard（5 worker）、Heavy（10 worker）
- **任务历史** — `claude-pulse jobs` 查看 Auto 模式的执行结果和汇总
- **逐任务日志** — `Task 1/3 [pulse] SUCCESS: 14s`、`Task 2/3 [prompt] SUCCESS: 42s`
- **全程无需打字** — 纯箭头键交互式 TUI
- **智能时间网格** — 半小时间隔，实时显示有效时间窗口
- **每日循环触发** — 设定每天固定时间（如 03:30、08:30、13:30）
- **一次性触发** — 指定具体日期和时间
- **自动唤醒** — 凌晨触发时通过 `pmset` 唤醒 Mac（00:00–06:59）
- **自动清理** — 过期的一次性触发和 30 天前的日志自动删除
- **智能重试** — pulse 失败会重试；prompt 不重试（避免重复执行）
- **自动迁移** — v1 配置自动升级为 v2

## 配置示例

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

任务配置流程——选完时间后，选择 Claude 要做什么：

```
  Task for 13:30:
    Pulse (token refresh)
    Custom prompt (Claude executes a task)
  ▸ Auto (Claude plans and executes)

  Describe the work for Claude:
  (or @filepath to load from file)
  > 重构认证模块并添加单元测试

  Scale:
  ▸ Standard — 5 workers, 10 turns each (Recommended)

  Add another task?
  ▸ No, done
```

## 有效时间窗口预览

选择触发时间时，Claude Pulse 会实时告诉你配额的有效时间段：

```
  Select times  Space toggle  Enter confirm  q back

    00:30   01:30   02:30   03:30   04:30   05:30
    06:30  [07:30]  08:30   09:30   10:30   11:30
    12:30   13:30   14:30   15:30   16:30   17:30
    18:30   19:30   20:30   21:30   22:30   23:30

  ▶ 07:30 → 02/10 一 Mon 07:00 - 12:00

  ←→↑↓ navigate
```

跨天触发会显示两个日期：
```
  ▶ 22:30 → 02/10 一 Mon 22:00 - 02/11 二 Tue 03:00
```

## 环境要求

- macOS（依赖 `launchd`、`pmset`、`caffeinate`）
- 已安装 [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- Python 3（macOS 自带）

## 安装

```bash
git clone https://github.com/ericshang98/claude-pulse.git
cd claude-pulse
bash install.sh
```

这会在 `/usr/local/bin/claude-pulse` 创建一个符号链接。

## 快速开始

```bash
claude-pulse setup
```

就这么简单。用方向键操作：

1. 选择 **"Add recurring daily triggers"**（每日循环）或 **"Add one-time trigger"**（一次性）
2. 在可视化时间网格中选择时间段（空格切换，回车确认）
3. 为每个新时间配置任务——**Pulse** 或 **自定义 Prompt**
4. 选择 **"Apply and finish"**

Claude Pulse 会自动处理剩下的一切——配置文件、定时任务、唤醒计划。

## 命令一览

| 命令 | 说明 |
|------|------|
| `claude-pulse setup` | 交互式配置（触发器 + 任务） |
| `claude-pulse start` | 启用所有触发 |
| `claude-pulse stop` | 停用所有触发 |
| `claude-pulse status` | 查看状态和已配置的任务 |
| `claude-pulse logs` | 最近的触发日志 |
| `claude-pulse logs --today` | 今天的日志 |
| `claude-pulse logs -n 50` | 最近 50 条 |
| `claude-pulse logs 2026-02-10` | 指定日期的日志 |
| `claude-pulse jobs` | 列出所有 Auto 模式任务 |
| `claude-pulse jobs --last` | 查看最近一次任务汇总 |
| `claude-pulse jobs <job_id>` | 查看指定任务汇总 |

## 示例：夜间代码审查 + Token 刷新

在 03:30 设一个每日触发，挂两个任务：

```
  Daily 03:30:
    - pulse
    - prompt: "Review recent changes for bugs" (10 turns)
```

两个任务**并行执行**。日志展示逐任务结果：

```
[2026-02-10 03:30:05] Task 1/2 [pulse] SUCCESS: 8s
[2026-02-10 03:30:47] Task 2/2 [prompt] SUCCESS: 42s "Review recent changes for bugs"
[2026-02-10 03:30:47] Trigger finished: 2 succeeded, 0 failed out of 2 tasks
```

## 示例：Auto 模式 — 夜间多任务并行

调度复杂工作，Claude 自动分解并并行执行：

```
  Daily 02:30:
    - auto: "重构认证模块，添加单元测试，更新文档" (standard)
```

Claude Pulse 会：
1. **编排器** — 分析项目，将工作拆分为 5 个独立子任务
2. **Worker** — 启动 5 个并行的 Claude Code 实例，各自处理一个子任务（每个 10 轮）
3. **汇总器** — 读取所有结果，生成 Markdown 报告

早上起来查看结果：
```bash
claude-pulse jobs --last
```

任务文件存储在 `~/.claude-pulse/jobs/`：
```
20260210-0230-a1b2/
  ├── input.md        # 你的原始请求
  ├── plan.json       # 编排器的任务分解
  ├── workers/        # 各 worker 的独立输出
  │   ├── 01-refactor-auth.md
  │   ├── 02-add-unit-tests.md
  │   └── 03-update-docs.md
  ├── summary.md      # 最终汇总报告
  └── meta.json       # 任务元数据（状态、耗时、计数）
```

用 `@文件路径` 加载长输入：
```
  > @/path/to/spec.md    ← 加载文件内容作为输入（不限长度）
```

## 推荐方案：24 小时全覆盖

每 5 小时设一个触发，token 全天候可用：

```
触发时间:  03:30  →  08:30  →  13:30  →  18:30  →  23:30
覆盖范围:  03-08     08-13     13-18     18-23     23-04
```

每天 5 次触发，每次约 $0.01 = **每天约 $0.05**，换来随时满配额。

## 配置结构（v2）

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
        {"mode": "auto", "input": "重构认证模块并添加测试", "scale": "standard"}
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

已有的 v1 配置会在首次运行时自动迁移。

## 技术细节

1. `claude-pulse setup` 会生成：
   - `~/.claude-pulse/config.json` — 你的配置（v2 格式）
   - `~/.claude-pulse/trigger.sh` — 触发脚本
   - `~/Library/LaunchAgents/com.claude-pulse.*.plist` — 每个触发时间一个 launchd 代理

2. 每个 launchd 代理在预定时间运行 `caffeinate -i trigger.sh <type> <time> [date]`

3. `trigger.sh` 的执行流程：
   - 检查 pulse 是否启用
   - 检测网络连通性（失败后 30 秒重试）
   - 从配置中读取该触发器的所有任务
   - **并行启动**所有任务（后台进程）
   - 等待全部完成，逐任务记录结果
   - pulse 失败会重试；prompt 不重试
   - auto 任务执行三阶段管道（编排器 → worker → 汇总器）
   - 清理过期的一次性触发、旧日志和旧任务记录（>30天）

## 卸载

```bash
bash uninstall.sh
```

这会移除所有代理、配置文件和符号链接。如果还需要取消 pmset 唤醒计划：

```bash
sudo pmset repeat cancel
```

## 为什么叫 "Pulse"？

Pulse 是脉搏，是最微小的生命迹象。Claude Pulse 做的就是这件事——发送一次心跳，让你的 token 配额保持活力。现在，它还能趁机帮你干活。

## 作者

<a href="https://github.com/ericshang98">
  <img src="https://avatars.githubusercontent.com/u/200189264?v=4" width="80" style="border-radius:50%" alt="Eric Shang"/>
</a>

**[Eric Shang](https://github.com/ericshang98)** — AI 原生工具构建者。同时在做 [Nexting AI](https://github.com/ericshang98) (AEO 平台) 和 [Perfect Web Clone](https://github.com/ericshang98/Perfect-Web-Clone)。

- Twitter/X: [@EricShang98](https://twitter.com/EricShang98)

## 参与共创

Claude Pulse 是开源项目，欢迎一起共创！无论是 Linux/Windows 支持、新的调度功能，还是更好的交互体验——欢迎提 PR 和 Issue。

```bash
# Fork, clone, hack, PR
git clone https://github.com/<your-username>/claude-pulse.git
```

### 贡献者

<a href="https://github.com/ericshang98/claude-pulse/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=ericshang98/claude-pulse" />
</a>

## 许可证

MIT
