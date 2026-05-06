#!/usr/bin/env bash
# exec-plan-lint.sh — universal lint for active execution plans.
#
# Plans under docs/exec-plans/active/*.md are the system of record for in-flight
# work. Every active plan must declare three sections so future automation
# (browser QA, Slack smoke tests, backend integration tests, etc.) can route
# verification mechanically instead of inferring from prose.
#
# Required sections:
#   ## Done means        — bulleted list of verifiable behaviors
#   ## Out of scope      — what this plan deliberately does not address
#   ## Verification mode — one of: browser, slack, backend-http, unit, none
#
# Usage:
#   exec-plan-lint.sh                    # lint staged active plans (pre-commit mode)
#   exec-plan-lint.sh path/to/plan.md    # lint explicit files (CLI / agent hook)
#
# Tool-agnostic: invoked by git pre-commit (universal), Claude Code PostToolUse,
# Codex/Gemini equivalents, or directly from the shell. The script is the
# primitive; per-tool wiring is just invocation.

set -euo pipefail

REQUIRED_SECTIONS=(
  "## Done means"
  "## Out of scope"
  "## Verification mode"
)
VALID_MODES_REGEX='\b(browser|slack|backend-http|unit|none)\b'

# Resolve targets: explicit args win, otherwise inspect the staged index.
if [ "$#" -gt 0 ]; then
  TARGETS=("$@")
else
  TARGETS=()
  while IFS= read -r f; do
    [ -n "$f" ] && TARGETS+=("$f")
  done < <(git diff --cached --name-only --diff-filter=AM 2>/dev/null \
            | grep -E '(^|/)docs/exec-plans/active/.+\.md$' || true)
fi

[ "${#TARGETS[@]}" -eq 0 ] && exit 0

FAIL=0
for plan in "${TARGETS[@]}"; do
  # Only lint files actually under an active/ directory. Defensive: keeps
  # explicit-arg invocations from accidentally linting completed plans or
  # unrelated markdown.
  case "$plan" in
    *docs/exec-plans/active/*.md) ;;
    *) continue ;;
  esac
  [ -f "$plan" ] || continue

  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qF "$section" "$plan"; then
      echo "FAIL  $plan — missing: $section" >&2
      FAIL=1
    fi
  done

  if grep -qF "## Verification mode" "$plan"; then
    # Take everything between "## Verification mode" and the next "## " heading.
    mode_block=$(awk '/^## Verification mode/{flag=1; next} /^## /{flag=0} flag' "$plan")
    if ! echo "$mode_block" | grep -qE "$VALID_MODES_REGEX"; then
      echo "FAIL  $plan — Verification mode must contain one of: browser, slack, backend-http, unit, none" >&2
      FAIL=1
    fi
  fi
done

if [ "$FAIL" -eq 1 ]; then
  cat >&2 <<'EOF'

Active exec-plans (docs/exec-plans/active/*.md) must declare:
  ## Done means        — bulleted list of verifiable behaviors
  ## Out of scope      — what this plan deliberately does not address
  ## Verification mode — one of: browser, slack, backend-http, unit, none

A plan without testable Done is a wish, not a contract.
EOF
  exit 1
fi

exit 0
