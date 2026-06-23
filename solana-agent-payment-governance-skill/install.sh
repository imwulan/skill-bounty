#!/usr/bin/env bash
# Installer for solana-agent-payment-governance-skill
# Copies the skill into a target Claude Code / Codex skills directory.
#
# Usage:
#   ./install.sh [target_dir]
#
# Default target_dir: ./.claude/skills/solana-agent-payment-governance-skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-./.claude/skills/solana-agent-payment-governance-skill}"

mkdir -p "$TARGET_DIR"
cp -r "$SCRIPT_DIR/skill/." "$TARGET_DIR/"

echo "Installed solana-agent-payment-governance-skill to: $TARGET_DIR"
echo "SKILL.md entry point: $TARGET_DIR/SKILL.md"
