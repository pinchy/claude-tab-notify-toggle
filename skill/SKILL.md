---
name: tab-notify-toggle
description: Toggle terminal tab bell notifications on/off. Use when user wants to enable, disable, or check status of tab flash notifications.
---

# tab-notify-toggle

Toggle terminal bell notifications on or off.

## Toggle

Run the following command using the Bash tool:

```bash
bash "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/hooks/tab-notify/tab-notify.sh toggle
```

Report the output to the user. The command will print either:
- `tab-notify: paused` — bell is now muted
- `tab-notify: resumed` — bell is now active
