---
issue: 14
title: Add commit mode selection prompt to dev-implement
branch: feature/14-commit-mode-selection-prompt
milestone: v2.3 — Workflow Efficiency
status: confirmed
confirmed_at: 2026-04-13T00:00:00Z
---

## Overview

Replace the binary "Auto-commit after each step? (yes/no)" prompt in `dev-implement` Step 2 with a 3-option commit mode selection prompt (per-step, auto-commit, batch) that includes the total step count. Update G-06 wording to reference the new `commit_mode` variable.

## Files to Create

- `docs/plans/issue-14/plan.md`: Confirmed plan document
- `docs/plans/issue-14/implementation.md`: Step-by-step implementation doc

## Files to Modify

- `.claude/skills/dev-implement/SKILL.md`: Replace binary auto-commit question with 3-option commit mode prompt (Step 2) and update G-06 wording (Step 7f)

## Implementation Steps

1. **Replace binary auto-commit question with commit mode prompt (Step 2, lines 185-187)**
   - Remove: `Auto-commit after each step? (yes / no)`
   - Add: AskUserQuestion-based 3-option prompt with step count
   - Include prompt text: "Implementation has N steps. How would you like to handle commits?"
   - Options: Per-step (current behavior), Auto-commit, Batch
   - Store selection as `commit_mode` variable (`per-step` | `auto-commit` | `batch`)
   - Expected: Step 2 now presents 3-option commit mode selection after loading the implementation doc

2. **Update G-06 gate wording (Step 7f, line 307)**
   - Remove: `If auto-commit = yes → commit automatically. If no → wait for "yes".`
   - Add: `If commit_mode = per-step → wait for user approval. If commit_mode = auto-commit → commit automatically. If commit_mode = batch → defer to batch logic.`
   - Expected: G-06 references the 3-state `commit_mode` variable

3. **Verify internal consistency**
   - Grep `SKILL.md` for any remaining references to `auto-commit = yes` or the old binary pattern
   - Ensure no orphaned references to the old yes/no variable
   - Expected: Zero stale references

## Test Cases

- **Happy path**: Load a 10-step implementation plan — verify prompt appears showing all 3 modes and the step count
- **Edge case**: Single-step plan — verify prompt still appears
- **Invalid input**: AskUserQuestion constrains selection — invalid input structurally impossible

## Security Considerations

No security-relevant attack surfaces identified for this issue.

SRS security note for downstream issues: SRS 6.2 requires "auto-commit mode must not bypass pre-commit hooks (`--no-verify` is never used)" — applies to #15, not #14.

## AC Mapping

| AC | How Addressed |
|----|--------------|
| AC-1 | Prompt placed in Step 2, after loading implementation doc, before step execution (Step 3+) |
| AC-2 | AskUserQuestion presents all 3 options: per-step, auto-commit, batch |
| AC-3 | Per-step option described as "approve each commit individually (current behavior)" — G-06 preserves gate |
| AC-4 | Selection stored as `commit_mode` variable, referenced by G-06 for use by #15/#16 |
| AC-5 | Prompt text includes total step count parsed from implementation doc progress table |

## Definition of Done

- [ ] All ACs checked
- [ ] `SKILL.md` internally consistent — no stale references to old binary auto-commit
- [ ] G-06 references `commit_mode` with all 3 states
- [ ] SRS FR-04 AC-1, AC-2 satisfied (AC-3/4/5 deferred to #15/#16)

## Brainstorming Decisions

| Question | Decision | SRS Ref |
|----------|----------|---------|
| Prompt style | Replace auto-commit only, keep model preference separate | FR-04 |
| Persistence | In-memory only, no session file | Q-02 (Open) |
| G-06 update | Update wording to reference commit_mode (3 states) | FR-04 AC-2 |
| Rationalization table | Defer update to #16 | FR-05 |
| Prompt mechanism | AskUserQuestion tool | FR-04 content spec |
| Step count source | Parse implementation doc progress table | FR-04 AC-1 |
| Invalid input | Handled by AskUserQuestion constraints | Issue test checklist |
