#!/usr/bin/env bash
# Static verification for Issue #10 — Progress Dashboard in dev-implement
# Run from project root: bash docs/plans/issue-10/verify-dashboard.sh

set -euo pipefail

SKILL=".claude/skills/dev-implement/SKILL.md"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "ok" ]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Issue #10 — Dashboard Verification ==="
echo ""

# T1: Sub-step 7h exists
if grep -q '### 7h' "$SKILL"; then
  check "T1 (AC-1): Sub-step 7h exists" "ok"
else
  check "T1 (AC-1): Sub-step 7h exists" "fail"
fi

# T2: All 5 dashboard data fields present in 7h section
FIELDS=$(sed -n '/### 7h/,/### [0-9]/p' "$SKILL" | grep -c -E 'Files changed|Commits|Tests|Build|Progress:' || true)
if [ "$FIELDS" -ge 5 ]; then
  check "T2 (AC-2): All 5 data fields present" "ok"
else
  check "T2 (AC-2): All 5 data fields present ($FIELDS/5 found)" "fail"
fi

# T3: Progress bar characters
if grep -q '█' "$SKILL" && grep -q '░' "$SKILL"; then
  check "T3 (AC-3): Progress bar uses █ and ░ characters" "ok"
else
  check "T3 (AC-3): Progress bar uses █ and ░ characters" "fail"
fi

# T4: git commands for data gathering
if grep -q 'git rev-list' "$SKILL" && grep -q 'git diff --name-status' "$SKILL"; then
  check "T4 (AC-5): Data gathered via git commands" "ok"
else
  check "T4 (AC-5): Data gathered via git commands" "fail"
fi

# T5: Commit count uses --count
if grep -q 'rev-list.*--count' "$SKILL"; then
  check "T5 (AC-2): Commit count uses git rev-list --count" "ok"
else
  check "T5 (AC-2): Commit count uses git rev-list --count" "fail"
fi

# T6: Dashboard content lines between borders (max 6 excluding borders)
DASHBOARD_LINES=$(sed -n '/### 7h/,/### [0-9]/p' "$SKILL" | sed -n '/══/,/══/p' | grep -v '══' | grep -c -E '\S' || true)
if [ "$DASHBOARD_LINES" -le 6 ]; then
  check "T6 (AC-4): Dashboard max 6 content lines ($DASHBOARD_LINES found)" "ok"
else
  check "T6 (AC-4): Dashboard max 6 content lines ($DASHBOARD_LINES found)" "fail"
fi

# T7: "not yet run" fallback documented
NOT_YET_RUN=$(sed -n '/### 7h/,/### [0-9]/p' "$SKILL" | grep -c 'not yet run' || true)
if [ "$NOT_YET_RUN" -ge 2 ]; then
  check "T7 (AC-2): 'not yet run' fallback for tests and build" "ok"
else
  check "T7 (AC-2): 'not yet run' fallback ($NOT_YET_RUN occurrences, need 2+)" "fail"
fi

# T8: Ordering — 7g before 7h before [PROGRESS] completed marker
LINE_7G=$(grep -n '### 7g' "$SKILL" | head -1 | cut -d: -f1 || echo 0)
LINE_7H=$(grep -n '### 7h' "$SKILL" | head -1 | cut -d: -f1 || echo 0)
LINE_PROG=$(grep -n 'Step 7/10.*completed' "$SKILL" | head -1 | cut -d: -f1 || echo 0)
if [ "$LINE_7G" -gt 0 ] && [ "$LINE_7H" -gt "$LINE_7G" ] && [ "$LINE_PROG" -gt "$LINE_7H" ]; then
  check "T8 (AC-1): Ordering 7g → 7h → PROGRESS marker" "ok"
else
  check "T8 (AC-1): Ordering 7g → 7h → PROGRESS marker (lines: 7g=$LINE_7G, 7h=$LINE_7H, prog=$LINE_PROG)" "fail"
fi

# T9: No hardcoded branch names in 7h (literal "develop" outside config refs)
HARDCODED=$(sed -n '/### 7h/,/### [0-9]/p' "$SKILL" | grep -v '{config.repo.develop_branch}' | grep -c '\bdevelop\b' || true)
if [ "$HARDCODED" -eq 0 ]; then
  check "T9 (AC-5): No hardcoded branch names in 7h" "ok"
else
  check "T9 (AC-5): No hardcoded branch names in 7h ($HARDCODED found)" "fail"
fi

# T10: Build failure state documented
if sed -n '/### 7h/,/### [0-9]/p' "$SKILL" | grep -q 'failing'; then
  check "T10 (AC-2): Build failure state documented" "ok"
else
  check "T10 (AC-2): Build failure state documented" "fail"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
