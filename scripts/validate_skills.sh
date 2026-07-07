#!/usr/bin/env bash
#
# validate_skills.sh — structural validation for the skills in this repository.
#
# A "skill" is any directory containing a SKILL.md file. For each one this checks:
#   - SKILL.md starts with YAML frontmatter that defines `name` and `description`
#   - README.md exists
#   - example/template_output.md exists
#   - example/sample_output.md exists (brief uses sample_output_today.md +
#     sample_output_week.md instead)
#
# It also fails if any .DS_Store file is tracked by git.
#
# Exit status: 0 if everything passes, 1 otherwise.

set -u

# Resolve the repository root (parent of this script's directory).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

errors=0
skills=0

fail() {
  printf '  FAIL: %s\n' "$1"
  errors=$((errors + 1))
}

# Extract the YAML frontmatter block (between the first two `---` fences).
frontmatter() {
  awk '
    NR == 1 && $0 != "---" { exit 2 }
    NR == 1 { next }
    /^---[[:space:]]*$/ { exit }
    { print }
  ' "$1"
}

echo "Validating skills under $ROOT/skills ..."
echo

# Find every skill directory (one that contains a SKILL.md).
while IFS= read -r skill_md; do
  dir="$(dirname "$skill_md")"
  name="${dir#"$ROOT"/}"
  base="$(basename "$dir")"
  skills=$((skills + 1))
  echo "• $name"

  # SKILL.md frontmatter
  if ! fm="$(frontmatter "$skill_md")"; then
    fail "SKILL.md does not start with a '---' frontmatter fence"
  else
    echo "$fm" | grep -Eq '^name:[[:space:]]*[^[:space:]]' \
      || fail "SKILL.md frontmatter is missing a non-empty 'name:'"
    echo "$fm" | grep -Eq '^description:' \
      || fail "SKILL.md frontmatter is missing 'description:'"
  fi

  # README.md
  [ -f "$dir/README.md" ] || fail "missing README.md"

  # example/ template + sample
  [ -f "$dir/example/template_output.md" ] || fail "missing example/template_output.md"
  if [ "$base" = "brief" ]; then
    [ -f "$dir/example/sample_output_today.md" ] || fail "missing example/sample_output_today.md"
    [ -f "$dir/example/sample_output_week.md" ]  || fail "missing example/sample_output_week.md"
  else
    [ -f "$dir/example/sample_output.md" ] || fail "missing example/sample_output.md"
  fi
done <<EOF
$(find skills -type f -name SKILL.md | sort)
EOF

# Repository-wide guard: no tracked macOS cruft.
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  if git ls-files | grep -q '\.DS_Store$'; then
    echo
    fail "tracked .DS_Store file(s) found — remove with 'git rm --cached'"
  fi
fi

echo
if [ "$skills" -eq 0 ]; then
  echo "No skills found (no SKILL.md files under skills/)."
  exit 1
fi

if [ "$errors" -eq 0 ]; then
  echo "OK — $skills skill(s) validated, no problems found."
  exit 0
else
  echo "FAILED — $errors problem(s) across $skills skill(s)."
  exit 1
fi
