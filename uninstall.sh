#!/bin/bash
# tab-notify uninstaller
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HOOK_DIR="$CLAUDE_DIR/hooks/tab-notify"
SKILL_DIR="$CLAUDE_DIR/skills/tab-notify-toggle"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Uninstalling tab-notify..."

# Remove hook and skill directories
rm -rf "$HOOK_DIR" "$SKILL_DIR"

# Remove hook entries from settings.json
if [ -f "$SETTINGS" ]; then
  python3 << PYEOF
import json, os

settings_path = os.path.expanduser("$SETTINGS")

try:
    with open(settings_path) as f:
        settings = json.load(f)
except:
    exit(0)

hooks = settings.get("hooks", {})
for event in ["Stop", "Notification", "PermissionRequest"]:
    groups = hooks.get(event, [])
    for group in groups:
        group["hooks"] = [
            h for h in group.get("hooks", [])
            if "tab-notify" not in h.get("command", "")
        ]
    hooks[event] = [g for g in groups if g.get("hooks")]
    if not hooks[event]:
        del hooks[event]

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
PYEOF
fi

echo "tab-notify uninstalled."
