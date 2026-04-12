---
issue: 13
title: Add verification gate to dev-parallel and document in claude-tools.md
branch: feature/13-add-verification-gate-dev-parallel
---

# Implementation Doc — Issue #13

## Progress Table

| Step | Description | Status |
|------|-------------|--------|
| 1 | Add `[VERIFY]` marker row to claude-tools.md table | done |
| 2 | Add `## [VERIFY] Convention` section to claude-tools.md | done |
| 3 | Commit 1 — docs(claude-tools) | done |
| 4 | Add 2 rationalization rows to dev-parallel | done |
| 5 | Update preamble step count 14 → 15 | done |
| 6 | Update Step 1 TodoWrite checklist (14 → 15 items) | done |
| 7 | Update Step 4 subagent prompt (new rules + report format) | done |
| 8 | Insert new Step 8 — Validate Subagent Reports | done |
| 9 | Renumber old Steps 8–14 to 9–15 | done |
| 10 | Commit 2 — feat(dev-parallel) | done |

---

## Step 1 — Add `[VERIFY]` marker row to claude-tools.md table

**File:** `references/claude-tools.md`

**Tool:** `Edit`

**Find** (exact text, lines 16–17):
```
| `[PROGRESS]` | `TodoWrite` tool | Create and update a live step checklist. Graceful degradation: skip if TodoWrite unavailable |

## Subagent Support
```

**Replace with:**
```
| `[PROGRESS]` | `TodoWrite` tool | Create and update a live step checklist. Graceful degradation: skip if TodoWrite unavailable |
| `[VERIFY]` | Inline text inspection | Run the 5-step verification gate before claiming a task complete. See `## [VERIFY] Convention` below. |

## Subagent Support
```

**Expected output:** Edit succeeds. File now has a `[VERIFY]` row after `[PROGRESS]`.

**Verification command:**
```bash
grep -n "\[VERIFY\]" references/claude-tools.md
```

**Expected verification output:** At least one line showing `| \`[VERIFY]\` | Inline text inspection |`.

---

## Step 2 — Add `## [VERIFY] Convention` section to claude-tools.md

**File:** `references/claude-tools.md`

**Tool:** `Edit`

**Find** (exact text — the final section of the file, lines 70–71):
```
If the TodoWrite tool is unavailable, skip all `[PROGRESS]` calls silently and continue execution. Never block on progress tracking.
```

**Replace with:**
```
If the TodoWrite tool is unavailable, skip all `[PROGRESS]` calls silently and continue execution. Never block on progress tracking.

## [VERIFY] Convention

`[VERIFY]` marks a mandatory 5-step verification gate that must run before a skill (or subagent) declares a task complete. The gate produces quoted command output as evidence, so a reviewer can confirm the claim without re-running the commands.

**Commands must be re-run every time — results cannot be recalled from memory.** Memory is unreliable; the only acceptable evidence is fresh command output captured during this gate run.

### The 5 steps

1. **IDENTIFY** — What specific claims am I about to make about this task? List each one (e.g., "tests pass", "build succeeds", "file X contains Y").
2. **RUN** — Execute the verification command(s) for each claim: `{config.stack.build_cmd}`, `{config.stack.lint_cmd}`, `{config.stack.test_cmd}`, or a `Read`/`Grep` for content claims. Do not reuse output from an earlier run.
3. **READ** — Read the ACTUAL output of each command. Do not summarize from memory. Do not paraphrase.
4. **VERIFY** — For each claim from IDENTIFY, check the output line-by-line. Does the output literally confirm the claim?
5. **CLAIM** — Only now may you state the task is complete. Every claim must be followed by a quoted block of the exact output that proves it.

### Red flags — restart the gate from RUN

If your CLAIM message contains any of the following, you MUST restart from step 2 (RUN):

- Hedging words: `should`, `probably`, `seems to`, `I believe`, `appears to`, `looks like`
- No quoted command output block for a claim
- Claims without a specific file path + line reference (for content claims)
- Output quoted from an earlier task or earlier gate run (must be fresh)

### Edge case — docs-only task

If no source files changed, the gate still runs: execute `{config.stack.lint_cmd}` (if available) or the relevant `Read`/`Grep` command to verify the docs claim, and quote that output in CLAIM.

### PASS format

```
GATE: PASS

Claims verified:
1. <claim>
   Evidence:
   ```
   <quoted command output>
   ```
2. <claim>
   Evidence:
   ```
   <quoted command output>
   ```
