## Test Plan — Issue #9: Implement skill invocation announcement banners

### Test Framework: None (markdown/shell — grep-based content verification)

### Test Stub File: `tests/verify-issue-9.sh`

---

### Test Cases

#### Happy Path

| # | AC | Type | Description | Input | Expected |
|---|----|----|-------------|-------|---------|
| TC-01 | AC-1 | content | All 22 SKILL.md files contain `## PREAMBLE` section | `grep -rl "## PREAMBLE" .claude/skills/*/SKILL.md \| wc -l` | 22 |
| TC-02 | AC-1 | content | No SKILL.md is missing the preamble | Loop: `grep -q "## PREAMBLE" $f` for each | 0 missing |
| TC-03 | AC-2 | content | dev-implement (issue-aware) contains issue extraction in preamble | `preamble_grep "Extract issue number" dev-implement` | ≥1 match |
| TC-04 | AC-2 | content | dev-start (issue-aware) contains `gh api` in preamble | `preamble_grep "gh api" dev-start` | ≥1 match |
| TC-05 | AC-2 | content | dev-plan (issue-aware) contains `gh api` in preamble | `preamble_grep "gh api" dev-plan` | ≥1 match |
| TC-06 | AC-3 | content | All 22 preambles detect branch via `git branch --show-current` | Loop over all skills | 22 matches |
| TC-07 | AC-4 | content | dev-implement banner shows "10 steps" | `preamble_grep_fixed "10 steps" dev-implement` | ≥1 match |
| TC-08 | AC-4 | content | dev-plan banner shows "17 steps" | `preamble_grep_fixed "17 steps" dev-plan` | ≥1 match |
| TC-09 | AC-4 | content | dev-parallel banner shows "14 steps" | `preamble_grep_fixed "14 steps" dev-parallel` | ≥1 match |
| TC-10 | AC-4 | content | dev-status banner shows "7 steps" | `preamble_grep_fixed "7 steps" dev-status` | ≥1 match |
| TC-11 | AC-5 | content | All 22 preambles have box-drawing `────` | Loop over all skills | 22 matches |

#### Edge Cases

| # | AC | Type | Description | Input | Expected |
|---|----|----|-------------|-------|---------|
| TC-12 | AC-2 | content | 14 issue-aware preambles reference `feature/` branch pattern | Loop over issue-aware skills | 14 matches |
| TC-13 | AC-2 | content | 8 non-issue preambles do NOT contain `gh api` | Loop over non-issue skills | 0 matches |
| TC-14 | AC-2 | content | 14 issue-aware preambles mention graceful degradation | Loop: `preamble_grep_case "gracefully"` | 14 matches |
| TC-15 | AC-4 | content | Each skill's step count in banner matches expected | Compare `N steps` in preamble vs STEP_COUNTS map | All match |
| TC-16 | AC-5 | content | PREAMBLE appears before STEP 1 in every file | Compare line numbers | true for all 22 |

#### Error / Failure Cases

| # | AC | Type | Description | Input | Expected |
|---|----|----|-------------|-------|---------|
| TC-17 | AC-1 | content | No SKILL.md has more than one `## PREAMBLE` section | `grep -c "## PREAMBLE"` per file | exactly 1 per file |
| TC-18 | AC-5 | content | No preamble uses plain dashes `----` instead of box-drawing `────` | Check for `^-{4,}` in preamble | 0 matches |
| TC-19 | AC-2 | content | Non-issue skill banners don't mention "Issue #" | Loop over non-issue preambles | 0 matches |
| TC-20 | AC-4 | content | No skill has "0 steps" in banner | Loop over all preambles | 0 matches |

---

### Coverage Target
- All 5 ACs: 100% structural coverage via grep checks
- 20 test cases: 11 happy path / 5 edge case / 4 error case
- Behavioral coverage (manual): see below

---

### Manual Behavioral Test Notes

These cannot be automated — they require running a Paadhai skill inside Claude Code:

**M-1 (Happy path):** Run `dev-implement` on a feature branch with an active issue — verify banner shows skill name, issue number + title, branch, and step count in box-drawing format.

**M-2 (Edge case):** Run `dev-status` (read-only, no issue context) — verify banner still displays with skill name, step count, and branch only (no issue line).

**M-3 (Error case):** Run a skill when `gh api` fails (no network / no auth) — verify banner degrades gracefully (shows banner without issue title rather than erroring).
