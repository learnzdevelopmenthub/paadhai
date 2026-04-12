---
issue: 12
title: Add 5-step verification gate to dev-implement
branch: feature/12-verification-gate-dev-implement
---

## Progress

| Step | Description                                                  | Status  |
|------|--------------------------------------------------------------|---------|
| 1    | Insert `## VERIFICATION GATE` section into dev-implement     | done    |
| 2    | Insert `### 7d.1 — Verification Gate` sub-step into Step 7   | done    |
| 3    | Verify edits and confirm all ACs addressed                   | done    |

---

## Step 1 — Insert `## VERIFICATION GATE` section into `dev-implement/SKILL.md`

**File:** `.claude/skills/dev-implement/SKILL.md`

**Action:** Insert a new `## VERIFICATION GATE` section between the RATIONALIZATION PREVENTION table's closing `---` (line 69) and `## STEP 1 — Load Config` (line 71).

**Insertion anchor:** use the `Edit` tool with this `old_string`:

```
| "I can skip lint, the code is clean" | Lint catches issues humans miss — formatting, unused vars, import order | Run `{config.stack.lint_cmd}` every time |

---

## STEP 1 — Load Config
```

And this `new_string`:

```
| "I can skip lint, the code is clean" | Lint catches issues humans miss — formatting, unused vars, import order | Run `{config.stack.lint_cmd}` every time |

---

## VERIFICATION GATE

Before declaring any step `done`, you MUST run this 5-step gate. This is a **structural rule** — it cannot be overridden, skipped, or abbreviated. The gate runs per-step inside Step 7 (see sub-step 7d.1).

**Commands must be re-run every time — results cannot be recalled from memory.** Memory is unreliable; the only acceptable evidence is fresh command output captured during this gate run.

### The 5 steps

1. **IDENTIFY** — What specific claims am I about to make about this step? List each one (e.g., "tests pass", "build succeeds", "file X contains Y").
2. **RUN** — Execute the verification command(s) for each claim: `{config.stack.build_cmd}`, `{config.stack.lint_cmd}`, `{config.stack.test_cmd}`, or a `Read`/`Grep` for content claims. Do not reuse output from an earlier run.
3. **READ** — Read the ACTUAL output of each command. Do not summarize from memory. Do not paraphrase.
4. **VERIFY** — For each claim from IDENTIFY, check the output line-by-line. Does the output literally confirm the claim?
5. **CLAIM** — Only now may you state the step is complete. Every claim must be followed by a quoted block of the exact output that proves it.

### Red flags — restart the gate from RUN

If your CLAIM message contains any of the following, you MUST restart from step 2 (RUN):

- Hedging words: `should`, `probably`, `seems to`, `I believe`, `appears to`, `looks like`
- No quoted command output block for a claim
- Claims without a specific file path + line reference (for content claims)
- Output quoted from an earlier step or earlier gate run (must be fresh)

### Edge case — docs-only step (7d skipped)

If Step 7d was skipped because no source files changed, the gate still runs: execute `{config.stack.lint_cmd}` (if available) or the relevant `Read`/`Grep` command to verify the docs claim, and quote that output in CLAIM.

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

If any claim cannot be verified, the gate FAILS and the step stays `pending`. Do not proceed to 7e. Do not commit.

```
GATE: FAIL

Unmet items:
1. Claim "<claim>" — <reason, e.g., "no output quoted", "output shows 2 failures", "hedging language used">
2. Claim "<claim>" — <reason>

Next action: fix the missing evidence above and re-run the gate from step 2 (RUN).
```

---

## STEP 1 — Load Config
```

**Expected outcome:** Reading the file again shows the new `## VERIFICATION GATE` section between the RATIONALIZATION PREVENTION table's closing `---` and `## STEP 1 — Load Config`. The section contains: the 5 numbered steps, the "commands must be re-run" rule, the red flags list with all four hedging words, the docs-only edge case, and both PASS and FAIL format blocks.

**Verification (per the gate itself):**
1. IDENTIFY: claims = "section inserted at correct anchor", "5 numbered gate steps present", "red flag list includes should/probably/seems to/I believe", "FAIL format is structured block with numbered unmet items"
2. RUN:
   - `Read .claude/skills/dev-implement/SKILL.md offset=68 limit=80` — confirms location and content
   - `Grep "IDENTIFY|RUN|READ|VERIFY|CLAIM" in .claude/skills/dev-implement/SKILL.md` — confirms 5 steps
   - `Grep "should|probably|seems to|I believe" in .claude/skills/dev-implement/SKILL.md` — confirms hedging words
