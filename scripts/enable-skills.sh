#!/usr/bin/env bash
set -euo pipefail

# Enables this fork's skills in ONE repo, by copying them into
# <repo>/.claude/skills/ (and the researcher agent into <repo>/.claude/agents/).
# Nothing is installed globally, and nothing updates itself: re-run after a
# `git pull` of this fork to refresh the copies.
#
#   scripts/enable-skills.sh <repo>               every skill except git-guardrails
#   scripts/enable-skills.sh <repo> tdd grilling  only the skills named
#   scripts/enable-skills.sh --remove <repo>      remove what this script installed
#
# Copies, not symlinks: an agent editing the copies in <repo> can't edit this fork.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST_NAME=".enabled-from-skills-fork"

# git-guardrails rewrites ~/.claude/settings.json hooks and is weaker than the
# repo-guard hook; deprecated skills are retired.
EXCLUDED=("git-guardrails-claude-code")

usage() { sed -n '7,10p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

remove=0
if [ "${1:-}" = "--remove" ]; then remove=1; shift; fi
[ $# -ge 1 ] || usage
TARGET="$(cd "$1" && pwd)"; shift
[ -d "$TARGET/.git" ] || { echo "error: $TARGET is not a git repo" >&2; exit 1; }
[ "$TARGET" != "$REPO" ] || { echo "error: refusing to enable skills inside the skills fork itself" >&2; exit 1; }

SKILLS_DIR="$TARGET/.claude/skills"
AGENTS_DIR="$TARGET/.claude/agents"
MANIFEST="$SKILLS_DIR/$MANIFEST_NAME"

if [ "$remove" = 1 ]; then
  [ -f "$MANIFEST" ] || { echo "nothing installed by this script in $TARGET"; exit 0; }
  while IFS= read -r entry; do
    [ -n "$entry" ] && rm -rf "${TARGET:?}/$entry" && echo "removed $entry"
  done < "$MANIFEST"
  rm -f "$MANIFEST"
  exit 0
fi

# Every skill folder outside deprecated/, keyed by its folder name.
names=(); srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"; name="$(basename "$src")"
  for ex in "${EXCLUDED[@]}"; do [ "$name" = "$ex" ] && continue 2; done
  names+=("$name"); srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/deprecated/*' -print0 | sort -z)

wanted=("$@")
if [ ${#wanted[@]} -gt 0 ]; then
  for w in "${wanted[@]}"; do
    printf '%s\n' "${names[@]}" | grep -qx "$w" || { echo "error: unknown skill '$w'" >&2; exit 1; }
  done
fi

mkdir -p "$SKILLS_DIR"
: > "$MANIFEST.tmp"
for i in "${!names[@]}"; do
  name="${names[$i]}"; src="${srcs[$i]}"
  if [ ${#wanted[@]} -gt 0 ] && ! printf '%s\n' "${wanted[@]}" | grep -qx "$name"; then continue; fi
  rm -rf "${SKILLS_DIR:?}/$name"
  cp -R "$src" "$SKILLS_DIR/$name"
  echo ".claude/skills/$name" >> "$MANIFEST.tmp"
  echo "enabled $name"
  if [ "$name" = "research" ]; then
    mkdir -p "$AGENTS_DIR"
    cp "$src/researcher-agent.md" "$AGENTS_DIR/researcher.md"
    echo ".claude/agents/researcher.md" >> "$MANIFEST.tmp"
    echo "enabled agent researcher"
  fi
done
# keep entries from earlier runs that this run didn't touch
[ -f "$MANIFEST" ] && cat "$MANIFEST" >> "$MANIFEST.tmp"
sort -u "$MANIFEST.tmp" > "$MANIFEST" && rm -f "$MANIFEST.tmp"

# Keep the copies out of the target repo's commits.
EXCLUDE_FILE="$TARGET/.git/info/exclude"
mkdir -p "$(dirname "$EXCLUDE_FILE")"
for pattern in "/.claude/skills/" "/.claude/agents/researcher.md"; do
  grep -qxF "$pattern" "$EXCLUDE_FILE" 2>/dev/null || echo "$pattern" >> "$EXCLUDE_FILE"
done

echo "done: start a new agent session in $TARGET to load the skills"
