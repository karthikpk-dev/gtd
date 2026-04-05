#!/bin/bash
set -e

SKILL_DIR="$HOME/.claude/skills/gtd"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills/gtd"

if [ ! -f "$SOURCE_DIR/SKILL.md" ]; then
  echo "Error: SKILL.md not found in $SOURCE_DIR"
  exit 1
fi

mkdir -p "$SKILL_DIR"
cp "$SOURCE_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
cp "$SOURCE_DIR/planning-guide.md" "$SKILL_DIR/planning-guide.md"

echo "GTD skill installed successfully!"
echo ""
echo "Usage:"
echo "  /gtd plan <description>  — Plan a new task"
echo "  /gtd run                 — Execute next subtask"
echo "  /gtd status              — Show progress"
echo "  /gtd skip                — Skip current task"
echo "  /gtd reset               — Delete plan and start fresh"
