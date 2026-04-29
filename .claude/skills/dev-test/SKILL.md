---
name: dev-test
description: Use when creating a test plan and stubs before implementation — derive test cases from ACs, generate test file stubs
---

# dev-test: Test Strategy

Generate a test plan from acceptance criteria and write test file stubs before implementation begins.

**Output:** `docs/plans/issue-<n>/test-plan.md` + test stub files

---

## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

If branch matches `feature/*` or `fix/*`:
- Extract issue number from branch name (e.g., `feature/42-add-login` → `42`)
- [SHELL] Fetch issue title:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> --jq '.title'
```

Display (with issue context):
```
────────────────────────────────────────
dev-test | Issue #<number> — <title>
11 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-test
11 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.stack.test_cmd}`
- `{config.stack.build_cmd}`
- `{config.repo.owner}` / `{config.repo.name}`

---

## STEP 2 — Load Issue Context

[SHELL] Get current branch:
```bash
git branch --show-current
```

Derive issue number from branch name (e.g., `feature/42-add-login` → `#42`).

### Spec artifact load (preferred)

[READ] `docs/plans/issue-<n>/requirements.md` — EARS acceptance criteria with stable REQ-IDs.
[READ] `docs/plans/issue-<n>/tasks.md` — implementation scope (informs which files will need test coverage).

Extract all REQ-IDs from requirements.md. These IDs become the **trace anchor** between requirements, tests, and implementation.

### Legacy fallback

If `requirements.md` does not exist:
1. [READ] `docs/plans/issue-<n>/plan.md` (legacy single-doc format)
2. Display warning:
   ```
   ────────────────────────────────────────
   LEGACY PLAN FORMAT DETECTED
   Issue #<n> uses the old plan.md format. dev-test expects three-artifact schema:
   - requirements.md (EARS acceptance criteria with REQ-IDs)
   - design.md (architecture)
   - tasks.md (atomic tasks with parallel flags)

   Recommendation: re-run /paadhai:dev-plan to regenerate. Continuing with legacy format
   for this run; test plan will use AC-N IDs from plan.md instead of REQ-IDs.
   ────────────────────────────────────────
   ```
3. Extract acceptance criteria as `AC-1`, `AC-2`, … from plan.md.

[SHELL] Fetch issue body for context:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> \
  --jq '{number: .number, title: .title, labels: [.labels[].name], body: .body}'
```

Display:
```
Issue       : #<number> <title>
Spec format : <new (requirements.md) | legacy (plan.md)>
IDs found   : <count> (REQ-1..N or AC-1..N)
```

---

## STEP 3 — Analyze Test Requirements

[DELEGATE][FAST-MODEL] Scan the codebase to detect:
- Test framework in use (Jest, Pytest, Vitest, RSpec, Go test, etc.)
- Test file naming conventions (e.g., `*.test.ts`, `*_test.go`, `test_*.py`)
- Test directory structure (`__tests__/`, `tests/`, `spec/`)
- Coverage tools available (nyc, coverage.py, tarpaulin, etc.)
- Existing test patterns and assertion styles

Store findings for use in Step 4 and Step 7.

---

## STEP 4 — Generate Test Plan

For each REQ-ID (or AC-N in legacy mode) from Step 2, define:
- **Test type**: unit / integration / e2e
- **REQ ID**: the stable ID this test verifies (REQ-1, REQ-2, ...)
- **Description**: what is being tested (drawn directly from EARS language)
- **Input**: test input / setup
- **Expected output**: expected behavior / assertion
- **Coverage target**: 80% line coverage on new code

Group test cases by:
1. Happy path tests
2. Edge case tests
3. Error / failure tests

**Coverage check:** every REQ-ID from requirements.md must appear in at least one row. Flag any REQ-ID with zero test coverage as a gap before proceeding.

Format (use `REQ` column for new format, `AC` column when in legacy fallback):
```
## Test Plan — Issue #<number>: <title>

### Test Framework: <detected-framework>

### Trace Anchor
Each test cites the REQ-ID it verifies. REQ coverage:
- REQ-1: <test count>
- REQ-2: <test count>
- <REQ-N with 0 tests>: GAP — needs coverage

### Test Cases

#### Happy Path
| # | REQ | Type | Description | Input | Expected |
|---|-----|------|-------------|-------|---------|
| 1 | REQ-1 | unit | <desc> | <input> | <expected> |

#### Edge Cases
| # | REQ | Type | Description | Input | Expected |
|---|-----|------|-------------|-------|---------|

#### Error / Failure Cases
| # | REQ | Type | Description | Input | Expected |
|---|-----|------|-------------|-------|---------|

### Coverage Target
- New code: 80% line coverage
- Critical paths: 100% branch coverage
- All REQ-IDs from requirements.md addressed
```

---

## STEP 5 — Present Test Plan

Show the full test plan.

**G-17: "Approve this test plan? (yes / list changes)"**

Wait for explicit approval.

---

## STEP 6 — Revision Loop

- **Approved** → proceed to Step 7
- **Changes requested** → update test plan → re-present (repeat Step 5)

---

## STEP 7 — Write Test Stubs

[DELEGATE][FAST-MODEL] Create test stub files following detected conventions from Step 3.

For each test file:
- Create describe/it (or equivalent) blocks for every test case
- Add TODO comments for assertion logic
- Use placeholder assertions that will be pending/skipped (not failing)
- Import the module under test (even if not yet implemented)

Example stub (Jest/TypeScript):
```typescript
describe('<feature>', () => {
  describe('happy path', () => {
    it('should <AC-1 description>', () => {
      // TODO: implement
      expect(true).toBe(true); // placeholder
    });
  });

  describe('edge cases', () => {
    it('should handle <edge case>', () => {
      // TODO: implement
      expect(true).toBe(true); // placeholder
    });
  });
});
```

---

## STEP 8 — Save Test Plan

[WRITE] `docs/plans/issue-<n>/test-plan.md` with the full test plan from Step 4 (approved version).

---

## STEP 9 — Verify Stubs Compile

[SHELL] Run build + test to confirm stubs are valid (pending/skipped, not errors):
```bash
{config.stack.build_cmd}
{config.stack.test_cmd}
```

If build fails → fix import errors or syntax issues in stubs (do NOT implement logic).
If tests fail unexpectedly → check placeholder assertions — they must not be actual failures.

---

## STEP 10 — Commit

[SHELL] Commit test plan and stubs:
```bash
git add docs/plans/issue-<n>/test-plan.md <test-stub-files>
git commit -m "test(plan): add test plan and stubs for issue #<n>

<count> test cases across <happy/edge/error> categories.

Refs #<n>"
```

---

## STEP 11 — Handoff

```
Test plan ready. Next step: run /paadhai:dev-implement.

Issue       : #<number> <title>
Test plan   : docs/plans/issue-<n>/test-plan.md
Stubs       : <list of stub files>
Test cases  : <count> (<happy> happy / <edge> edge / <error> error)
REQ coverage: <covered>/<total> REQ-IDs from requirements.md
Gate passed : G-17
```