```

### FAIL format

If any claim cannot be verified, the gate FAILS and the task stays `pending`. Do not proceed. Do not commit.

```
GATE: FAIL

Unmet items:
1. Claim "<claim>" — <reason, e.g., "no output quoted", "output shows 2 failures", "hedging language used">
2. Claim "<claim>" — <reason>

Next action: fix the missing evidence above and re-run the gate from step 2 (RUN).
```

### Usage across skills

- **`dev-implement`** applies the gate per-step inside its implementation loop (§ VERIFICATION GATE in that skill's SKILL.md).
- **`dev-parallel`** requires each subagent to run the gate on its own work and include the PASS block in its report. The orchestrator validates the report structure (Step 8 of dev-parallel) before accepting results.
- **Future skills** may reference this convention by writing `[VERIFY] Run the gate before declaring <task> complete` in the relevant step.
```

**Expected output:** Edit succeeds. File now ends with a full `## [VERIFY] Convention` section.

**Verification command:**
```bash
grep -n "## \[VERIFY\] Convention" references/claude-tools.md
grep -c "IDENTIFY\|RUN\|READ\|VERIFY\|CLAIM" references/claude-tools.md
```

**Expected verification output:** First command shows the section header line. Second command shows a count ≥ 5 (the 5 gate step names).

---

## Step 3 — Commit 1

**Tool:** `Bash`

**Commands:**
```bash
git add references/claude-tools.md
git status
git commit -m "docs(claude-tools): add [VERIFY] marker and convention

Add [VERIFY] to the capability marker table and a full ## [VERIFY]
Convention section documenting the 5-step verification gate, red-flag
list, PASS/FAIL formats, and cross-skill usage notes. This makes the
verification gate a reusable pattern for future skills.

Refs #13"
```

**Expected output:** `git status` shows only `references/claude-tools.md` staged. Commit succeeds with 1 file changed.

**Verification command:**
```bash
git log -1 --stat
```

**Expected verification output:** Latest commit is `docs(claude-tools): add [VERIFY] marker and convention`, 1 file changed, `references/claude-tools.md` only.

---

## Step 4 — Add 2 rationalization rows to dev-parallel

**File:** `.claude/skills/dev-parallel/SKILL.md`

**Tool:** `Edit`

**Find** (exact text, line 58, the last row of the rationalization table):
```
| "The task grouping is obvious, no need to analyze" | Poor grouping creates coupling between subagents and merge nightmares | Analyze dependencies and group carefully (Step 2) |
```

**Replace with:**
```
| "The task grouping is obvious, no need to analyze" | Poor grouping creates coupling between subagents and merge nightmares | Analyze dependencies and group carefully (Step 2) |
| "Subagent said GATE: PASS, I can trust it without inspecting" | The gate block can be fabricated; evidence must be present and well-formed | Always inspect each report for quoted evidence per claim (Step 8) |
| "One missing claim isn't worth a re-dispatch" | Partial evidence = no evidence; skipping the re-dispatch normalizes missing claims | Reject the report and re-dispatch verify-only (Step 8) |
```

**Expected output:** Edit succeeds. Rationalization table now has 9 rows instead of 7.

**Verification command:**
```bash
grep -c "^| \"" .claude/skills/dev-parallel/SKILL.md
```

**Expected verification output:** Count should be 9 (7 original + 2 new rationalization rows).

---

## Step 5 — Update preamble step count 14 → 15

**File:** `.claude/skills/dev-parallel/SKILL.md`

**Tool:** `Edit` with `replace_all: true`

**Find:**
```
14 steps | Branch: <branch>
```

**Replace with:**
```
15 steps | Branch: <branch>
```

**Expected output:** Edit succeeds, 2 replacements (both banner variants).

**Verification command:**
```bash
grep -n "14 steps\|15 steps" .claude/skills/dev-parallel/SKILL.md
```

**Expected verification output:** Zero lines matching `14 steps`. Two lines matching `15 steps`.

---

## Step 6 — Update Step 1 TodoWrite checklist (14 → 15 items)

**File:** `.claude/skills/dev-parallel/SKILL.md`

**Tool:** `Edit`

**Find** (exact text, the current checklist block inside Step 1):
```
[PROGRESS] Initialize TodoWrite checklist — 14 items, all `pending`:
```
Step 1/14: Load Config
Step 2/14: Load Implementation Doc
Step 3/14: Group Independent Tasks
Step 4/14: Generate Subagent Prompts
Step 5/14: Dispatch Gate
Step 6/14: Dispatch Subagents (after G-11)
Step 7/14: Collect Results
Step 8/14: Stage 1: Spec Compliance Review
Step 9/14: Stage 2: Code Quality Review
Step 10/14: Fix Loop
Step 11/14: Update Implementation Doc
Step 12/14: Full Test Run
Step 13/14: Summary
Step 14/14: Handoff
```
```

