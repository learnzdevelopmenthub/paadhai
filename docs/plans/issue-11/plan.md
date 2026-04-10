---
issue: 11
title: Add rationalization prevention tables to dev-implement, dev-plan, dev-parallel
branch: feature/11-rationalization-prevention-tables
milestone: v2.2 — Quality Guards
status: confirmed
confirmed_at: 2026-04-10
---

## Overview

Add rationalization prevention tables to `dev-implement`, `dev-plan`, and `dev-parallel` skill files. Each table lists common agent rationalizations for skipping steps, explains why each is wrong, and states the correct action — tailored to each skill's specific failure modes.

## Files to Create

- `docs/plans/issue-11/plan.md`: Plan document
- `docs/plans/issue-11/implementation.md`: Step-by-step implementation doc

## Files to Modify

- `.claude/skills/dev-implement/SKILL.md`: Add rationalization prevention table between PREAMBLE and STEP 1 (after line 53)
- `.claude/skills/dev-plan/SKILL.md`: Add rationalization prevention table between PREAMBLE and STEP 1 (after line 46)
- `.claude/skills/dev-parallel/SKILL.md`: Add rationalization prevention table between PREAMBLE and STEP 1 (after line 44)

## Implementation Steps

1. **Add rationalization table to `dev-implement/SKILL.md`**
   - Insert `## RATIONALIZATION PREVENTION` section with >=5 entries tailored to implementation failure modes (skipping review, skipping tests, skipping build, batching commits, assuming trivial)
   - Expected: New section between PREAMBLE `---` and `## STEP 1`

2. **Add rationalization table to `dev-plan/SKILL.md`**
   - Insert `## RATIONALIZATION PREVENTION` section with >=5 entries tailored to planning failure modes (skipping brainstorming, skipping security assessment, skipping version validation, rushing confirmation, skipping code reading)
   - Expected: New section between PREAMBLE `---` and `## STEP 1`

3. **Add rationalization table to `dev-parallel/SKILL.md`**
   - Insert `## RATIONALIZATION PREVENTION` section with >=5 entries tailored to parallel execution failure modes (skipping review stages, merging without verification, rushing subagent dispatch, skipping conflict check, assuming independence)
   - Expected: New section between PREAMBLE `---` and `## STEP 1`

## Test Cases

- **Happy path**: Read each updated skill file — verify rationalization table appears before STEP 1 with >=5 entries in 3-column format
- **Edge case**: Table entries cover both code-change rationalizations and verification-step rationalizations
- **Error case**: N/A — documentation-only change

## Security Considerations

No security-relevant attack surfaces identified for this issue.

## AC Mapping

| AC | How Addressed |
|----|--------------|
| AC-1 | Tables added to all three skill files (Steps 1-3) |
| AC-2 | Each table has >=5 entries with thought pattern, counter, and required action |
| AC-3 | Tables placed between PREAMBLE and STEP 1 in each file |
| AC-4 | Three-column format: Thought / Why it's wrong / What to do |

## Definition of Done

- [ ] All ACs checked
- [ ] Each table has >=5 skill-specific entries
- [ ] Tables are between PREAMBLE and STEP 1 in each file
- [ ] 3-column markdown format matches SRS example
