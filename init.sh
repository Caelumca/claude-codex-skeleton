#!/usr/bin/env bash
# Drop this skeleton into a new project: bash init.sh /path/to/project
set -euo pipefail
DEST="${1:?usage: init.sh /path/to/project}"
SRC="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DEST"
cp -rn "$SRC/.claude" "$SRC/.briefs" "$SRC/.notes" "$SRC/.qa" "$SRC/.review" "$DEST/" 2>/dev/null || true
[ -f "$DEST/CLAUDE.md" ] || cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"
grep -qxF '.qa/raw/' "$DEST/.gitignore" 2>/dev/null || echo '.qa/raw/' >> "$DEST/.gitignore"
echo "Skeleton installed → $DEST  (now fill CLAUDE.md and pick a mode)"
