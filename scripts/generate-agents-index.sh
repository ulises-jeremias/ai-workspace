#!/usr/bin/env bash
# scripts/generate-agents-index.sh
# Regenerate the routing table in AGENTS.md from installed skills.
#
# Usage:
#   ./scripts/generate-agents-index.sh [--dry-run]
#
# This script scans the opencode/claude skills directory and generates
# a Markdown routing table to update the Skills section in AGENTS.md.
# It is non-destructive and only updates the auto-generated block.

set -euo pipefail

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_MD="${WORKSPACE_ROOT}/AGENTS.md"
DRY_RUN="${1:-}"

# ── colors ────────────────────────────────────────────────────────────────────
_color() { [[ -t 1 ]] && printf '\033[%sm%s\033[0m\n' "$1" "$2" || printf '%s\n' "$2"; }
blue()   { _color "1;34" "$*"; }
green()  { _color "1;32" "$*"; }
yellow() { _color "1;33" "$*"; }
dim()    { _color "0;37" "$*"; }

# ── find skills dirs ──────────────────────────────────────────────────────────
SKILLS_DIRS=(
  "${HOME}/.config/opencode/skills"
  "${HOME}/.local/share/opencode/skills"
  "${HOME}/.claude/skills"
)

found_skills=()

for skills_dir in "${SKILLS_DIRS[@]}"; do
  if [[ -d "${skills_dir}" ]]; then
    blue "Scanning: ${skills_dir}"
    while IFS= read -r -d '' skill_dir; do
      skill_name=$(basename "${skill_dir}")
      skill_md="${skill_dir}/SKILL.md"

      if [[ -f "${skill_md}" ]]; then
        # Extract description from SKILL.md (first line after # heading that starts with >)
        desc=$(grep -m1 '^>' "${skill_md}" 2>/dev/null | sed 's/^> //' || echo "")
        if [[ -z "${desc}" ]]; then
          # Fallback: first non-empty, non-heading line
          desc=$(grep -m1 '^[^#>]' "${skill_md}" 2>/dev/null | head -c 80 || echo "")
        fi
        found_skills+=("${skill_name}|${desc}")
        dim "  Found: ${skill_name}"
      fi
    done < <(find "${skills_dir}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  fi
done

if [[ ${#found_skills[@]} -eq 0 ]]; then
  yellow "No skills found. Checked:"
  for d in "${SKILLS_DIRS[@]}"; do
    dim "  ${d}"
  done
  exit 0
fi

# ── generate routing table ────────────────────────────────────────────────────
echo ""
blue "Generating routing table for ${#found_skills[@]} skills..."

table_lines=(
  "<!-- AUTO-GENERATED: run scripts/generate-agents-index.sh to update -->"
  ""
  "| Skill | Description |"
  "|-------|-------------|"
)

for entry in "${found_skills[@]}"; do
  name="${entry%%|*}"
  desc="${entry##*|}"
  table_lines+=("| \`${name}\` | ${desc} |")
done

table_lines+=("" "<!-- END AUTO-GENERATED -->")

# ── output ────────────────────────────────────────────────────────────────────
echo ""
blue "=== Generated Skills Table ==="
for line in "${table_lines[@]}"; do
  echo "${line}"
done

echo ""

if [[ "${DRY_RUN}" == "--dry-run" ]]; then
  yellow "Dry run — AGENTS.md not modified."
  echo "Run without --dry-run to update."
  exit 0
fi

# Check if AGENTS.md has the auto-generated block
if grep -q "<!-- AUTO-GENERATED:" "${AGENTS_MD}" 2>/dev/null; then
  # Replace the block between the markers
  python3 - "${AGENTS_MD}" "${table_lines[@]}" <<'PYEOF'
import sys
from pathlib import Path

agents_path = Path(sys.argv[1])
new_lines = sys.argv[2:]

content = agents_path.read_text(encoding="utf-8")
lines = content.splitlines(keepends=True)

start_marker = "<!-- AUTO-GENERATED:"
end_marker = "<!-- END AUTO-GENERATED -->"

start_idx = next((i for i, l in enumerate(lines) if start_marker in l), None)
end_idx = next((i for i, l in enumerate(lines) if end_marker in l), None)

if start_idx is not None and end_idx is not None:
    replacement = [l + "\n" for l in new_lines]
    new_content_lines = lines[:start_idx] + replacement + lines[end_idx + 1:]
    agents_path.write_text("".join(new_content_lines), encoding="utf-8")
    print("Updated auto-generated block in AGENTS.md")
else:
    print("Auto-generated block markers not found — no changes made.")
PYEOF
else
  yellow "No AUTO-GENERATED block found in AGENTS.md."
  yellow "Add these markers to AGENTS.md where you want the skills table:"
  echo ""
  echo "  <!-- AUTO-GENERATED: run scripts/generate-agents-index.sh to update -->"
  echo "  <!-- END AUTO-GENERATED -->"
fi

green "Done."
