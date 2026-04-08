---
issue: 10
title: Add per-step progress dashboard to dev-implement
branch: feature/10-per-step-progress-dashboard
milestone: v2.1 — Visibility
status: confirmed
confirmed_at: 2026-04-08
---

## Overview

Add a compact aggregate progress dashboard (sub-step `7h`) to `dev-implement`'s implementation loop that displays cumulative stats after each step's commit, using actual git and command output as data sources.

## Files to Modify

- `.claude/skills/dev-implement/SKILL.md`: Add dashboard sub-step 7h, add dashboard data-gathering shell commands, update Step 9 summary to reference cumulative data

## Implementation Steps

1. **Add dashboard data-gathering commands to Step 7 (after 7g commit)**
   - Add new sub-step `7h — Progress Dashboard` after the existing `7g — Commit`
   - Include shell commands to gather cumulative stats:
     - `git diff --stat {config.repo.develop_branch}...HEAD` → parse file counts (created vs modified)
     - `git rev-list {config.repo.develop_branch}..HEAD --count` → commit count
   - Build status from most recent 7d result; test status from most recent test run (or "not yet run")
   - Expected: new sub-step added to SKILL.md

2. **Define the dashboard display format**
   - 12-char progress bar using `█` (filled) and `░` (empty), proportional to completed/total steps
   - Exact format matching SRS FR-03:
     ```
     Progress: ████████░░░░ 8/12 steps (67%)
     ══════════════════════════════════════════
     Files changed : 14 (6 created, 8 modified)
     Commits       : 7
     Tests         : 23 passing, 0 failing
     Build         : passing
     ══════════════════════════════════════════
     ```
   - Maximum 6 lines excluding border characters (AC-4)
   - Expected: format block defined in SKILL.md

3. **Add instructions for deriving file statistics**
   - Use `git diff --name-status {config.repo.develop_branch}...HEAD` for accurate created (A) vs modified (M) counts
   - Count lines starting with `A` as "created", lines starting with `M` as "modified"
   - Expected: shell commands and parsing instructions in SKILL.md

4. **Handle edge cases**
   - Step 1 with no prior changes: show `0 files changed`, `0 commits`, `Tests: not yet run`, `Build: not yet run`
   - Steps where build/lint were skipped (no source files changed): show last known build status
   - Test line: show "not yet run" until Step 8 runs `{config.stack.test_cmd}`; after that show actual counts
   - Expected: edge case handling documented in the sub-step instructions

## Test Cases

- **Happy path**: Complete step 4 of 8 — dashboard shows `4/8 (50%)`, correct cumulative file stats, commit count, and build status from most recent 7d
- **Edge case**: Step with no file changes (config-only) — dashboard shows `0 files changed` for that step but cumulative total still accurate
- **Error case**: Build fails on a step — dashboard shows `Build: failing` (not "passing")
- **Edge case**: First step completed — dashboard shows with zeroes/initial values

## Security Considerations

No security-relevant attack surfaces identified for this issue.

## AC Mapping

| AC | How Addressed |
|----|--------------|
| AC-1 | Dashboard displayed in new sub-step 7h, after every completed step's commit |
| AC-2 | Shell commands gather step progress, file stats (created/modified via `git diff --name-status`), commit count (`git rev-list --count`), test summary, build status |
| AC-3 | 12-char text progress bar using `█`/`░` characters, proportional to completion |
| AC-4 | Format is exactly 6 lines: progress bar, files, commits, tests, build — within top/bottom borders (borders excluded per AC) |
| AC-5 | All data from `git diff --name-status`, `git rev-list --count`, and actual build/test command output |

## Definition of Done

- [ ] All ACs checked
- [ ] Dashboard displays after each step in implementation loop
- [ ] Data derived from actual commands, not estimation
