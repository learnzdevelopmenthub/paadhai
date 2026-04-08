#!/usr/bin/env bash
# verify-issue-9.sh
# Content verification for issue #9: Implement skill invocation announcement banners
# Run from repo root: bash tests/verify-issue-9.sh

set -uo pipefail

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
    ge) [ "$actual" -ge "$expected" ] 2>/dev/null && ok=true ;;
    eq) [ "$actual" -eq "$expected" ] 2>/dev/null && ok=true ;;
    gt) [ "$actual" -gt "$expected" ] 2>/dev/null && ok=true ;;
  esac

  if $ok; then
    echo "  PASS [$id] $description (got $actual)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL [$id] $description (expected $op $expected, got $actual)"
    FAIL=$((FAIL + 1))
  fi
}

grep_count() {
  grep -c "$1" "$2" 2>/dev/null || true
}

grep_count_fixed() {
  grep -cF "$1" "$2" 2>/dev/null || true
}

# Preamble extraction helper: get lines between ## PREAMBLE and ## STEP 1
preamble_grep() {
  local pattern="$1"
  local file="$2"
  sed -n '/^## PREAMBLE/,/^## STEP 1/p' "$file" 2>/dev/null | grep -c "$pattern" 2>/dev/null || true
}

preamble_grep_fixed() {
  local pattern="$1"
  local file="$2"
  sed -n '/^## PREAMBLE/,/^## STEP 1/p' "$file" 2>/dev/null | grep -cF "$pattern" 2>/dev/null || true
}

preamble_grep_case() {
  local pattern="$1"
  local file="$2"
  sed -n '/^## PREAMBLE/,/^## STEP 1/p' "$file" 2>/dev/null | grep -ci "$pattern" 2>/dev/null || true
}

# All 22 skill directories
ALL_SKILLS=(
  dev-adr dev-audit dev-debug dev-deps dev-docs dev-hotfix
  dev-implement dev-parallel dev-plan dev-pr dev-release dev-rollback
  dev-ship dev-start dev-status dev-test dev-unblock
  next-version paadhai-skill project-init project-plan release-plan
)

# 14 issue-aware skills (Variant A)
ISSUE_AWARE=(
  dev-adr dev-audit dev-debug dev-docs dev-hotfix
  dev-implement dev-parallel dev-plan dev-pr dev-rollback
  dev-ship dev-start dev-test dev-unblock
)

# 8 non-issue skills (Variant B)
NON_ISSUE=(
  dev-deps dev-release dev-status next-version
  paadhai-skill project-init project-plan release-plan
)

# Expected step counts per skill
declare -A STEP_COUNTS=(
  [dev-adr]=10 [dev-audit]=7 [dev-debug]=11 [dev-deps]=8
  [dev-docs]=8 [dev-hotfix]=12 [dev-implement]=10 [dev-parallel]=14
  [dev-plan]=17 [dev-pr]=8 [dev-release]=14 [dev-rollback]=8
  [dev-ship]=7 [dev-start]=8 [dev-status]=7 [dev-test]=11
  [dev-unblock]=8 [next-version]=7 [paadhai-skill]=13
  [project-init]=9 [project-plan]=10 [release-plan]=8
)

echo ""
echo "=== Issue #9 Content Verification ==="
echo ""

# ── Happy Path ────────────────────────────────────────────────────────────────
echo "Happy Path"

# TC-01: All 22 SKILL.md files contain ## PREAMBLE
count=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  if grep -q "## PREAMBLE" "$f" 2>/dev/null; then
    count=$((count + 1))
  fi
done
check "TC-01" "All 22 SKILL.md files contain ## PREAMBLE" "$count" eq 22

# TC-02: No SKILL.md is missing the preamble
missing=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  if ! grep -q "## PREAMBLE" "$f" 2>/dev/null; then
    echo "         MISSING: $f"
    missing=$((missing + 1))
  fi
done
check "TC-02" "No SKILL.md missing preamble" "$missing" eq 0

# TC-03: dev-implement (issue-aware) contains issue extraction in preamble
check "TC-03" "dev-implement: preamble has issue extraction" \
  "$(preamble_grep 'Extract issue number' .claude/skills/dev-implement/SKILL.md)" ge 1

# TC-04: dev-start (issue-aware) contains gh api in preamble
check "TC-04" "dev-start: preamble has gh api fetch" \
  "$(preamble_grep 'gh api' .claude/skills/dev-start/SKILL.md)" ge 1

# TC-05: dev-plan (issue-aware) contains gh api in preamble
check "TC-05" "dev-plan: preamble has gh api fetch" \
  "$(preamble_grep 'gh api' .claude/skills/dev-plan/SKILL.md)" ge 1

# TC-06: All 22 skills detect branch via git branch --show-current in preamble
count=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(preamble_grep_fixed "git branch --show-current" "$f")
  if [ "$c" -ge 1 ] 2>/dev/null; then
    count=$((count + 1))
  fi
done
check "TC-06" "All 22 preambles have git branch --show-current" "$count" eq 22

# TC-07: dev-implement banner shows "10 steps"
check "TC-07" "dev-implement: banner shows 10 steps" \
  "$(preamble_grep_fixed '10 steps' .claude/skills/dev-implement/SKILL.md)" ge 1

# TC-08: dev-plan banner shows "17 steps"
check "TC-08" "dev-plan: banner shows 17 steps" \
  "$(preamble_grep_fixed '17 steps' .claude/skills/dev-plan/SKILL.md)" ge 1

