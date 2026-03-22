#!/usr/bin/env bash
# Watch status file and output only complete state changes
STATUS_FILE="$HOME/.cache/oc-buffer/.status"

# Output initial state
[[ -f "$STATUS_FILE" ]] && cat "$STATUS_FILE" || echo "idle"

# Watch for changes and output new state each time
tail -F "$STATUS_FILE" 2>/dev/null | while read -r line; do
  # Only output non-empty lines
  [[ -n "$line" ]] && echo "$line"
done
