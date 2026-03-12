#!/bin/bash
# tab-notify: Ring terminal bell when Claude finishes, needs permission, or waits for input.
# This causes the terminal tab to flash/highlight when you're on another tab.
set -uo pipefail

NOTIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAUSED_FILE="$NOTIFY_DIR/.paused"

# --- CLI subcommands ---
case "${1:-}" in
  pause)  touch "$PAUSED_FILE"; echo "tab-notify: paused"; exit 0 ;;
  resume) rm -f "$PAUSED_FILE"; echo "tab-notify: resumed"; exit 0 ;;
  toggle)
    if [ -f "$PAUSED_FILE" ]; then rm -f "$PAUSED_FILE"; echo "tab-notify: resumed"
    else touch "$PAUSED_FILE"; echo "tab-notify: paused"; fi
    exit 0 ;;
  status)
    [ -f "$PAUSED_FILE" ] && echo "tab-notify: paused" || echo "tab-notify: active"
    exit 0 ;;
  help|--help|-h)
    echo "Usage: tab-notify <pause|resume|toggle|status>"
    exit 0 ;;
esac

# If no CLI arg and stdin is a terminal, show help
if [ -t 0 ]; then
  echo "Usage: tab-notify <pause|resume|toggle|status>"
  exit 0
fi

# --- Hook mode: read event from stdin ---
[ -f "$PAUSED_FILE" ] && exit 0

INPUT=$(cat)
EVENT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('hook_event_name',''))" 2>/dev/null)

case "$EVENT" in
  Stop|Notification|PermissionRequest) ;;
  *) exit 0 ;;
esac

# --- Find the real TTY by walking up the process tree ---
REAL_TTY=""
_pid=$PPID
for _ in 1 2 3 4 5; do
  [ -z "$_pid" ] && break
  _tty=$(ps -o tty= -p "$_pid" 2>/dev/null | tr -d ' ')
  if [ -n "$_tty" ] && [ "$_tty" != "??" ]; then
    REAL_TTY="/dev/$_tty"
    break
  fi
  _pid=$(ps -o ppid= -p "$_pid" 2>/dev/null | tr -d ' ')
done

# --- Ring the bell ---
if [ -n "$REAL_TTY" ] && [ -w "$REAL_TTY" ]; then
  printf '\a' > "$REAL_TTY"
fi

exit 0
