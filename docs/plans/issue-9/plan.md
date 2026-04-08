---
issue: 9
title: Implement skill invocation announcement banners
branch: feature/9-skill-invocation-banners
milestone: "v2.1 \u2014 Visibility"
status: confirmed
confirmed_at: 2026-04-08
---

## Overview

Add a `## PREAMBLE \u2014 Announcement Banner` section to all 22 SKILL.md files, displaying a context banner as the first output of every skill invocation per SRS FR-02.

## Files to Create

None.

## Files to Modify

- `.claude/skills/dev-adr/SKILL.md` \u2014 add preamble (10 steps)
- `.claude/skills/dev-audit/SKILL.md` \u2014 add preamble (7 steps)
- `.claude/skills/dev-debug/SKILL.md` \u2014 add preamble (11 steps)
- `.claude/skills/dev-deps/SKILL.md` \u2014 add preamble (8 steps)
- `.claude/skills/dev-docs/SKILL.md` \u2014 add preamble (8 steps)
- `.claude/skills/dev-hotfix/SKILL.md` \u2014 add preamble (12 steps)
- `.claude/skills/dev-implement/SKILL.md` \u2014 add preamble (10 steps)
- `.claude/skills/dev-parallel/SKILL.md` \u2014 add preamble (14 steps)
- `.claude/skills/dev-plan/SKILL.md` \u2014 add preamble (17 steps)
- `.claude/skills/dev-pr/SKILL.md` \u2014 add preamble (8 steps)
- `.claude/skills/dev-release/SKILL.md` \u2014 add preamble (14 steps)
- `.claude/skills/dev-rollback/SKILL.md` \u2014 add preamble (8 steps)
- `.claude/skills/dev-ship/SKILL.md` \u2014 add preamble (7 steps)
- `.claude/skills/dev-start/SKILL.md` \u2014 add preamble (8 steps)
- `.claude/skills/dev-status/SKILL.md` \u2014 add preamble (7 steps)
- `.claude/skills/dev-test/SKILL.md` \u2014 add preamble (11 steps)
- `.claude/skills/dev-unblock/SKILL.md` \u2014 add preamble (8 steps)
- `.claude/skills/next-version/SKILL.md` \u2014 add preamble (7 steps)
- `.claude/skills/paadhai-skill/SKILL.md` \u2014 add preamble (13 steps)
- `.claude/skills/project-init/SKILL.md` \u2014 add preamble (9 steps)
- `.claude/skills/project-plan/SKILL.md` \u2014 add preamble (10 steps)
- `.claude/skills/release-plan/SKILL.md` \u2014 add preamble (8 steps)

## Implementation Steps

1. **Define preamble template** \u2014 Two variants based on context availability:
   - **Issue-aware variant** (skills on feature/fix branches): detect branch, extract issue number, fetch title, display full banner
   - **Minimal variant** (skills without issue context): display skill name, step count, branch only

2. **Insert preamble into all 22 SKILL.md files** \u2014 Place between skill description block and `## STEP 1`. Each gets correct step count and skill name hardcoded.

3. **Verify** \u2014 Grep all SKILL.md files to confirm all 22 have the preamble section.

## Test Cases

- **Happy path**: Run `dev-implement` on a feature branch with an active issue \u2014 verify banner shows skill name, issue number, branch, and step count
- **Edge case**: Run `dev-status` (read-only, no issue context) \u2014 verify banner still displays with available info (skill name only)
- **Error case**: Run a skill with no active branch \u2014 verify banner degrades gracefully (omits branch field rather than erroring)

## Security Considerations

No security-relevant attack surfaces identified for this issue.

## AC Mapping

| AC | How Addressed |
|----|--------------|
| AC-1 | Preamble section added before Step 1 in all 22 skills, displays banner as first output |
| AC-2 | Banner extracts issue number from branch name, fetches title via `gh api`; omits if not applicable |
| AC-3 | Banner reads branch via `git branch --show-current`; omits if not on feature/fix branch |
| AC-4 | Step count hardcoded per skill in the banner display |
| AC-5 | Consistent `\u2500\u2500\u2500\u2500` box-drawing format across all skills, matching SRS FR-02 spec |

## Definition of Done

- [ ] All 22 SKILL.md files contain `## PREAMBLE \u2014 Announcement Banner`
- [ ] Banner format matches SRS FR-02 exactly
- [ ] All ACs checked
