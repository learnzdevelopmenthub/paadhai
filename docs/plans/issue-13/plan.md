---
issue: 13
title: Add verification gate to dev-parallel and document in claude-tools.md
branch: feature/13-add-verification-gate-dev-parallel
milestone: v2.2 — Quality Guards
status: confirmed
confirmed_at: 2026-04-11
---

# Plan — Issue #13

## Overview
Add a 5-step verification gate to `dev-parallel` (applied per-subagent via evidence-bearing reports) and document `[VERIFY]` as a reusable marker + convention in `references/claude-tools.md`.

## Files to Create
- None.

## Files to Modify
- `references/claude-tools.md` — add `[VERIFY]` row to marker table + new `## [VERIFY] Convention` section
- `.claude/skills/dev-parallel/SKILL.md` — update rationalization table, subagent prompt (Step 4), add new Step 8 (Validate Subagent Reports), renumber old Steps 8–14 to 9–15, update preamble `14 steps` → `15 steps`

## Implementation Steps

**Step 1 — Add `[VERIFY]` marker row to `claude-tools.md` table.** Insert between `[PROGRESS]` and the "Subagent Support" section.

**Step 2 — Add `## [VERIFY] Convention` section to `claude-tools.md`.** Sibling to `## [PROGRESS] Convention`. Contains: purpose, the 5 gate steps (IDENTIFY/RUN/READ/VERIFY/CLAIM), red-flag list, PASS format, FAIL format, docs-only edge case. Copy text verbatim from `dev-implement/SKILL.md § VERIFICATION GATE`.

**Step 3 — Commit 1.** `docs(claude-tools): add [VERIFY] marker and convention`

**Step 4 — Add rationalization rows to `dev-parallel/SKILL.md`.** Add 2 new rows to the existing rationalization table:
- `"Subagent said GATE: PASS, I can trust it without inspecting"` → always inspect for quoted evidence
- `"One missing claim isn't worth a re-dispatch"` → partial evidence = no evidence

**Step 5 — Update preamble step count.** Change `14 steps` → `15 steps` in both banner displays.

**Step 6 — Update Step 1 TodoWrite checklist.** Change from 14 items to 15 items, insert `Step 8/15: Validate Subagent Reports` after `Step 7/15: Collect Results`, renumber old 8–14 to 9–15.

**Step 7 — Update Step 4 (Generate Subagent Prompts).** Add two new rules to the subagent prompt builder:
- "Before reporting, run the `[VERIFY]` gate defined in `references/claude-tools.md § [VERIFY] Convention`."
- "Your report MUST end with a `GATE: PASS` block containing quoted command output for every claim. Reports without this block will be rejected."

Also extend the report format example to include the `GATE: PASS` block shape.

**Step 8 — Insert new Step 8 (Validate Subagent Reports).** Between old Step 7 (Collect Results) and old Step 8 (Stage 1 Spec Compliance Review). Contains:
- 3 checks (Presence, Evidence, Hedging)
- Verify-only re-dispatch logic (1 retry cap)
- Escalation prompt on second failure (`retry / manual / abort`)
- `[PROGRESS]` markers

**Step 9 — Renumber old Steps 8–14 to 9–15.** Update every `Step N/14` → `Step N/15` and shift numbers. Update the Stage 1 / Stage 2 headers and all `[PROGRESS]` references.

**Step 10 — Commit 2.** `feat(dev-parallel): add verification gate and subagent report validation`

## Test Cases
- **Happy path:** Subagent report contains `GATE: PASS` + quoted build/lint/test output → validation passes → proceeds to Stage 1 review.
- **Edge case — docs-only subagent:** Report contains `GATE: PASS` with quoted `Read`/`Grep` output instead of build output → validation passes.
- **Edge case — missing gate block:** Report says "done" with no `GATE: PASS` block → validation rejects → verify-only re-dispatch.
- **Edge case — hedging:** Report says "tests should pass" in a claim line → validation rejects → verify-only re-dispatch.
- **Edge case — missing evidence:** Report has `GATE: PASS` block but one claim lacks a fenced code block → validation rejects.
- **Error case — second failure:** Verify-only re-dispatch also returns a bad report → escalation prompt shown to user.

(No runtime test stubs — skills are markdown. Verification happens via the dev-plan Step 14 implementation-doc reviewer and PR review.)

## Security Considerations
> No security-relevant attack surfaces identified for this issue beyond agent-trust considerations already covered by existing Stage 1 / Stage 2 review stages in dev-parallel.

## AC Mapping

| AC | How Addressed |
|----|---------------|
| AC-1 (gate added to dev-parallel, executed per-subagent before accept) | Step 7 subagent prompt runs `[VERIFY]` gate internally; new Step 8 validates each report before accepting |
| AC-2 (completion messages must include quoted verification output; reject without) | New Step 8 Check 1 (Presence) + Check 2 (Evidence) in validator |
| AC-3 (hedging → re-dispatch with explicit verify instruction) | New Step 8 Check 3 (Hedging); verify-only re-dispatch logic with 1 retry cap |
| AC-4 (`[VERIFY]` reusable pattern in claude-tools.md) | Steps 1–2: add marker row + `## [VERIFY] Convention` section |
| AC-5 (claude-tools.md documents 5 gate steps and red-flag list) | Step 2: convention section contains full 5-step definition + red-flag list verbatim from FR-06 |

| SRS Ref | Relation |
|---------|----------|
| FR-06 AC-2 | = issue AC-1 (gate added to dev-parallel) |
| FR-06 AC-4 | = issue AC-3 (hedging triggers re-verification) |
| FR-06 AC-5 | = issue AC-4 (documented in claude-tools.md) |

## Definition of Done
- [ ] `references/claude-tools.md` contains `[VERIFY]` marker row + `## [VERIFY] Convention` section
- [ ] `.claude/skills/dev-parallel/SKILL.md` has 15 steps, new Step 8 validator, updated subagent prompt, 2 new rationalization rows
- [ ] All existing `[PROGRESS]` numbering in dev-parallel is consistent with 15-step layout
- [ ] 2 commits pushed: `docs(claude-tools): ...` and `feat(dev-parallel): ...`
- [ ] Implementation-doc reviewer in dev-plan Step 14 returns PASS
- [ ] No source build/lint/test (project `language: none` in `.paadhai.json`) — verification is read-through + grep
- [ ] All 5 issue ACs checked