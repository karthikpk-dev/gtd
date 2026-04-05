#!/bin/bash
set -e

SKILL_DIR="$HOME/.claude/skills/gtd"

if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "GTD skill uninstalled successfully."
else
  echo "GTD skill not found at $SKILL_DIR — nothing to remove."
fi
