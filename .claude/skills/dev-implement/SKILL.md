---
name: dev-implement
description: Use when implementing confirmed plans — execute steps with code review, commit mode selection, and subagent delegation for independent tasks
---

# dev-implement: Execute Implementation

Execute the implementation doc step-by-step with code review, commit mode selection, and optional subagent delegation.

---

## Resumption

If the user says "continue" or "resume":
1. [READ] `docs/plans/issue-<n>/tasks.md` (or legacy `implementation.md`) → find first task with status `pending`
2. [SHELL] `git status` → check for uncommitted work
3. Resume from that task — never re-do `done` tasks

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
dev-implement | Issue #<number> — <title>
10 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-implement
10 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## RATIONALIZATION PREVENTION

Before executing any step, check your reasoning against this table. These are **structural rules** — they cannot be overridden.

| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "This step is trivial, skip review" | Trivial changes cause subtle bugs — off-by-one, wrong variable, missed import | Run full code review for every step |
| "Tests aren't needed for this change" | Every code change needs verification; untested code is unverified code | Write or run tests as specified |
| "The build will obviously pass" | Build failures catch real issues — type errors, missing deps, broken imports | Run `{config.stack.build_cmd}` every time |
| "I'll commit these steps together" | Atomic commits aid debugging and revert; batching hides which step broke | One commit per step — unless `commit_mode = batch`, in which case G-06's batch grouping logic is authoritative |
| "I already know this works" | Memory is unreliable — verify, don't assume | Run the verification command and read actual output |
| "This is just a config change, no review needed" | Config errors cause silent production failures | Review config changes like code changes |
| "I can skip lint, the code is clean" | Lint catches issues humans miss — formatting, unused vars, import order | Run `{config.stack.lint_cmd}` every time |

---

## VERIFICATION GATE

Before declaring any step `done`, you MUST run the 5-step `[VERIFY]` gate. This is a **structural rule** — it cannot be overridden, skipped, or abbreviated. The gate runs per-step inside Step 7 (see sub-step 7d.1).

**Authoritative definition:** `references/claude-tools.md § [VERIFY] Convention`. Read it once per session.

The gate's contract:
- 5 steps: IDENTIFY → RUN → READ → VERIFY → CLAIM
- Commands must be re-run every time — memory is not evidence
- Output the `GATE: PASS` block with quoted evidence for every claim, or `GATE: FAIL` with unmet items
- Hedging language (`should`, `probably`, `seems to`, `appears to`, `looks like`) auto-restarts the gate from RUN

For PASS / FAIL message formats, see the convention reference.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 10 items, all `pending`:
```
Step 1/10: Load Config
Step 2/10: Load Implementation Doc
Step 3/10: Analyze Task Dependencies
Step 4/10: Choose Execution Path
Step 5/10: Pre-Implementation Check
Step 6/10: Route Execution
Step 7/10: Implementation Loop
Step 8/10: Full Test Run
Step 9/10: Summary
Step 10/10: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/10 `completed`:
```
Step 1/10: Load Config [completed]
Files read: .paadhai.json
```

---

## STEP 2 — Load Implementation Doc

[PROGRESS] Mark Step 2/10 `in_progress`.

[SHELL] Get current branch:
```bash
git branch --show-current
```

Derive issue number from branch.

### Spec artifact load (preferred)

[READ] all three:
- `docs/plans/issue-<n>/requirements.md` — REQ-IDs (used in commit messages and verification)
- `docs/plans/issue-<n>/design.md` — architecture (informs review in Step 7c)
- `docs/plans/issue-<n>/tasks.md` — atomic task groups with `parallel: true|false` flags

Set `spec_format = "new"`.

Total task count = sum of tasks across all groups in tasks.md.

### Legacy fallback

If `tasks.md` does not exist:
1. [READ] `docs/plans/issue-<n>/implementation.md` + `docs/plans/issue-<n>/plan.md`
2. Display LEGACY FORMAT WARNING:
   ```
   ────────────────────────────────────────
   LEGACY PLAN FORMAT DETECTED
   Issue #<n> uses old plan.md + implementation.md format. dev-implement expects tasks.md
   with parallel flags. Auto-routing to dev-parallel will be DISABLED for this run.
   Recommendation: re-run /paadhai:dev-plan to regenerate.
   ────────────────────────────────────────
   ```
3. Set `spec_format = "legacy"`. Total step count = rows in implementation.md progress table.

### Display

```
Issue       : #<number> <title>
Branch      : <branch-name>
Spec format : <new | legacy>
Tasks       : <total count> across <group count> groups (new) | <total count> steps (legacy)
Parallel    : <count of parallel-flagged groups> (new format only)
```

Ask user:
- Model preference? (fast / smart / auto)

Present commit mode selection using AskUserQuestion:

**Prompt text:** "Implementation has <total task count> tasks. How would you like to handle commits?"

**Options:**
| Label | Description |
|-------|-------------|
| Per-task (Recommended) | Approve each commit individually (current behavior) |
| Auto-commit | Commit automatically after each passing task |
| Batch | Commit at group boundaries (one commit per group) |

Store the selection as `commit_mode` (`per-step` | `auto-commit` | `batch`) for use by G-06.

In `batch` mode with `spec_format = "new"`, group boundaries come directly from tasks.md `### Group N` headings — overriding the `step.group_metadata` and path-prefix heuristics.

