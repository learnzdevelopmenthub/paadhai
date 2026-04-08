---
issue: 10
title: Add per-step progress dashboard to dev-implement
branch: feature/10-per-step-progress-dashboard
framework: shell-based static verification
---

# Test Plan — Issue #10: Add per-step progress dashboard to dev-implement

## Test Framework: Shell-based static verification (no runtime test framework — markdown-only project)

## Test Cases

### Happy Path

| # | AC | Type | Description | Input | Expected |
|---|----|----- |-------------|-------|---------|
| 1 | AC-1 | static | Sub-step 7h exists in SKILL.md after 7g | `grep '### 7h' SKILL.md` | Match found |
| 2 | AC-2 | static | Dashboard displays all 5 data fields | `grep -c 'Files changed\|Commits\|Tests\|Build\|Progress:' SKILL.md` (in 7h section) | All 5 present |
| 3 | AC-3 | static | Progress bar uses `█` and `░` characters | `grep '█.*░' SKILL.md` | Match found in dashboard format |
| 4 | AC-5 | static | Data gathered via git commands, not estimation | `grep 'git rev-list\|git diff --name-status' SKILL.md` | Both commands present in 7h |
| 5 | AC-2 | static | Commit count uses `git rev-list --count` | `grep 'rev-list.*--count' SKILL.md` | Match found |

### Edge Cases

| # | AC | Type | Description | Input | Expected |
|---|----|----- |-------------|-------|---------|
| 6 | AC-4 | static | Dashboard format is max 6 content lines | Count lines between `══` borders in 7h | Exactly 5 content lines (progress, files, commits, tests, build) |
| 7 | AC-2 | static | "not yet run" fallback documented | `grep 'not yet run' SKILL.md` | Present for both tests and build |
| 8 | AC-1 | static | 7h appears after 7g and before PROGRESS marker | Read SKILL.md, verify ordering: 7g → 7h → `[PROGRESS]` | Correct order |

### Error / Failure Cases

| # | AC | Type | Description | Input | Expected |
|---|----|----- |-------------|-------|---------|
| 9 | AC-5 | static | No hardcoded branch names in 7h | Inspect 7h section for literal `develop` outside config references | 0 hardcoded occurrences |
| 10 | AC-2 | static | Build failure state documented | `grep 'failing' SKILL.md` in 7h section | "failing" option present for build status |

## Coverage Target

- All 5 ACs verified by at least one static check
- All edge cases from plan.md covered (first step, skipped build, failing build)
