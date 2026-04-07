---
name: dev-debug
description: Use when debugging failures — 4-phase systematic debugging with escalation after repeated failures
---

# dev-debug: Systematic Debugging

4-phase debugging: reproduce, isolate, hypothesize, verify. No fixes until isolation is complete.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/project-init` first.

Store:
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`
- `{config.repo.owner}` / `{config.repo.name}`

---

## STEP 2 — Identify Problem

[SHELL] Get current branch:
```bash
git branch --show-current
```

Derive issue number from branch name.

Ask user:
> "What is failing? (test name, error message, or behavior description)"

[SHELL] Check for prior debug sessions:
```bash
test -f docs/plans/issue-<n>/debug.md && echo "exists" || echo "none"
```

If exists → [READ] `docs/plans/issue-<n>/debug.md` for prior findings. Display:
```
Prior debug session found — <count> previous attempt(s).
Last hypothesis: <summary>
```

Initialize: `failure_counter = 0`

---

## STEP 3 — Phase 1: Reproduce

**HARD RULE: Do not propose any fix in this phase. Only confirm reproduction.**

[SHELL] Run the failing command (from user input or `{config.stack.test_cmd}`):
```bash
{config.stack.test_cmd}
```

Capture: exact error output, exit code, stack trace (if any).

[READ] relevant source files from stack trace or error output.

Display:
```
Phase 1: Reproduce
═══════════════════════════
Reproduced : YES / NO
Command    : <command run>
Exit code  : <code>
Error      : <first 10 lines of error output>
Stack trace: <file:line references>
```

If not reproducible → ask user for more specific reproduction steps. Do not proceed until reproduced.

---

## STEP 4 — Phase 2: Isolate

**HARD RULE: Do not propose any fix in this phase. Only identify the exact location and trigger.**

[DELEGATE][SMART-MODEL] Narrow down root cause:

1. **Which file and line?** — trace from stack trace or error output
2. **What input triggers it?** — specific data, state, or sequence
3. **Is it a regression?**
   ```bash
   git log --oneline -10 -- <file>
   ```
4. **Minimal reproduction path** — smallest set of conditions that trigger the bug

[READ] the isolated file(s) to confirm the location.

Display:
```
Phase 2: Isolate
═══════════════════════════
File       : <file-path>
Line       : <line-number>
Trigger    : <what causes it>
Regression : YES (commit <sha>) / NO (pre-existing)
Minimal    : <shortest reproduction path>
```

---

## STEP 5 — Phase 3: Hypothesize

[DELEGATE][SMART-MODEL] Generate 1–3 competing hypotheses, ranked by likelihood:

For each hypothesis:
- **Root cause theory**: what is wrong and why
- **Predicted fix**: what change would resolve it
- **Risk**: what could go wrong with this fix (regressions, side effects)
- **Confidence**: high / medium / low

Display:
```
Phase 3: Hypothesize
═══════════════════════════
#1 (high)   : <root cause> → <predicted fix>
              Risk: <side effects>

#2 (medium) : <root cause> → <predicted fix>
              Risk: <side effects>

#3 (low)    : <root cause> → <predicted fix>
              Risk: <side effects>
```

---

## STEP 6 — Fix Gate

**G-12: "Proceed with hypothesis #<n>? (yes / pick different / describe alternative)"**

Wait for user choice:
- **yes** → proceed with the indicated hypothesis
- **pick different** → user picks a different hypothesis number
- **describe alternative** → user provides their own theory → add as hypothesis and proceed

---

## STEP 7 — Phase 4: Verify (after G-12)

Implement the chosen fix.

[SHELL] Run the original failing command — it must pass:
```bash
<original-failing-command>
```

[SHELL] Run full test suite — no regressions:
```bash
{config.stack.test_cmd}
```

**If fix works** (both commands pass):
- Proceed to Step 8

**If fix fails** (either command still fails):
1. Revert the fix:
   ```bash
   git checkout -- <modified-files>
   ```
2. Increment `failure_counter`
3. If `failure_counter >= 3` → go to **Step 7b** (Architectural Escalation)
4. If `failure_counter < 3` → display "Fix did not work. Returning to hypothesize." → return to Step 5 with new context from this failure

---

## STEP 7b — Architectural Escalation (3+ failed fixes)

[DELEGATE][SMART-MODEL] Architectural review:

Check:
- Is the component design fundamentally flawed?
- Is there a structural issue causing the bug (wrong abstraction, missing layer, circular dependency)?
- Should this be a refactor instead of a patch?
- Are there upstream/downstream assumptions that are broken?

Display:
```
Architectural Escalation
═══════════════════════════
3+ fix attempts have failed. This may indicate a design issue.

Analysis:
<architectural findings>

Recommendation: <continue debugging / refactor component / create new issue>
```

Ask user:
> "Continue debugging with new approach, or create a refactor issue? (debug / refactor)"

- **debug** → reset failure_counter, return to Step 4 with architectural context
- **refactor** → display recommendation for new issue, stop

---

## STEP 8 — Record Findings

[WRITE] Append to `docs/plans/issue-<n>/debug.md` (create if not exists):

```markdown
## Debug Session — <timestamp>

Problem    : <user's description>
Reproduced : <command + abbreviated output>
Isolated   : <file:line>
Trigger    : <what causes it>
Regression : <yes/no + commit if applicable>
Hypothesis : #<n> — <root cause theory>
Fix        : <what was changed>
Verified   : <test command + PASS>
Attempts   : <failure_counter + 1>
```

---

## STEP 9 — Commit

[SHELL] Commit the fix and debug log:
```bash
git add <fixed-files> docs/plans/issue-<n>/debug.md
git commit -m "fix(<scope>): <subject>

<root cause explanation — one sentence>

Refs #<issue-number>"
```

---

## STEP 10 — Summary + Handoff

Display:
```
Debug Complete
═══════════════════════════
Problem    : <description>
Root cause : <one sentence>
Fix        : <what changed>
Tests      : all passing
Attempts   : <count>
Debug log  : docs/plans/issue-<n>/debug.md
```

```
Run /dev-pr if ready to open a PR, or /dev-implement to continue implementation.

Branch : <branch-name>
Issue  : #<number>
```
