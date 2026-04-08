## Test Plan — Issue #8: Add [PROGRESS] marker and TodoWrite integration to multi-step skills

### Test Framework: None (markdown/shell — grep-based content verification)

### Test Stub File: `tests/verify-issue-8.sh`

---

### Test Cases

#### Happy Path

| # | AC | Type | Description | Input | Expected |
|---|----|----|-------------|-------|---------|
| TC-01 | AC-1 | content | `[PROGRESS]` marker row exists in `references/claude-tools.md` | `grep "\[PROGRESS\]" references/claude-tools.md` | ≥1 match |
| TC-02 | AC-1 | content | `[PROGRESS]` section header exists in `references/claude-tools.md` | `grep "## \[PROGRESS\]" references/claude-tools.md` | ≥1 match |
| TC-03 | AC-1 | content | Graceful degradation note present in `references/claude-tools.md` | `grep -i "graceful" references/claude-tools.md` | ≥1 match |
| TC-04 | AC-2 | content | `dev-implement` contains PROGRESS init block + per-step markers | `grep -c "PROGRESS" .claude/skills/dev-implement/SKILL.md` | ≥20 |
| TC-05 | AC-2 | content | `dev-parallel` contains PROGRESS init block + per-step markers | `grep -c "PROGRESS" .claude/skills/dev-parallel/SKILL.md` | ≥28 |
| TC-06 | AC-2 | content | `dev-plan` contains PROGRESS init block + per-step markers | `grep -c "PROGRESS" .claude/skills/dev-plan/SKILL.md` | ≥34 |
| TC-07 | AC-2 | content | `project-plan` contains PROGRESS init block + per-step markers | `grep -c "PROGRESS" .claude/skills/project-plan/SKILL.md` | ≥20 |
| TC-08 | AC-2 | content | `release-plan` contains PROGRESS init block + per-step markers | `grep -c "PROGRESS" .claude/skills/release-plan/SKILL.md` | ≥16 |
| TC-09 | AC-2 | content | `dev-release` contains PROGRESS init block + per-step markers | `grep -c "PROGRESS" .claude/skills/dev-release/SKILL.md` | ≥28 |
| TC-10 | AC-3 | content | `dev-implement` has `[in_progress]` per-step markers (steps 2–10) | `grep -c "in_progress" .claude/skills/dev-implement/SKILL.md` | ≥9 |
| TC-11 | AC-4 | content | `dev-implement` has `[completed]` per-step markers (steps 2–10) | `grep -c "completed" .claude/skills/dev-implement/SKILL.md` | ≥9 |
| TC-12 | AC-4 | content | `dev-implement` completed format includes `Files:` field | `grep "Files:" .claude/skills/dev-implement/SKILL.md` | ≥1 match |
| TC-13 | AC-4 | content | `dev-implement` completed format includes `Build:` field | `grep "Build:" .claude/skills/dev-implement/SKILL.md` | ≥1 match |

#### Edge Cases

| # | AC | Type | Description | Input | Expected |
|---|----|----|-------------|-------|---------|
| TC-14 | AC-2 | content | `dev-implement` init block last item is `Step 10/10:` | `grep "Step 10/10:" .claude/skills/dev-implement/SKILL.md` | ≥1 match |
| TC-15 | AC-2 | content | `dev-parallel` init block last item is `Step 14/14:` | `grep "Step 14/14:" .claude/skills/dev-parallel/SKILL.md` | ≥1 match |
| TC-16 | AC-2 | content | `dev-plan` init block last item is `Step 17/17:` | `grep "Step 17/17:" .claude/skills/dev-plan/SKILL.md` | ≥1 match |
| TC-17 | AC-2 | content | `project-plan` init block last item is `Step 10/10:` | `grep "Step 10/10:" .claude/skills/project-plan/SKILL.md` | ≥1 match |
| TC-18 | AC-2 | content | `release-plan` init block last item is `Step 8/8:` | `grep "Step 8/8:" .claude/skills/release-plan/SKILL.md` | ≥1 match |
| TC-19 | AC-2 | content | `dev-release` init block last item is `Step 14/14:` | `grep "Step 14/14:" .claude/skills/dev-release/SKILL.md` | ≥1 match |
| TC-20 | AC-2 | content | Init block uses correct `Step N/Total:` format in `dev-implement` | `grep "Step 1/10:" .claude/skills/dev-implement/SKILL.md` | ≥1 match |

#### Error / Failure Cases

| # | AC | Type | Description | Input | Expected |
|---|----|----|-------------|-------|---------|
| TC-21 | AC-2 | content | `dev-implement` init block does NOT use wrong total | `grep -E "Step 1/(9\|11):" .claude/skills/dev-implement/SKILL.md` | 0 matches |
| TC-22 | AC-3 | content | No step has both `in_progress` and `completed` on the same line | `grep -E "in_progress.*completed\|completed.*in_progress" ...SKILL.md` | 0 matches |
| TC-23 | AC-1 | content | `[PROGRESS]` table row appears exactly once in `claude-tools.md` | Count `^\| \`[PROGRESS]\`` rows | exactly 1 |
| TC-24 | AC-4 | content | `Files:` field does not contain hardcoded `src/` path | `grep "Files: src/" .claude/skills/dev-implement/SKILL.md` | 0 matches |

---

### Coverage Target
- All 5 ACs: 100% structural coverage via grep checks
- 24 test cases: 13 happy path / 7 edge case / 4 error case
- Behavioral coverage (manual): happy path (run dev-implement, observe TodoWrite updates), edge (single-step), error (mid-step failure)

---

### Manual Behavioral Test Notes

These cannot be automated — they require running a Paadhai skill inside Claude Code:

**M-1 (Happy path):** Invoke `dev-implement` on any plan with ≥2 steps. Observe that:
- A TodoWrite checklist appears immediately with one item per step
- The current step shows `[in_progress]` suffix
- Prior steps show `[completed]` with Files and Build summary

**M-2 (Edge case — graceful degradation):** Verify that if TodoWrite fails silently, the skill continues rather than halting.

**M-3 (Error case):** When a step fails mid-execution, the failed step must NOT be marked `completed`; all remaining steps stay `pending`.