3. READ: read all three outputs fresh
4. VERIFY: each claim confirmed by its corresponding output
5. CLAIM: quote the three outputs under `GATE: PASS`

---

## Step 2 — Insert `### 7d.1 — Verification Gate` sub-step into Step 7

**File:** `.claude/skills/dev-implement/SKILL.md`

**Action:** Insert a new `### 7d.1 — Verification Gate` sub-step between `### 7d — Build + Lint` (ends with "Fix failures before proceeding." at line 221) and `### 7e — Update Implementation Doc` (line 223).

**Insertion anchor:** use the `Edit` tool with this `old_string`:

```
Fix failures before proceeding.

### 7e — Update Implementation Doc
```

And this `new_string`:

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
```

**Expected outcome:** Reading the file again shows `### 7d.1 — Verification Gate` between `### 7d — Build + Lint` and `### 7e — Update Implementation Doc`. The sub-step references the top-level VERIFICATION GATE section, states the blocking rule, covers the docs-only edge case, and lists the hedging-language auto-retrigger.

**Verification (per the gate itself):**
1. IDENTIFY: claims = "7d.1 inserted between 7d and 7e", "references top-level VERIFICATION GATE section", "blocking rule on FAIL present", "hedging auto-retrigger present"
2. RUN:
   - `Read .claude/skills/dev-implement/SKILL.md offset=215 limit=30` — shows 7d, 7d.1, 7e in order
   - `Grep "### 7d\.1|### 7e" in .claude/skills/dev-implement/SKILL.md -n` — confirms ordering and line numbers
3. READ: read both outputs fresh
4. VERIFY: each claim confirmed
5. CLAIM: quote under `GATE: PASS`

---

## Step 3 — Verify edits and confirm all ACs addressed

**Action:** Read the modified file and run greps to confirm all 5 acceptance criteria from issue #12 are satisfied. This step produces no new file changes.

**Verification commands:**

```bash
# Confirm VERIFICATION GATE section location
Read .claude/skills/dev-implement/SKILL.md offset=68 limit=90

# Confirm 7d.1 sub-step location
Read .claude/skills/dev-implement/SKILL.md offset=215 limit=35

# Confirm all 5 gate steps named
Grep -n "IDENTIFY|^2\. \*\*RUN|^3\. \*\*READ|VERIFY|CLAIM" .claude/skills/dev-implement/SKILL.md

# Confirm hedging words (AC-3)
Grep -n "should.*probably.*seems to.*I believe|hedging" .claude/skills/dev-implement/SKILL.md

# Confirm memory rule (AC-4)
Grep -n "cannot be recalled from memory|re-run every time" .claude/skills/dev-implement/SKILL.md

# Confirm FAIL format (AC-5)
Grep -n "GATE: FAIL|Unmet items" .claude/skills/dev-implement/SKILL.md

# Confirm CLAIM requires quoted output (AC-2)
Grep -n "quoted block|Evidence:" .claude/skills/dev-implement/SKILL.md
```

**Expected outcome:** Every grep returns at least one match. Every AC from the plan's AC Mapping table can be cited by quoting a specific file + line range.

**Per-AC checklist:**
- [ ] AC-1: Gate defined + 7d.1 wiring both present — quote both section headings with line numbers
- [ ] AC-2: "Evidence:" + quoted output block pattern visible in PASS format — quote the PASS format block
- [ ] AC-3: Hedging words list present with restart-from-RUN rule — quote the red flags block
- [ ] AC-4: "cannot be recalled from memory" phrase present — quote that line
- [ ] AC-5: FAIL format has "Unmet items" numbered list + "step stays `pending`" rule — quote the FAIL format block

**Verification (per the gate itself):** This step IS the verification for the whole change. Produce a single `GATE: PASS` block at the end citing all 5 ACs with quoted file evidence. If any AC cannot be verified, `GATE: FAIL` and return to Step 1 or Step 2 to fix.

---

## Deviations

(none)
