---
issue: 12
title: Add 5-step verification gate to dev-implement
branch: feature/12-verification-gate-dev-implement
type: manual-verification
---

## Test Plan — Issue #12: Add 5-step verification gate to dev-implement

### Test Framework: Manual verification (read-based)

This is a documentation-only change to `.claude/skills/dev-implement/SKILL.md`. There is no runtime code, no test framework, and no executable tests. Verification is done by reading the modified file and checking structural requirements via Read/Grep.

### Test Cases

#### Happy Path

| #  | AC   | Type   | Description                                  | Input                                                                          | Expected                                                                                              |
|----|------|--------|----------------------------------------------|--------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| 1  | AC-1 | verify | Top-level gate section present               | Grep `^## VERIFICATION GATE` in `dev-implement/SKILL.md`                       | Exactly one match                                                                                     |
| 2  | AC-1 | verify | Gate placed before STEP 1                    | Read section order in `SKILL.md`                                               | `## VERIFICATION GATE` appears before `## STEP 1 — Load Config`                                       |
| 3  | AC-1 | verify | Gate sub-step wired into Step 7              | Grep `^### 7d\.1 — Verification Gate`                                          | Exactly one match between `### 7d` and `### 7e`                                                       |
| 4  | AC-1 | verify | All 5 gate phases named                      | Grep for `IDENTIFY`, `RUN`, `READ`, `VERIFY`, `CLAIM` headings                 | All 5 phase names present in the gate section                                                         |
| 5  | AC-2 | verify | PASS format requires quoted output           | Read PASS format block                                                         | Block contains `Evidence:` followed by a fenced code block placeholder                                |
| 6  | AC-2 | verify | CLAIM step references quoted output rule     | Grep `quoted block of the exact output`                                        | At least one match in CLAIM step description                                                          |

#### Edge Cases

| #  | AC   | Type   | Description                                  | Input                                                                          | Expected                                                                                              |
|----|------|--------|----------------------------------------------|--------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| 7  | AC-1 | verify | Docs-only fallback documented                | Grep `docs-only` or `7d was skipped` in gate section                           | Match present; fallback says run `{config.stack.lint_cmd}` or `Read`/`Grep` and quote output          |
| 8  | AC-2 | verify | Sub-step 7d.1 references top-level gate      | Read 7d.1 body                                                                 | Body references the `## VERIFICATION GATE` section                                                    |
| 9  | AC-1 | verify | Step count in banner unchanged               | Read PREAMBLE banner block                                                     | Still says `10 steps` (7d.1 is a sub-step, not a new top-level step)                                  |

#### Error / Failure Cases

| #  | AC   | Type   | Description                                  | Input                                                                          | Expected                                                                                              |
|----|------|--------|----------------------------------------------|--------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| 10 | AC-3 | verify | Hedging words listed (all 4 from issue)      | Grep `should`, `probably`, `seems to`, `I believe` in red flags block          | All 4 words present in a single red-flags list                                                        |
| 11 | AC-3 | verify | Hedging triggers restart from RUN            | Grep `restart from .*RUN` or `restart the gate from RUN`                       | At least one match in red flags block AND in 7d.1 auto-retrigger rule                                 |
| 12 | AC-3 | verify | Missing-quoted-output is a red flag          | Read red flags list                                                            | Bullet for "no quoted command output block for a claim"                                               |
| 13 | AC-4 | verify | Memory-recall ban present                    | Grep `cannot be recalled from memory` or `re-run every time`                   | At least one match in gate intro paragraph                                                            |
| 14 | AC-5 | verify | FAIL format is a structured block            | Read FAIL format block                                                         | Block has `GATE: FAIL` header + `Unmet items` numbered list                                           |
| 15 | AC-5 | verify | FAIL blocks step completion                  | Grep `step stays \`pending\`` AND `Do not proceed to 7e`                       | Both phrases present in FAIL format block or 7d.1 sub-step                                            |
| 16 | AC-5 | verify | FAIL blocks commit                           | Grep `Do not commit` in 7d.1 or FAIL format                                    | At least one match                                                                                    |

### Per-AC Mapping

| AC   | Tests                  |
|------|------------------------|
| AC-1 | 1, 2, 3, 4, 7, 9       |
| AC-2 | 5, 6, 8                |
| AC-3 | 10, 11, 12             |
| AC-4 | 13                     |
| AC-5 | 14, 15, 16             |

### Coverage Target

- N/A — no executable code. Coverage = "every AC verifiable by a Read/Grep against the modified file" (16 checks across 5 ACs).

### Test Stubs

N/A — no test framework (`stack.language: none`). Verification is performed inline during implementation Step 3 of `docs/plans/issue-12/implementation.md`, which already runs Read/Grep against `SKILL.md` per the gate's own format.
