# tab-notify

A tiny [Claude Code](https://docs.anthropic.com/en/docs/claude-code) hook that rings the terminal bell when Claude finishes working. Your terminal tab flashes so you know when to come back.

Works on macOS, Linux, and WSL. No dependencies beyond Python 3 (for JSON parsing).

## What it does

When Claude Code fires a **Stop**, **Notification**, or **PermissionRequest** event, tab-notify sends a bell character (`\a`) to your terminal. Most terminals will flash or highlight the tab when it's not focused.

It works by walking the process tree to find the real TTY device, since Claude Code hooks run in detached subprocesses that don't have direct terminal access.

## Install

One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/pinchy/tab-notify/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/pinchy/tab-notify.git
cd tab-notify
bash install.sh
```

Restart Claude Code after installing.

## Usage

tab-notify runs automatically. When Claude finishes a task and you're on another tab, your terminal tab will flash.

### Toggle on/off

Inside Claude Code:

```
/tab-notify-toggle
```

Or from your shell:

```bash
~/.claude/hooks/tab-notify/tab-notify.sh toggle
~/.claude/hooks/tab-notify/tab-notify.sh status
~/.claude/hooks/tab-notify/tab-notify.sh pause
~/.claude/hooks/tab-notify/tab-notify.sh resume
```

## Terminal support

The bell character works in most terminals. Make sure "visual bell" or "bell notification" is enabled in your terminal settings:

- **iTerm2**: Profiles > Terminal > Notifications > "Flash visual bell" or "Show bell icon in tabs"
- **Terminal.app**: Settings > Profiles > Advanced > "Visual bell" / "Audible bell"
- **Ghostty**: Works by default
- **Warp**: Works by default
- **Kitty**: `enable_audio_bell yes` in kitty.conf
- **Alacritty**: `bell.duration` in alacritty.toml

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/pinchy/tab-notify/main/uninstall.sh | bash
```

Or if you cloned the repo:

```bash
bash uninstall.sh
```

## How it works

1. Claude Code fires a hook event (Stop, Notification, PermissionRequest)
2. `tab-notify.sh` receives the event JSON on stdin
3. It walks the process tree (`ps -o tty=`) to find the TTY device
4. It writes `\a` (bell) directly to the TTY device (e.g. `/dev/ttys007`)

This bypasses Claude Code's stdout capture, which would otherwise swallow the bell character.

## License

MIT
