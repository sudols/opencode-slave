#!/usr/bin/env bash
BUFFER_DIR="$HOME/.cache/oc-buffer"
STATUS_FILE="$HOME/.cache/oc-buffer/.status"
mkdir -p "$BUFFER_DIR"
rm -f "$BUFFER_DIR"/* "$BUFFER_DIR"/.[!.]* "$BUFFER_DIR"/..?*
echo "cleared" > "$STATUS_FILE.tmp" && mv "$STATUS_FILE.tmp" "$STATUS_FILE"
