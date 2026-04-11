# Claude Code — Capability Marker Mapping

This file maps Devflow capability markers to Claude Code native tools.
Loaded at session start via `CLAUDE.md`.

| Marker | Claude Code Tool | Notes |
|--------|-----------------|-------|
| `[READ]` | `Read` tool | Read file contents |
| `[SHELL]` | `Bash` tool | Execute shell commands |
| `[SEARCH]` | `Grep` / `Glob` tools | Search codebase |
| `[WRITE]` | `Write` / `Edit` tools | Create or modify files |
| `[PARALLEL]` | Multiple `Agent` tool calls in one message | Launch parallel subagents |
| `[DELEGATE]` | `Agent` tool | Launch isolated subagent |
| `[FAST-MODEL]` | `model: "haiku"` parameter on Agent tool | Use fastest available model |
| `[SMART-MODEL]` | `model: "opus"` parameter on Agent tool | Use most capable model |
| `[PROGRESS]` | `TodoWrite` tool | Create and update a live step checklist. Graceful degradation: skip if TodoWrite unavailable |
| `[VERIFY]` | Inline text inspection | Run the 5-step verification gate before claiming a task complete. See `## [VERIFY] Convention` below. |

## Subagent Support

Claude Code fully supports subagent dispatch via the `Agent` tool.

- `[PARALLEL]` → multiple `Agent` calls in a single message (true parallelism)
- `[DELEGATE]` → single `Agent` call with focused brief
- Model selection via `model` parameter: `"haiku"`, `"sonnet"`, `"opus"`

## Fallback

No fallback needed — Claude Code supports all markers natively.

## [PROGRESS] Convention

`[PROGRESS]` maps to the `TodoWrite` tool. Use it to maintain a live checklist of steps during skill execution.

### Initialization (at skill start, after config is loaded)

Create one TodoWrite item per numbered STEP in the skill. All items start as `pending`.

Item format:
```
Step N/Total: <step title>
```

### Updating items during execution

At the **start** of each step — update that item to `in_progress`:
```
Step 3/10: Analyze Task Dependencies [in_progress]
```

At the **end** of each step — update that item to `completed`, embedding result:
```
Step 3/10: Analyze Task Dependencies [completed]
Analysis complete
```

For steps that read files:
```
Step 2/10: Load Implementation Doc [completed]
Files read: docs/plans/issue-8/implementation.md, docs/plans/issue-8/plan.md
```

For steps that change files or run build/lint:
```
Step 7/10: Implementation Loop [completed]
Files changed: src/auth.ts, src/types.ts
Build: ✓  Lint: ✓
```

### Graceful degradation

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
