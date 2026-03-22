#!/usr/bin/env bash
SESSION_FILE="$HOME/.cache/oc-buffer/.session_id"
STATUS_FILE="$HOME/.cache/oc-buffer/.status"

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "idle" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
  exit 1
fi

SID=$(cat "$SESSION_FILE")

# Use fuzzel in dmenu mode with transparent config
PROMPT=$(echo "" | fuzzel --dmenu --config ~/.config/fuzzel/oc-input.ini)

if [[ -z "$PROMPT" ]]; then
  exit 0
fi

echo "running" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
OUTPUT=$(opencode run "$PROMPT" -s "$SID" 2>/dev/null)

if [[ -n "$OUTPUT" ]]; then
  # Strip markdown code fences if present
  FIRST_LINE=$(echo "$OUTPUT" | head -n1)
  LAST_LINE=$(echo "$OUTPUT" | tail -n1)

  if [[ "$FIRST_LINE" =~ ^\`\`\`[a-zA-Z0-9]*$ ]] && [[ "$LAST_LINE" == '```' ]]; then
    # Strip first and last lines (markdown fences)
    CLEANED=$(echo "$OUTPUT" | sed '1d;$d')
    echo "$CLEANED" | wl-copy
  else
    # Keep output as-is
    echo "$OUTPUT" | wl-copy
  fi

  echo "done" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
else
  echo "error" >"$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
fi
