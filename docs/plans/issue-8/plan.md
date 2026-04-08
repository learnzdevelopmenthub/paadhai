---
issue: 8
title: Add [PROGRESS] marker and TodoWrite integration to multi-step skills
branch: feature/8-add-progress-marker-todowrite-skills
milestone: v2.1 — Visibility
status: confirmed
confirmed_at: 2026-04-08T00:00:00Z
---

## Overview

Add a `[PROGRESS]` capability marker to `references/claude-tools.md` and instrument 6 affected skills (`dev-implement`, `dev-parallel`, `dev-plan`, `project-plan`, `release-plan`, `dev-release`) with TodoWrite-based step tracking at the start of each skill's execution, updating each item's status and content as steps progress.

## Files to Create

None.

## Files to Modify

- `references/claude-tools.md` — Add `[PROGRESS]` marker row mapping to TodoWrite tool, with graceful-degradation note
- `.claude/skills/dev-implement/SKILL.md` — Add `[PROGRESS]` checklist initialization after Step 1; update each step to mark `in_progress` at start and `completed` (with files/build/lint) at end
- `.claude/skills/dev-parallel/SKILL.md` — Same pattern; `[PROGRESS]` init after Step 1; mark steps through Step 14
- `.claude/skills/dev-plan/SKILL.md` — Same pattern; Steps 1–17
- `.claude/skills/project-plan/SKILL.md` — Same pattern; Steps 1–10
- `.claude/skills/release-plan/SKILL.md` — Same pattern; Steps 1–8
- `.claude/skills/dev-release/SKILL.md` — Same pattern; Steps 1–14

## Implementation Steps

1. **Add `[PROGRESS]` marker to `references/claude-tools.md`**
   - Append a new row to the marker table: `| \`[PROGRESS]\` | \`TodoWrite\` tool | Create and update a live step checklist. Graceful degradation: skip if TodoWrite unavailable |`
   - Add a `[PROGRESS]` section under "Subagent Support" documenting item format and completion update convention
   - Expected: file has 9 rows in the marker table; `[PROGRESS]` is the last row

2. **Instrument `dev-implement/SKILL.md`**
   - After STEP 1 body, insert a `[PROGRESS]` block that creates a 10-item TodoWrite list (one per STEP 1–10), all `pending`, using format `Step N/10: <step title>`
   - At the start of each STEP (2–10), add a `[PROGRESS]` line marking that step `in_progress`
   - At the end of each STEP (2–10), add a `[PROGRESS]` line marking it `completed` with files changed and build/lint result
   - Expected: 10-item TodoWrite list is created; each step transitions `pending → in_progress → completed`

3. **Instrument `dev-parallel/SKILL.md`**
   - Same pattern as step 2; 14-item list (STEP 1–14)
   - Expected: 14-item list; correct transitions per step

4. **Instrument `dev-plan/SKILL.md`**
   - Same pattern; 17-item list (STEP 1–17)
   - Expected: 17-item list; correct transitions

5. **Instrument `project-plan/SKILL.md`**
   - Same pattern; 10-item list (STEP 1–10)
   - Expected: 10-item list; correct transitions

6. **Instrument `release-plan/SKILL.md`**
   - Same pattern; 8-item list (STEP 1–8)
   - Expected: 8-item list; correct transitions

7. **Instrument `dev-release/SKILL.md`**
   - Same pattern; 14-item list (STEP 1–14)
   - Expected: 14-item list; correct transitions

## Test Cases

- **Happy path:** Run `dev-implement` on a multi-step plan — TodoWrite list of 10 items appears immediately; as each step executes, prior items show `completed` with files/build/lint; current step shows `in_progress`
- **Edge case (single-step skill):** A skill with 1 step still creates a 1-item TodoWrite list
- **Error case:** Step fails mid-execution — the failed step is NOT marked `completed`; remaining steps stay `pending`; skill does not proceed until failure is resolved

## Security Considerations

No security-relevant attack surfaces identified for this issue. These are markdown instruction files with no runtime code execution or user input handling.

## AC Mapping

| AC | How Addressed |
|----|---------------|
| AC-1 | `[PROGRESS]` marker added to `references/claude-tools.md` mapping to TodoWrite |
| AC-2 | Each affected skill creates TodoWrite list at start with one item per numbered STEP |
| AC-3 | Current step marked `in_progress`; all prior steps marked `completed` |
| AC-4 | Completed items updated with files changed and build/lint result inline |
| AC-5 | TodoWrite checklist is always visible in Claude Code's task panel — no scrolling needed |

## Definition of Done

- [ ] All ACs checked
- [ ] All 6 skills + `references/claude-tools.md` updated
- [ ] No hardcoded repo names or branch names in any modified file

## Notes

- ADR: declined (no new technology, no architectural decision — purely additive markdown changes)
- Decisions locked in:
  - Item format: `Step N/Total: <step title>` with `[in_progress]`/`[completed]` suffix
  - Files/build/lint embedded inside completed todo item content
  - Graceful degradation via inline `[PROGRESS]` note — no explicit availability check block
  - Single-step skills still create a 1-item list
  - All numbered STEPs tracked (including Load Config and Handoff); sub-steps (e.g., 7a, 7b) not counted separately
