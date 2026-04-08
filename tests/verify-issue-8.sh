#!/usr/bin/env bash
# verify-issue-8.sh
# Content verification for issue #8: Add [PROGRESS] marker and TodoWrite integration
# Run from repo root: bash tests/verify-issue-8.sh

set -euo pipefail

PASS=0
FAIL=0

check() {
  local id="$1"
  local description="$2"
  local actual="$3"
  local op="$4"
  local expected="$5"

  local ok=false
  case "$op" in
    ge) [ "$actual" -ge "$expected" ] && ok=true ;;
    eq) [ "$actual" -eq "$expected" ] && ok=true ;;
    gt) [ "$actual" -gt "$expected" ] && ok=true ;;
  esac

  if $ok; then
    echo "  PASS [$id] $description (got $actual)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL [$id] $description (expected $op $expected, got $actual)"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "=== Issue #8 Content Verification ==="
echo ""

# ── Happy Path ────────────────────────────────────────────────────────────────
echo "Happy Path"

# TC-1: [PROGRESS] marker row in claude-tools.md
check "TC-01" "[PROGRESS] marker row in references/claude-tools.md" \
  "$(grep -c '\[PROGRESS\]' references/claude-tools.md || echo 0)" ge 1

# TC-2: [PROGRESS] section header in claude-tools.md
check "TC-02" "[PROGRESS] section header in references/claude-tools.md" \
  "$(grep -c '## \[PROGRESS\]' references/claude-tools.md || echo 0)" ge 1

# TC-3: Graceful degradation note in claude-tools.md
check "TC-03" "Graceful degradation note in references/claude-tools.md" \
  "$(grep -ci 'graceful' references/claude-tools.md || echo 0)" ge 1

# TC-4: dev-implement PROGRESS call count
check "TC-04" "dev-implement: ≥20 PROGRESS markers" \
  "$(grep -c 'PROGRESS' .claude/skills/dev-implement/SKILL.md || echo 0)" ge 20

# TC-5: dev-parallel PROGRESS call count
check "TC-05" "dev-parallel: ≥28 PROGRESS markers" \
  "$(grep -c 'PROGRESS' .claude/skills/dev-parallel/SKILL.md || echo 0)" ge 28

# TC-6: dev-plan PROGRESS call count
check "TC-06" "dev-plan: ≥34 PROGRESS markers" \
  "$(grep -c 'PROGRESS' .claude/skills/dev-plan/SKILL.md || echo 0)" ge 34

# TC-7: project-plan PROGRESS call count
check "TC-07" "project-plan: ≥20 PROGRESS markers" \
  "$(grep -c 'PROGRESS' .claude/skills/project-plan/SKILL.md || echo 0)" ge 20

# TC-8: release-plan PROGRESS call count
check "TC-08" "release-plan: ≥16 PROGRESS markers" \
  "$(grep -c 'PROGRESS' .claude/skills/release-plan/SKILL.md || echo 0)" ge 16

# TC-9: dev-release PROGRESS call count
check "TC-09" "dev-release: ≥28 PROGRESS markers" \
  "$(grep -c 'PROGRESS' .claude/skills/dev-release/SKILL.md || echo 0)" ge 28

# TC-10: dev-implement has [in_progress] per-step markers
check "TC-10" "dev-implement: ≥9 [in_progress] step markers" \
  "$(grep -c 'in_progress' .claude/skills/dev-implement/SKILL.md || echo 0)" ge 9

# TC-11: dev-implement has [completed] per-step markers
check "TC-11" "dev-implement: ≥9 [completed] step markers" \
  "$(grep -c 'completed' .claude/skills/dev-implement/SKILL.md || echo 0)" ge 9

# TC-12: dev-implement completed format includes Files: field
check "TC-12" "dev-implement: Files: field present in completed format" \
  "$(grep -c 'Files:' .claude/skills/dev-implement/SKILL.md || echo 0)" ge 1

# TC-13: dev-implement completed format includes Build: field
check "TC-13" "dev-implement: Build: field present in completed format" \
  "$(grep -c 'Build:' .claude/skills/dev-implement/SKILL.md || echo 0)" ge 1

echo ""
# ── Edge Cases ────────────────────────────────────────────────────────────────
echo "Edge Cases"

# TC-14: dev-implement init block last item is Step 10/10
check "TC-14" "dev-implement: init block contains Step 10/10:" \
  "$(grep -c 'Step 10/10:' .claude/skills/dev-implement/SKILL.md || echo 0)" ge 1

# TC-15: dev-parallel init block last item is Step 14/14
check "TC-15" "dev-parallel: init block contains Step 14/14:" \
  "$(grep -c 'Step 14/14:' .claude/skills/dev-parallel/SKILL.md || echo 0)" ge 1

# TC-16: dev-plan init block last item is Step 17/17
check "TC-16" "dev-plan: init block contains Step 17/17:" \
  "$(grep -c 'Step 17/17:' .claude/skills/dev-plan/SKILL.md || echo 0)" ge 1

# TC-17: project-plan init block last item is Step 10/10
check "TC-17" "project-plan: init block contains Step 10/10:" \
  "$(grep -c 'Step 10/10:' .claude/skills/project-plan/SKILL.md || echo 0)" ge 1

# TC-18: release-plan init block last item is Step 8/8
check "TC-18" "release-plan: init block contains Step 8/8:" \
  "$(grep -c 'Step 8/8:' .claude/skills/release-plan/SKILL.md || echo 0)" ge 1

# TC-19: dev-release init block last item is Step 14/14
check "TC-19" "dev-release: init block contains Step 14/14:" \
  "$(grep -c 'Step 14/14:' .claude/skills/dev-release/SKILL.md || echo 0)" ge 1

# TC-20: dev-implement uses correct Step N/Total: format (Step 1/10:)
check "TC-20" "dev-implement: Step 1/10: format present" \
  "$(grep -c 'Step 1/10:' .claude/skills/dev-implement/SKILL.md || echo 0)" ge 1

echo ""
# ── Error / Failure Cases ─────────────────────────────────────────────────────
echo "Error / Failure Cases"

# TC-21: dev-implement init block does NOT use wrong total (e.g. Step 1/9:, Step 1/11:)
check "TC-21" "dev-implement: no wrong total in init block (not Step 1/9: or Step 1/11:)" \
  "$(grep -cE 'Step 1/(9|11):' .claude/skills/dev-implement/SKILL.md || echo 0)" eq 0

# TC-22: No step has both in_progress and completed on the same line
check "TC-22" "dev-implement: no line mixes in_progress + completed" \
  "$(grep -cE 'in_progress.*completed|completed.*in_progress' .claude/skills/dev-implement/SKILL.md || echo 0)" eq 0

# TC-23: [PROGRESS] marker row appears exactly once in the marker table of claude-tools.md
check "TC-23" "claude-tools.md: [PROGRESS] table row appears exactly once" \
  "$(grep -c '^\| \`\[PROGRESS\]\`' references/claude-tools.md || echo 0)" eq 1

# TC-24: Files: in completed format is not hardcoded with a real path
check "TC-24" "dev-implement: Files: field does not contain hardcoded src/ path" \
  "$(grep -c 'Files: src/' .claude/skills/dev-implement/SKILL.md || echo 0)" eq 0

echo ""
echo "══════════════════════════════════════"
echo "Results: $PASS passed, $FAIL failed"
echo "══════════════════════════════════════"
echo ""

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