[PROGRESS] Mark Step 2/10 `completed`.

---

## STEP 3 — Analyze Task Dependencies

[PROGRESS] Mark Step 3/10 `in_progress`.

### When `spec_format = "new"` (tasks.md present)

Read `parallel:` flag and `depends_on:` field from each group in tasks.md. Build:
- Group dependency graph (DAG)
- Parallel-eligible group set (`parallel: true`)
- Sequential-only group set (`parallel: false`)

Display:
```
Task Group Analysis
═══════════════════════════════════════
Group | Tasks | parallel | depends_on
──────┼───────┼──────────┼─────────────
  1   | 3     | false    | none
  2   | 4     | true     | Group 1
  3   | 2     | false    | Group 2
```

If ANY group has `parallel: true` → auto-routing is **available**. If all groups have `parallel: false` → sequential only.

### When `spec_format = "legacy"`

Auto-routing disabled. Continue with the original heuristic:
- **Sequential patterns**: step B requires step A's output
- **Independent patterns**: steps with no shared state

[PROGRESS] Mark Step 3/10 `completed`.

---

## STEP 4 — Choose Execution Path

[PROGRESS] Mark Step 4/10 `in_progress`.

### When `spec_format = "new"` and at least one group is `parallel: true`

Offer:
1. **Auto-route** (recommended): sequential groups run inline; parallel-flagged groups dispatch to `/paadhai:dev-parallel` automatically
2. **All sequential**: ignore parallel flags; run every group inline

Display the group analysis and ask user to choose. Default: auto-route.

### When `spec_format = "new"` and all groups are `parallel: false`

Sequential only — proceed automatically. No prompt needed.

### When `spec_format = "legacy"`

Original behavior:
- **Independent-heavy** → offer: subagent-driven OR sequential
- **Sequential-heavy** → sequential only
- **Mixed** → offer choice

Store choice as `execution_mode` ∈ `{auto-route, sequential}`.

[PROGRESS] Mark Step 4/10 `completed`.

---

## STEP 5 — Pre-Implementation Check

[PROGRESS] Mark Step 5/10 `in_progress`: `Step 5/10: Pre-Implementation Check [in_progress]`

[SHELL] Verify branch and working state:
```bash
git branch --show-current
git status
```

- Must be on feature branch (not `{config.repo.develop_branch}` or `main`)
- Working tree must be clean (or stash uncommitted work first)

[PROGRESS] Mark Step 5/10 `completed`: `Step 5/10: Pre-Implementation Check [completed]`
`Branch verified, working tree clean`

---

## STEP 6 — Route Execution

[PROGRESS] Mark Step 6/10 `in_progress`.

### When `execution_mode == "auto-route"` (new format)

Iterate over groups in dependency order:

```
FOR each group in tasks.md (topologically sorted by depends_on):
  Wait for all groups in `depends_on` to complete.

  IF group.parallel == true:
    → Dispatch to /paadhai:dev-parallel
       Pass: PAADHAI_CALLER=dev-implement, PAADHAI_GROUP_ID=<group-name>, issue number
       dev-parallel handles only this single group, returns commit SHA + status
    → Wait for completion. On FAIL → escalate to user.
  ELSE:
    → Execute group's tasks sequentially via Step 7 (Implementation Loop)
       on this agent.

  Update tasks.md: mark group's tasks `done`.
END FOR
```

### When `execution_mode == "sequential"` or `spec_format == "legacy"`

Run all tasks/steps inline via Step 7 (no auto-routing).

[PROGRESS] Mark Step 6/10 `completed`.

---

## STEP 7 — Implementation Loop

[PROGRESS] Mark Step 7/10 `in_progress`: `Step 7/10: Implementation Loop [in_progress]`

For each `pending` step in the implementation doc:

### 7a — Read Before Modifying
[READ] all files that will be modified in this step.

### 7b — Implement
[DELEGATE] Execute the step (model per user choice in Step 2). Follow the exact command/code in the implementation doc.

### 7c — Code Review
[READ] `code-reviewer-prompt.md` — load review criteria.
[DELEGATE][SMART-MODEL] Review changes using the loaded reviewer prompt. Check:
- Correctness
- Pattern alignment with existing code
- No introduced bugs or security issues