**Replace with:**
```
[PROGRESS] Initialize TodoWrite checklist — 15 items, all `pending`:
```
Step 1/15: Load Config
Step 2/15: Load Implementation Doc
Step 3/15: Group Independent Tasks
Step 4/15: Generate Subagent Prompts
Step 5/15: Dispatch Gate
Step 6/15: Dispatch Subagents (after G-11)
Step 7/15: Collect Results
Step 8/15: Validate Subagent Reports
Step 9/15: Stage 1: Spec Compliance Review
Step 10/15: Stage 2: Code Quality Review
Step 11/15: Fix Loop
Step 12/15: Update Implementation Doc
Step 13/15: Full Test Run
Step 14/15: Summary
Step 15/15: Handoff
```
```

Also find (lines 93–97, the step-1 completion marker):
```
[PROGRESS] Mark Step 1/14 `completed`:
```
Step 1/14: Load Config [completed]
Files read: .paadhai.json
```
```

Replace with:
```
[PROGRESS] Mark Step 1/15 `completed`:
```
Step 1/15: Load Config [completed]
Files read: .paadhai.json
```
```

**Expected output:** Both edits succeed.

**Verification command:**
```bash
grep -c "Step 8/15: Validate Subagent Reports" .claude/skills/dev-parallel/SKILL.md
```

**Expected verification output:** `1` (the new item appears exactly once in the initial checklist).

---

## Step 7 — Update Step 4 subagent prompt (new rules + report format)

**File:** `.claude/skills/dev-parallel/SKILL.md`

**Tool:** `Edit`

