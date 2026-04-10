---
issue: 12
title: Add 5-step verification gate to dev-implement
branch: feature/12-verification-gate-dev-implement
milestone: v2.2 — Quality Guards
status: confirmed
confirmed_at: 2026-04-10
---

## Overview

Add a mandatory 5-step verification gate (IDENTIFY → RUN → READ → VERIFY → CLAIM) to `dev-implement/SKILL.md`. The gate runs per-step inside Step 7 after build/lint succeed, and blocks marking a step complete until the agent quotes actual command output. Implements SRS FR-06 for the `dev-implement` skill (issue #13 covers `dev-parallel` and `references/claude-tools.md`).

## Files to Create

- `docs/plans/issue-12/plan.md`: Plan document
- `docs/plans/issue-12/implementation.md`: Step-by-step implementation doc

## Files to Modify

- `.claude/skills/dev-implement/SKILL.md`:
  1. Insert new `## VERIFICATION GATE` section between the RATIONALIZATION PREVENTION table's closing `---` and `## STEP 1 — Load Config`
  2. Insert new sub-step `### 7d.1 — Verification Gate` between `### 7d — Build + Lint` and `### 7e — Update Implementation Doc`

## Implementation Steps

1. **Insert `## VERIFICATION GATE` section into `dev-implement/SKILL.md`**
   - Placement: directly after the RATIONALIZATION PREVENTION table's closing `---` and before `## STEP 1 — Load Config`
   - Content:
     - Introduction paragraph: the gate is mandatory per-step and cannot be overridden
     - Numbered 5-step list: IDENTIFY → RUN → READ → VERIFY → CLAIM (verbatim from SRS FR-06)
     - Rule: "Commands must be re-run — results cannot be recalled from memory" (AC-4)
     - Red flags block listing "should", "probably", "seems to", "I believe", plus "no command output quoted in the completion message"
     - Explicit rule: "If any red flag appears in your CLAIM, restart from RUN" (AC-3)
     - FAIL format: structured `GATE: FAIL` header with numbered unmet items; step stays `pending`; no commit until PASS (AC-5)
     - PASS format: `GATE: PASS` followed by claims, each with a quoted output block (AC-2)
   - Expected: New section present between RP and STEP 1, ~40 lines

2. **Insert `### 7d.1 — Verification Gate` sub-step into Step 7 (Implementation Loop)**
   - Placement: between `### 7d — Build + Lint` and `### 7e — Update Implementation Doc`
   - Content:
     - Reference to the `## VERIFICATION GATE` section at the top of the file
     - Instruction: run the 5 gate steps using the exact output from 7d's build/lint plus any test command for this step
     - Blocking rule: if the gate returns FAIL, do not proceed to 7e; fix the missing evidence and re-run the gate
     - Edge case: if 7d was skipped (no source files), the gate must still run `{config.stack.lint_cmd}` or the test command and quote its output
     - Auto-retrigger rule: hedging language in the CLAIM forces restart from RUN (AC-3)
   - Expected: New sub-step ~12 lines

3. **Verify edits by reading the updated file**
   - Confirm VERIFICATION GATE section is between RATIONALIZATION PREVENTION and `## STEP 1`
   - Confirm `### 7d.1` is between `### 7d` and `### 7e`
   - Confirm all 5 ACs are addressed by inspection and quote the relevant lines

## Test Cases

- **Happy path (AC-1)**: Read updated `SKILL.md` — VERIFICATION GATE section exists before STEP 1, and sub-step 7d.1 appears between 7d and 7e. Both sections reference the 5 gate steps.
- **Edge case (docs-only change)**: Gate text explicitly states that when 7d is skipped (no source files), the agent must still run `{config.stack.lint_cmd}` or the test command and quote its output.
- **Error case (AC-3)**: Gate red-flag list includes all four hedging words ("should", "probably", "seems to", "I believe") and a catch-all "no command output quoted" rule with explicit re-verification instruction.
- **Error case (AC-4)**: Gate text contains an explicit rule that commands must be re-run and results cannot be recalled from memory.
- **Error case (AC-5)**: FAIL format is a structured block with numbered unmet items; wording states the step stays `pending` and no commit occurs until the gate returns PASS.

## Security Considerations

No security-relevant attack surfaces identified for this issue.

## AC Mapping

| AC   | How Addressed                                                                                   |
|------|-------------------------------------------------------------------------------------------------|
| AC-1 | Gate defined in new `## VERIFICATION GATE` section + wired into Step 7 via sub-step `### 7d.1`  |
| AC-2 | CLAIM step and PASS format both require quoted command output (test/build/lint) in the message |
| AC-3 | Red flags list (hedging words + missing output) with explicit restart-from-RUN rule             |
| AC-4 | Gate text explicitly forbids recalling results from memory; mandates re-running commands        |
| AC-5 | FAIL format is a structured block listing numbered unmet items; step blocked from completion    |

## Definition of Done

- [ ] `## VERIFICATION GATE` section present between RATIONALIZATION PREVENTION and `## STEP 1`
- [ ] Sub-step `### 7d.1 — Verification Gate` present between `### 7d` and `### 7e` in Step 7
- [ ] All 5 ACs verifiable by reading `SKILL.md`
- [ ] Plan + implementation doc committed under `docs/plans/issue-12/`

> Build / lint / test: N/A — no build stack configured for this repo (`.paadhai.json` stack is `none`); this is a docs-only change.
