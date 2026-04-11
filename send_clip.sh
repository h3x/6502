#!/usr/bin/env bash

PORT=${1:-/dev/ttyUSB0}
DELAY=${2:-0.01}   # seconds between characters (tune this!)

# Choose clipboard command depending on system
if command -v pbpaste >/dev/null 2>&1; then
  CLIP_CMD="pbpaste"
elif command -v xclip >/dev/null 2>&1; then
  CLIP_CMD="xclip -selection clipboard -o"
elif command -v xsel >/dev/null 2>&1; then
  CLIP_CMD="xsel --clipboard --output"
else
  echo "No clipboard tool found (pbpaste/xclip/xsel)"
  exit 1
fi


# Send slowly
eval "$CLIP_CMD" | while IFS= read -r -n1 char; do
  printf "%s" "$char" > "$PORT"
  # sleep "$DELAY"
done