**PASS/FAIL.** Skip for: config changes, docs, dependency bumps. Fix until PASS.

### 7d — Build + Lint
[SHELL] (skip if no source files changed):
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
```

Fix failures before proceeding.

### 7d.1 — Verification Gate

Run the 5-step VERIFICATION GATE (defined in the `## VERIFICATION GATE` section at the top of this file) before marking this step `done`.

- **Inputs to the gate**: the exact output from 7d's `{config.stack.build_cmd}` and `{config.stack.lint_cmd}`, plus any test command output for this step. Output must be fresh — re-run if you do not have it captured.
- **Docs-only step**: if 7d was skipped (no source files changed), run `{config.stack.lint_cmd}` (if available) or the relevant content-verification command (`Read`/`Grep`) and quote its output.
- **On PASS**: proceed to 7e.
- **On FAIL**: do not proceed to 7e. Do not commit. Fix the unmet items listed by the gate and re-run the gate from step 2 (RUN).
- **Hedging auto-retrigger**: if your CLAIM contains `should`, `probably`, `seems to`, `I believe`, or lacks a quoted output block, restart the gate from RUN before proceeding.

### 7e — Update Implementation Doc
[WRITE] Mark step as `done` in implementation doc. Add deviation note if step differed from plan.

### 7f — Step Summary + Gate
Display:
```
Step <n> complete
Files changed : <list>
Build         : ✓ / ✗
Lint          : ✓ / ✗
Code review   : PASS / SKIP
```

**G-06** branches on `commit_mode`:

- **`per-step`** → wait for explicit user approval before committing (unchanged).
- **`auto-commit` — pass path** → if build (7d), lint (7d), code review (7c), and verification gate (7d.1) all PASS, commit automatically using 7g with no approval prompt. Unconfigured check commands (empty `{config.stack.build_cmd}` or `{config.stack.lint_cmd}`) are treated as non-blocking: the matching check is skipped, not failed.
- **`auto-commit` — fail path** → on any FAIL (build, lint, code review, or verification gate), do **not** commit. Flip `commit_mode` from `auto-commit` to `per-step` for the remainder of the session, display the MODE SWITCH banner below, then fall through to per-step G-06 for this failing step once the developer has fixed the issue and re-run the relevant gates. Once flipped, `commit_mode` stays `per-step` for every subsequent step in this session — it does not flip back.
- **`batch`** → group steps by logical concern and commit at group boundaries rather than per step. Semantics:
  - **Group-key computation**: for each step, `group_key = step.group_metadata` if a `**Group:** <slug>` header is present on the step, else the first 2 path segments of the step's primary file (the first-listed file in its "Files" / modified-files section).
  - **Group boundaries**: a group closes when the next step's `group_key` differs, or the implementation reaches its final step.
  - **Group pass path**: on group close, if every member step's 7c (code review), 7d (build + lint), and 7d.1 (verification gate) all PASS, commit the whole group using 7g with the batch commit message format below. No approval prompt.
  - **Group fail path**: if any member step FAILs (build, lint, code review, verification gate, or pre-commit hook), the group is **not committed**. Display the BATCH BROKEN banner below, flip `commit_mode` from `batch` to `per-step` for the remainder of the session, then fall through to per-step G-06 for the failing step once the developer has fixed the issue and re-run the relevant gates. Uncommitted changes from earlier group-members remain on disk and are handled via per-step G-06 from that point forward — the developer decides per commit what to include. Once flipped, `commit_mode` stays `per-step` for every subsequent step in this session — it does not flip back.
  - **Edge case — size-1 groups**: when a step's `group_key` differs from both neighbors, its group has size 1; it still commits silently in batch mode (no approval prompt). Mode remains `batch`.
  - **`--no-verify` forbidden**: batch commits use the same `git commit` invocation as per-step (see 7g safeguard). Pre-commit hook failure → BATCH BROKEN banner with reason `hook`.
  - **Batch commit message format** (deferred in actual invocation to 7g):
    ```
    <type>(<scope>): <group-name> — <N> steps

    - Step <N1>: <description>
    - Step <N2>: <description>
    …

    Refs #<issue-number>
    ```
    Subject: max 72 chars, imperative mood. `<type>` selected per 7g's commit-type table based on the group's dominant change kind.

MODE SWITCH banner (displayed on `auto-commit` fail path, immediately before per-step G-06 re-engages):

```
────────────────────────────────────────
MODE SWITCH: auto-commit → per-step
Reason: <build | lint | review | gate> failed on step <N>
All remaining steps will use per-step approval.
────────────────────────────────────────
```

BATCH BROKEN banner (displayed on `batch` fail path, immediately before per-step G-06 re-engages):

