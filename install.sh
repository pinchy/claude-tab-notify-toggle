#!/bin/bash
# tab-notify installer for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/pinchy/tab-notify/main/install.sh | bash
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HOOK_DIR="$CLAUDE_DIR/hooks/tab-notify"
SKILL_DIR="$CLAUDE_DIR/skills/tab-notify-toggle"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Installing tab-notify..."

# Create directories
mkdir -p "$HOOK_DIR" "$SKILL_DIR"

# Download files (or copy if running from repo)
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != "bash" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/tab-notify.sh" ]; then
  cp "$SCRIPT_DIR/tab-notify.sh" "$HOOK_DIR/tab-notify.sh"
  cp "$SCRIPT_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"
else
  BASE_URL="https://raw.githubusercontent.com/pinchy/tab-notify/main"
  curl -fsSL "$BASE_URL/tab-notify.sh" -o "$HOOK_DIR/tab-notify.sh"
  curl -fsSL "$BASE_URL/skill/SKILL.md" -o "$SKILL_DIR/SKILL.md"
fi

chmod +x "$HOOK_DIR/tab-notify.sh"

# Register hooks in settings.json
if [ ! -f "$SETTINGS" ]; then
  cat > "$SETTINGS" << 'EOF'
{
  "hooks": {},
  "permissions": {}
}
EOF
fi

# Merge hook entries into settings.json (idempotent)
python3 << PYEOF
import json, os

settings_path = os.path.expanduser("$SETTINGS")
hook_path = os.path.expanduser("$HOOK_DIR/tab-notify.sh")

try:
    with open(settings_path) as f:
        settings = json.load(f)
except:
    settings = {}

hooks = settings.setdefault("hooks", {})

for event in ["Stop", "Notification", "PermissionRequest"]:
    existing = hooks.get(event, [])
    already = any(
        "tab-notify" in h.get("command", "")
        for group in existing
        for h in group.get("hooks", [])
    )
    if already:
        continue

    entry = {"type": "command", "command": hook_path, "timeout": 5}
    if existing:
        existing[0].setdefault("hooks", []).append(entry)
    else:
        hooks[event] = [{"matcher": "", "hooks": [entry]}]

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
PYEOF

echo ""
echo "tab-notify installed!"
echo ""
echo "Your terminal tab will now flash when Claude Code:"
echo "  - Finishes a task"
echo "  - Needs permission"
echo "  - Waits for input"
echo ""
echo "Commands:"
echo "  /tab-notify-toggle    Toggle on/off inside Claude Code"
echo "  tab-notify.sh status  Check current state"
echo ""
echo "Restart Claude Code for hooks to take effect."