# TC-09: dev-parallel banner shows "14 steps"
check "TC-09" "dev-parallel: banner shows 14 steps" \
  "$(preamble_grep_fixed '14 steps' .claude/skills/dev-parallel/SKILL.md)" ge 1

# TC-10: dev-status banner shows "7 steps"
check "TC-10" "dev-status: banner shows 7 steps" \
  "$(preamble_grep_fixed '7 steps' .claude/skills/dev-status/SKILL.md)" ge 1

# TC-11: All 22 skills have box-drawing ──── in preamble
count=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(preamble_grep_fixed "────" "$f")
  if [ "$c" -ge 1 ] 2>/dev/null; then
    count=$((count + 1))
  fi
done
check "TC-11" "All 22 preambles have box-drawing ────" "$count" eq 22

echo ""
# ── Edge Cases ────────────────────────────────────────────────────────────────
echo "Edge Cases"

# TC-12: Issue-aware skills (14) contain feature/* branch check in preamble
count=0
for skill in "${ISSUE_AWARE[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(preamble_grep_fixed "feature/" "$f")
  if [ "$c" -ge 1 ] 2>/dev/null; then
    count=$((count + 1))
  fi
done
check "TC-12" "14 issue-aware preambles reference feature/ branch" "$count" eq 14

# TC-13: Non-issue skills (8) do NOT contain gh api in preamble
bad=0
for skill in "${NON_ISSUE[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(preamble_grep 'gh api' "$f")
  if [ "$c" -ge 1 ] 2>/dev/null; then
    echo "         UNEXPECTED gh api in: $f"
    bad=$((bad + 1))
  fi
done
check "TC-13" "8 non-issue preambles have no gh api" "$bad" eq 0

# TC-14: Issue-aware skills have graceful degradation note in preamble
count=0
for skill in "${ISSUE_AWARE[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(preamble_grep_case "gracefully" "$f")
  if [ "$c" -ge 1 ] 2>/dev/null; then
    count=$((count + 1))
  fi
done
check "TC-14" "14 issue-aware preambles mention graceful degradation" "$count" eq 14

# TC-15: Each skill's step count in banner matches expected
mismatch=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  expected_n="${STEP_COUNTS[$skill]}"
  c=$(preamble_grep_fixed "${expected_n} steps" "$f")
  if [ "$c" -lt 1 ] 2>/dev/null; then
    echo "         MISMATCH: $skill expected '${expected_n} steps' in preamble"
    mismatch=$((mismatch + 1))
  fi
done
check "TC-15" "All 22 banners have correct step count" "$mismatch" eq 0

# TC-16: Preamble appears before ## STEP 1 in every file
bad=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  preamble_line=$(grep -n "## PREAMBLE" "$f" 2>/dev/null | head -1 | cut -d: -f1)
  step1_line=$(grep -n "## STEP 1" "$f" 2>/dev/null | head -1 | cut -d: -f1)
  if [ -z "$preamble_line" ] || [ -z "$step1_line" ]; then
    bad=$((bad + 1))
  elif [ "$preamble_line" -ge "$step1_line" ] 2>/dev/null; then
    echo "         ORDER: $skill PREAMBLE (L$preamble_line) not before STEP 1 (L$step1_line)"
    bad=$((bad + 1))
  fi
done
check "TC-16" "PREAMBLE before STEP 1 in all 22 files" "$bad" eq 0

echo ""
# ── Error / Failure Cases ─────────────────────────────────────────────────────
echo "Error / Failure Cases"

# TC-17: No SKILL.md has more than one ## PREAMBLE section
bad=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(grep_count "## PREAMBLE" "$f")
  if [ "$c" -gt 1 ] 2>/dev/null; then
    echo "         DUPLICATE: $f has $c ## PREAMBLE sections"
    bad=$((bad + 1))
  fi
done
check "TC-17" "No SKILL.md has duplicate ## PREAMBLE" "$bad" eq 0

# TC-18: No preamble uses plain dashes ---- instead of box-drawing ────
bad=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  # Check for 4+ plain dashes in preamble that aren't box-drawing
  c=$(sed -n '/^## PREAMBLE/,/^## STEP 1/p' "$f" 2>/dev/null | grep -cE "^-{4,}" 2>/dev/null || true)
  if [ "$c" -ge 1 ] 2>/dev/null; then
    echo "         PLAIN DASHES: $f uses ---- instead of ────"
    bad=$((bad + 1))
  fi
done
check "TC-18" "No preamble uses plain dashes instead of box-drawing" "$bad" eq 0

# TC-19: Non-issue skill banners don't mention "Issue #" in preamble
bad=0
for skill in "${NON_ISSUE[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(preamble_grep_fixed "Issue #" "$f")
  if [ "$c" -ge 1 ] 2>/dev/null; then
    echo "         UNEXPECTED Issue # in: $f"
    bad=$((bad + 1))
  fi
done
check "TC-19" "Non-issue preambles don't mention Issue #" "$bad" eq 0

# TC-20: No skill has "0 steps" in banner
bad=0
for skill in "${ALL_SKILLS[@]}"; do
  f=".claude/skills/$skill/SKILL.md"
  c=$(preamble_grep_fixed "0 steps" "$f")
  if [ "$c" -ge 1 ] 2>/dev/null; then
    echo "         ZERO STEPS: $f"
    bad=$((bad + 1))
  fi
done
check "TC-20" "No preamble has 0 steps" "$bad" eq 0

echo ""
echo "══════════════════════════════════════"
echo "Results: $PASS passed, $FAIL failed"
echo "══════════════════════════════════════"
echo ""

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
