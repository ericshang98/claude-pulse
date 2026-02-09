# Claude Pulse

**睡觉的时候，帮你保持 Claude Code 的 token 配额常新。**

[English](README.md)

---

> 你是不是总为 Claude Code 五小时的 token 限额而发愁？你的 token 总是跟不上你的经验和想法？

Claude Code 的 token 配额从**上次使用起每 5 小时刷新一次**。这意味着每晚睡觉时你都在浪费刷新窗口。每天早上坐到电脑前，配额还没恢复好。

**Claude Pulse** 解决这个问题。它在你设定的时间自动触发一次极简的 Claude Code 请求——让你的 token 配额随时保持新鲜。

## 工作原理

```
   你在睡觉          Claude Pulse 触发          你醒了
   zzz...      →     03:30 触发 (1 token)   →   配额已满！
                      08:30 触发 (1 token)       直接开干。
```

Claude Pulse 利用 macOS 的 `launchd` 调度轻量级触发。每次触发只发送一个单词的提示词（`"reply with only the word: pulse"`），消耗约 1 个 token，成本约 $0.01。这会重置你的 5 小时配额计时器。

对于凌晨的触发，它甚至能通过 `pmset` 把你的 Mac 从睡眠中唤醒。

## 特性

- **全程无需打字** — 纯箭头键交互式 TUI，不需要输入任何文字
- **智能时间网格** — 半小时间隔，实时显示有效时间窗口
- **每日循环触发** — 设定每天固定时间（如 03:30、08:30、13:30）
- **一次性触发** — 指定具体日期和时间（如 2月10日 07:30）
- **跨天感知** — 有效窗口跨越午夜时显示完整日期
- **自动唤醒** — 凌晨触发时通过 `pmset` 唤醒 Mac（00:00–06:59）
- **自动清理** — 过期的一次性触发和 30 天前的日志自动删除
- **重试机制** — 网络检查 + 失败后自动重试

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
3. 选择 **"Apply and finish"**

Claude Pulse 会自动处理剩下的一切——配置文件、定时任务、唤醒计划。

## 命令一览

| 命令 | 说明 |
|------|------|
| `claude-pulse setup` | 交互式配置 |
| `claude-pulse start` | 启用所有触发 |
| `claude-pulse stop` | 停用所有触发 |
| `claude-pulse status` | 查看当前状态 |
| `claude-pulse logs` | 最近的触发日志 |
| `claude-pulse logs --today` | 今天的日志 |
| `claude-pulse logs -n 50` | 最近 50 条 |
| `claude-pulse logs 2026-02-10` | 指定日期的日志 |

## 推荐方案：24 小时全覆盖

每 5 小时设一个触发，token 全天候可用：

```
触发时间:  03:30  →  08:30  →  13:30  →  18:30  →  23:30
覆盖范围:  03-08     08-13     13-18     18-23     23-04
```

每天 5 次触发，每次约 $0.01 = **每天约 $0.05**，换来随时满配额。

## 技术细节

1. `claude-pulse setup` 会生成：
   - `~/.claude-pulse/config.json` — 你的配置
   - `~/.claude-pulse/trigger.sh` — 触发脚本
   - `~/Library/LaunchAgents/com.claude-pulse.*.plist` — 每个触发时间一个 launchd 代理

2. 每个 launchd 代理在预定时间运行 `caffeinate -i trigger.sh`

3. `trigger.sh` 的执行流程：
   - 检查 pulse 是否启用
   - 检测网络连通性（失败后 30 秒重试）
   - 运行 `claude -p "reply with only the word: pulse" --max-turns 1`
   - 把结果记录到 `~/.claude-pulse/logs/`
   - 失败时自动重试一次
   - 清理过期的一次性触发和旧日志（>30天）

## 卸载

```bash
bash uninstall.sh
```

这会移除所有代理、配置文件和符号链接。如果还需要取消 pmset 唤醒计划：

```bash
sudo pmset repeat cancel
```

## 为什么叫 "Pulse"？

Pulse 是脉搏，是最微小的生命迹象。Claude Pulse 做的就是这件事——发送一次心跳，让你的 token 配额保持活力。

## 作者

<a href="https://github.com/ericshang98">
  <img src="https://avatars.githubusercontent.com/u/200189264?v=4" width="80" style="border-radius:50%" alt="Eric Shang"/>
</a>

**[Eric Shang](https://github.com/ericshang98)** — AI 原生工具构建者。同时在做 [Nexting AI](https://github.com/ericshang98)（AEO 平台）和 [Perfect Web Clone](https://github.com/ericshang98/Perfect-Web-Clone)。

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