**Find** (exact text, Step 4's rules list, lines 170–176):
```
5. **Rules**:
   - `[READ]` every file before modifying it
   - `git add <specific-files>` — never `git add -A`
   - Run `{config.stack.build_cmd}` and `{config.stack.lint_cmd}` after changes
   - Mark each step as `done` in implementation.md after completion
6. **Report format**: files changed, build status, lint status, commit SHA
```

**Replace with:**
```
5. **Rules**:
   - `[READ]` every file before modifying it
   - `git add <specific-files>` — never `git add -A`
   - Run `{config.stack.build_cmd}` and `{config.stack.lint_cmd}` after changes
   - Mark each step as `done` in implementation.md after completion
   - **Before reporting, run the `[VERIFY]` gate defined in `references/claude-tools.md § [VERIFY] Convention`.** Your report MUST end with a `GATE: PASS` block containing quoted command output for every claim. Reports without this block will be rejected by the orchestrator and re-dispatched.
6. **Report format**:
   ```
   ## Report

   Files changed : <list>
   Commit SHA    : <sha>

   ## [VERIFY] Gate

   GATE: PASS

   Claims verified:
   1. Build succeeds
      Evidence:
      ```
      <quoted output of {config.stack.build_cmd}>
      ```
   2. Lint clean
      Evidence:
      ```
      <quoted output of {config.stack.lint_cmd}>
      ```
   3. Assigned step(s) marked `done` in implementation.md
      Evidence:
      ```
      <quoted grep/read output showing "status: done" for each assigned step>
      ```
   ```
```

**Expected output:** Edit succeeds. Step 4 now has the `[VERIFY]` rule and the new report format.

**Verification command:**
```bash
grep -n "\[VERIFY\] gate defined in" .claude/skills/dev-parallel/SKILL.md
```

**Expected verification output:** One line showing the new rule inside Step 4.

---

## Step 8 — Insert new Step 8 — Validate Subagent Reports

**File:** `.claude/skills/dev-parallel/SKILL.md`

**Tool:** `Edit`

**Find** (exact text — the boundary between old Step 7 closing and old Step 8 opening, lines 248–253):
```
[PROGRESS] Mark Step 7/14 `completed`: `Step 7/14: Collect Results [completed]`
`Results collected`

---

## STEP 8 — Stage 1: Spec Compliance Review
```

**Replace with:**
```
[PROGRESS] Mark Step 7/15 `completed`: `Step 7/15: Collect Results [completed]`
`Results collected`

---

## STEP 8 — Validate Subagent Reports

[PROGRESS] Mark Step 8/15 `in_progress`: `Step 8/15: Validate Subagent Reports [in_progress]`

Every subagent report MUST pass the `[VERIFY]` structural validation before the orchestrator accepts it. The orchestrator does NOT re-run verification commands — it inspects the report text for evidence produced by the subagent's own gate run (defined in `references/claude-tools.md § [VERIFY] Convention`).

### Validation checks (text inspection, inline — no subagent delegation)

For each subagent report:

1. **Presence** — Does the report contain a `GATE: PASS` block?
   - If no → **REJECT**: missing gate

2. **Evidence** — For each claim listed under `Claims verified:`, is there a fenced code block containing command output directly beneath it?
   - If any claim lacks a fenced evidence block → **REJECT**: claim "<X>" has no quoted evidence

3. **Hedging** — Does the report contain any red-flag language (outside of fenced code blocks)?
   Red flags: `should`, `probably`, `seems to`, `I believe`, `appears to`, `looks like`
   - If any red flag appears in prose → **REJECT**: hedging in "<quoted sentence>"

### On REJECT → verify-only re-dispatch

[DELEGATE][FAST-MODEL] Dispatch a new subagent (same task group), with a narrower prompt:

```
The previous subagent for group <N> produced a report that failed [VERIFY] validation.
Reason: <reject reason>

Previous report:
<quoted bad report>

Your task: verify-only. Do NOT modify code — the work is already committed.
1. [READ] the files listed in "Files changed" of the previous report
2. Run {config.stack.build_cmd}, {config.stack.lint_cmd}, and {config.stack.test_cmd} (if applicable) against the current state
3. Produce a new report with a well-formed GATE: PASS block including quoted command output for every claim
4. Do NOT use hedging language
```

### Retry cap + escalation

- **1 retry** per group.
- If the verify-only re-dispatch ALSO fails validation → stop and escalate to the user:

```
Subagent for group <N> failed verification twice.

Last report:
<quoted bad report>

Reject reason: <reason>

Options:
  retry  — dispatch a third verify-only subagent
  manual — you fix and re-run the gate yourself
  abort  — stop dev-parallel, leave work in place
```

Wait for explicit user choice. Do not proceed without it.

### On all reports PASS

Proceed to Step 9 (Stage 1: Spec Compliance Review).

[PROGRESS] Mark Step 8/15 `completed`: `Step 8/15: Validate Subagent Reports [completed]`
`All reports passed [VERIFY] validation`

---

## STEP 9 — Stage 1: Spec Compliance Review
```

**Expected output:** Edit succeeds. A new full STEP 8 section exists between Collect Results and Stage 1 Spec Compliance Review.

**Verification command:**
```bash
grep -n "^## STEP " .claude/skills/dev-parallel/SKILL.md
```

**Expected verification output:** 15 lines, with `## STEP 8 — Validate Subagent Reports` appearing between `## STEP 7` and `## STEP 9 — Stage 1: Spec Compliance Review`.

---

## Step 9 — Renumber old Steps 8–14 to 9–15

**File:** `.claude/skills/dev-parallel/SKILL.md`

**Tool:** `Edit` with `replace_all: true` for every operation below. The `Step N/14: <label>` pattern is globally unique per N because each label differs.

**Context:** After Step 8 of this doc, the only headers/markers that still carry `/14` numbering are:
- Checklist items in the Step 1 `[PROGRESS]` initialization block (Steps 1–7 with their original numbers, because Step 6 of this doc rewrote the checklist to use `/15`) — wait, Step 6 already handled Steps 1–14 inside the checklist block. The remaining `/14` references are the **per-step `[PROGRESS]` mark calls** scattered through Steps 1–14.
- Headers `## STEP 9` through `## STEP 14`
- Internal `[PROGRESS]` markers inside each of those old step bodies

### 9a — Update per-step `[PROGRESS]` mark calls (Steps 1–7; unchanged numbers but `/14` → `/15`)

Apply each as `Edit` with `replace_all: true`:

| Find | Replace |
|------|---------|
| `Step 1/14: Load Config` | `Step 1/15: Load Config` |
| `Step 2/14: Load Implementation Doc` | `Step 2/15: Load Implementation Doc` |
| `Step 3/14: Group Independent Tasks` | `Step 3/15: Group Independent Tasks` |
| `Step 4/14: Generate Subagent Prompts` | `Step 4/15: Generate Subagent Prompts` |
| `Step 5/14: Dispatch Gate` | `Step 5/15: Dispatch Gate` |
| `Step 6/14: Dispatch Subagents (after G-11)` | `Step 6/15: Dispatch Subagents (after G-11)` |
| `Step 7/14: Collect Results` | `Step 7/15: Collect Results` |

Note: `Step 1/14: Load Config` was already rewritten in Step 6 (checklist block), but the `[PROGRESS] Mark Step 1/14 \`completed\`` line was also covered in Step 6. For Steps 2–7, the checklist block (Step 6 of this doc) already uses `/15`, but the per-step `[PROGRESS] Mark Step N/14 ...` calls inside Steps 2–7 bodies still say `/14` — that is what this sub-step updates.

### 9b — Update internal `[PROGRESS]` markers in old Steps 8–14 and shift to new numbers

Apply each as `Edit` with `replace_all: true`. Each pattern is unique, so order does not matter:

| Find | Replace |
|------|---------|
| `Step 8/14: Stage 1: Spec Compliance Review` | `Step 9/15: Stage 1: Spec Compliance Review` |
| `Step 9/14: Stage 2: Code Quality Review` | `Step 10/15: Stage 2: Code Quality Review` |
| `Step 10/14: Fix Loop` | `Step 11/15: Fix Loop` |
| `Step 11/14: Update Implementation Doc` | `Step 12/15: Update Implementation Doc` |
| `Step 12/14: Full Test Run` | `Step 13/15: Full Test Run` |
| `Step 13/14: Summary` | `Step 14/15: Summary` |
| `Step 14/14: Handoff` | `Step 15/15: Handoff` |

### 9c — Rename step headers

Apply each as `Edit` (single occurrence each — each header is unique):

| Find | Replace |
|------|---------|
| `## STEP 9 — Stage 2: Code Quality Review` | `## STEP 10 — Stage 2: Code Quality Review` |
| `## STEP 10 — Fix Loop` | `## STEP 11 — Fix Loop` |
| `## STEP 11 — Update Implementation Doc` | `## STEP 12 — Update Implementation Doc` |
| `## STEP 12 — Full Test Run` | `## STEP 13 — Full Test Run` |
| `## STEP 13 — Summary` | `## STEP 14 — Summary` |
| `## STEP 14 — Handoff` | `## STEP 15 — Handoff` |

**Order matters here:** apply in REVERSE numerical order (STEP 14 → STEP 15 first, then STEP 13 → STEP 14, and so on). This prevents a later rename from accidentally matching a header that was just renamed. (Example: renaming `## STEP 9` → `## STEP 10` first would create a collision when the real `## STEP 10` — now displaced — is later renamed to `## STEP 11`.)

Note: `## STEP 8 — Stage 1: Spec Compliance Review` was already renamed to `## STEP 9 — Stage 1: Spec Compliance Review` in Step 8 of this doc (as part of the replacement block). Do not re-rename it here.

**Expected output:** All edits succeed. File no longer contains any `/14` step references, and all step headers are numbered 1–15 with no gaps.

**Verification commands:**
```bash
grep -c "Step [0-9]*/14:" .claude/skills/dev-parallel/SKILL.md
grep -c "Step [0-9]*/15:" .claude/skills/dev-parallel/SKILL.md
grep -n "^## STEP " .claude/skills/dev-parallel/SKILL.md
```

**Expected verification output:**
- First command: `0` (no `/14` markers remain)
- Second command: ≥ 30 (roughly 2 per step × 15 steps, plus the 15 checklist lines inside Step 1)
- Third command: exactly 15 lines, numbered `## STEP 1` through `## STEP 15` in order, with no gaps.

---

## Step 10 — Commit 2

**Tool:** `Bash`

**Commands:**
```bash
git add .claude/skills/dev-parallel/SKILL.md
git status
git commit -m "feat(dev-parallel): add verification gate and subagent report validation

Apply the [VERIFY] gate to dev-parallel per-subagent. Subagents run
the 5-step gate on their own work and include a GATE: PASS block with
quoted evidence in their report. A new orchestrator step (Step 8 —
Validate Subagent Reports) inspects each report for presence, evidence,
and hedging language; failures trigger a verify-only re-dispatch with
a 1-retry cap and user escalation.

Two new rationalization prevention rows added. Step count: 14 -> 15.

Refs #13"
```

**Expected output:** `git status` shows only `.claude/skills/dev-parallel/SKILL.md` staged. Commit succeeds with 1 file changed.

**Verification command:**
```bash
git log -2 --oneline
```

**Expected verification output:** Two most recent commits on this branch, in order:
```
<sha2> feat(dev-parallel): add verification gate and subagent report validation
<sha1> docs(claude-tools): add [VERIFY] marker and convention
```

---

## Deviations

(empty — fill in if any step deviates from the plan during execution)