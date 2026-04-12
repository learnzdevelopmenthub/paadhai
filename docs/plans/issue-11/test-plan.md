---
issue: 11
title: Add rationalization prevention tables to dev-implement, dev-plan, dev-parallel
branch: feature/11-rationalization-prevention-tables
type: manual-verification
---

## Test Plan — Issue #11: Add rationalization prevention tables

### Test Framework: Manual verification (read-based)

This is a documentation-only change. There is no runtime code, no test framework, and no executable tests. Verification is done by reading the modified files and checking structural requirements.

### Test Cases

#### Happy Path

| # | AC | Type | Description | Input | Expected |
|---|---|----|-------------|-------|----------|
| 1 | AC-1 | verify | Tables present in all 3 files | Read `dev-implement/SKILL.md` | Contains `## RATIONALIZATION PREVENTION` section |
| 2 | AC-1 | verify | Tables present in all 3 files | Read `dev-plan/SKILL.md` | Contains `## RATIONALIZATION PREVENTION` section |
| 3 | AC-1 | verify | Tables present in all 3 files | Read `dev-parallel/SKILL.md` | Contains `## RATIONALIZATION PREVENTION` section |
| 4 | AC-2 | verify | Each table has >=5 entries | Count table rows in each file | >= 5 data rows per table |
| 5 | AC-3 | verify | Tables before STEP 1 | Check section order in each file | `## RATIONALIZATION PREVENTION` appears before `## STEP 1` |
| 6 | AC-4 | verify | 3-column format | Check table headers | Headers: `Thought | Why it's wrong | What to do` |

#### Edge Cases

| # | AC | Type | Description | Input | Expected |
|---|---|----|-------------|-------|----------|
| 7 | AC-2 | verify | Entries cover code changes | Read table entries | At least one entry about code-change rationalization per file |
| 8 | AC-2 | verify | Entries cover verification steps | Read table entries | At least one entry about verification-skip rationalization per file |
| 9 | AC-2 | verify | Tables are skill-specific | Compare tables across files | Tables differ — tailored to each skill's failure modes |

#### Error / Failure Cases

| # | AC | Type | Description | Input | Expected |
|---|---|----|-------------|-------|----------|
| — | — | — | N/A — documentation-only change | — | — |

### Coverage Target

- N/A — no executable code