```
────────────────────────────────────────
BATCH BROKEN: batch → per-step
Reason: <build | lint | review | gate | hook> failed on step <N> (group <G>)
Group <G> not committed. All remaining steps will use per-step approval.
────────────────────────────────────────
```

### 7g — Commit
[SHELL] Commit specific files (not `git add -A`):
```bash
git add <specific-files-changed>
git commit -m "<type>(<scope>): <subject>

<optional body>

Refs #<number>"
```

Commit type guide:
| Type | When |
|------|------|
| `feat` | New functionality |
| `fix` | Bug fix |
| `test` | Test only |
| `chore` | Deps, config |
| `refactor` | Restructure, no behavior change |
| `docs` | Documentation |
| `perf` | Performance improvement |

Subject: max 72 chars, imperative mood ("add X" not "added X").

Auto-commit uses the same `git commit` invocation as per-step — `--no-verify` is never used. If a pre-commit hook fails, treat it as a step failure: the commit aborts, the MODE SWITCH banner displays with reason `hook`, `commit_mode` flips to `per-step`, and G-06 re-engages for the failing step.

### 7h — Progress Dashboard
After each step's commit, display a compact aggregate progress dashboard. Data MUST come from actual command output — never estimate or fabricate values.

[SHELL] Gather cumulative stats:
```bash
# Count commits on this branch since diverging from develop
COMMIT_COUNT=$(git rev-list {config.repo.develop_branch}..HEAD --count)

# Count created (A) and modified (M) files since diverging from develop
CREATED=$(git diff --name-status {config.repo.develop_branch}...HEAD | grep -c '^A')
MODIFIED=$(git diff --name-status {config.repo.develop_branch}...HEAD | grep -c '^M')
TOTAL_FILES=$((CREATED + MODIFIED))
```

Compute progress bar:
- Let `DONE` = number of implementation steps completed so far (including this one)
- Let `TOTAL` = total number of implementation steps
- Let `PCT` = `DONE * 100 / TOTAL`
- Filled chars = `DONE * 12 / TOTAL` (integer division), using `█`
- Empty chars = `12 - filled`, using `░`

Determine test and build status:
- **Build**: Use the result from the most recent 7d execution. If 7d was skipped for this step (no source files changed), use the last known build result. If no build has run yet, show `not yet run`.
- **Tests**: Use the result from the most recent `{config.stack.test_cmd}` execution (typically Step 8). If no test command has run yet, show `not yet run`.

Display:
```
Progress: ████████░░░░ <DONE>/<TOTAL> steps (<PCT>%)
══════════════════════════════════════════
Files changed : <TOTAL_FILES> (<CREATED> created, <MODIFIED> modified)
Commits       : <COMMIT_COUNT>
Tests         : <passing> passing, <failing> failing | not yet run
Build         : passing | failing | not yet run
══════════════════════════════════════════
```

**Constraints:**
- Maximum 6 lines excluding the `══` border lines (AC-4)
- Progress bar is always 12 characters wide (AC-3)
- All values derived from actual `git diff`, `git rev-list`, and command output — never from agent estimation (AC-5)

**Edge cases:**
- First step completed with no prior changes: show `0` for files/commits, `not yet run` for tests/build
- Step where build/lint was skipped (no source files): show last known build status
- Build or test failure: show `failing`, not `passing`

[PROGRESS] Mark Step 7/10 `completed`: `Step 7/10: Implementation Loop [completed]`
`Files changed: <list from step>  Build: ✓  Lint: ✓`

---

## STEP 8 — Full Test Run

[PROGRESS] Mark Step 8/10 `in_progress`: `Step 8/10: Full Test Run [in_progress]`

[SHELL] After all steps complete:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

Fix any failures before proceeding. Do not skip.

[PROGRESS] Mark Step 8/10 `completed`: `Step 8/10: Full Test Run [completed]`
`Build: ✓  Lint: ✓  Tests: <count> passing`

---

## STEP 9 — Summary

[PROGRESS] Mark Step 9/10 `in_progress`: `Step 9/10: Summary [in_progress]`

Display:
```
Implementation complete

Issue   : #<number> <title>
Commits : <count>
Build   : ✓
Lint    : ✓
Tests   : <pass count> passing
```

[PROGRESS] Mark Step 9/10 `completed`: `Step 9/10: Summary [completed]`
`Output displayed`

---

## STEP 10 — Handoff

[PROGRESS] Mark Step 10/10 `in_progress`: `Step 10/10: Handoff [in_progress]`

```
Run /dev-pr to push the branch and open a pull request.

Branch  : <branch-name>
Issue   : #<number>
```

[PROGRESS] Mark Step 10/10 `completed`: `Step 10/10: Handoff [completed]`
`Output displayed`
