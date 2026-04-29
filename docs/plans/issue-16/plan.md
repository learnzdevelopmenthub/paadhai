---
issue: 16
title: Implement batch commit grouping by related steps in dev-implement
branch: feature/16-batch-commit-grouping
milestone: v2.3 — Workflow Efficiency
status: confirmed
confirmed_at: 2026-04-22
---

## Overview

Replace the placeholder `**batch**` bullet in G-06 (Step 7f of `.claude/skills/dev-implement/SKILL.md`) with full batch grouping semantics: group-key computation (explicit tag OR file-prefix), group-boundary commit rule, batch commit message format, and batch-failure → per-step revert with BATCH BROKEN banner. Add a narrow carve-out to the rationalization table row so batch mode is not blocked. Same Option-B in-place pattern used in #15 — no renumbering of sub-steps.

## Files to Create

- `docs/plans/issue-16/plan.md` — this plan
- `docs/plans/issue-16/implementation.md` — step-by-step impl doc

## Files to Modify

- `.claude/skills/dev-implement/SKILL.md`:
  1. Amend the rationalization row on line 64 with a narrow `commit_mode = batch` carve-out.
  2. Replace the one-liner `**batch**` bullet in G-06 (Step 7f, line 326) with full batch grouping prose.
  3. Add the BATCH BROKEN banner literal adjacent to the existing MODE SWITCH banner.

## Implementation Steps

1. **Amend rationalization row (line 64)**
   - Current: `| "I'll commit these steps together" | Atomic commits aid debugging and revert; batching hides which step broke | One commit per step |`
   - Replace the "What to do" cell with: `One commit per step — unless commit_mode = batch, in which case G-06's batch grouping logic is authoritative`
   - Expected: row preserves structural rule for per-step/auto-commit modes; explicit batch mode is exempt. SRS §6.2 "not overridable by the agent" still holds because the carve-out itself is structural — it requires the explicit `batch` value from Step 2's AskUserQuestion-constrained prompt, not an ad-hoc agent decision.

2. **Expand G-06 `batch` bullet in Step 7f**
   - Current (line 326):
     ```
     - **`batch`** → defer to batch grouping logic (logic in #16); unchanged.
     ```
   - Replace with a multi-sub-bullet block describing:
     - **Group-key computation**: for each step, `group_key = step.group_metadata` if a `**Group:** <slug>` header is present on the step, else the first 2 path segments of the step's primary file (the first-listed file in its "Files" / modified-files section).
     - **Group boundaries**: a group closes when the next step's `group_key` differs, or the implementation reaches its final step.
     - **Group pass path**: on group close, if all member steps' 7c/7d/7d.1 PASS, commit the whole group using 7g with a batch commit message (format below). No approval prompt.
     - **Group fail path**: if any member step FAILs (build, lint, review, verification gate, or pre-commit hook), the group is **not committed**. Display the BATCH BROKEN banner, flip `commit_mode` to `per-step` for the remainder of the session, then fall through to per-step G-06 for the failing step after fix. Uncommitted changes from earlier group-members remain on disk and are handled via per-step G-06 from that point forward — the developer decides per commit what to include. Once flipped, `commit_mode` stays `per-step` for every subsequent step.
     - **Edge case — size-1 groups**: when a step's `group_key` differs from both neighbors, its group has size 1; it still commits silently via batch mode (no approval prompt). Mode remains `batch`.
     - **`--no-verify` forbidden**: batch commits use the same `git commit` invocation as per-step. Pre-commit hook failure → BATCH BROKEN banner with reason `hook`.
   - **Batch commit message format** (documented at end of the bullet, deferred in actual invocation to 7g):
     ```
     <type>(<scope>): <group-name> — <N> steps

     - Step <N1>: <description>
     - Step <N2>: <description>
     …

     Refs #<issue-number>
     ```
     Subject: max 72 chars, imperative mood. Type selected per 7g's commit-type table based on the group's dominant change kind.
   - Expected: `(logic in #16)` placeholder removed; G-06 section describes batch mode with full semantics.

3. **Add BATCH BROKEN banner literal under Step 7f**
   - Insert adjacent to the existing MODE SWITCH banner block (lines 328–336):
     ```
     BATCH BROKEN banner (displayed on `batch` fail path, immediately before per-step G-06 re-engages):

     ────────────────────────────────────────
     BATCH BROKEN: batch → per-step
     Reason: <build | lint | review | gate | hook> failed on step <N> (group <G>)
     Group <G> not committed. All remaining steps will use per-step approval.
     ────────────────────────────────────────
     ```
   - Expected: post-edit `grep -c "BATCH BROKEN"` returns 2 (one prose reference + one banner literal line), matching the existing MODE SWITCH pattern.

4. **Verify internal consistency (greps)**
   - `grep -n "logic in #16" .claude/skills/dev-implement/SKILL.md` → zero matches.
   - `grep -c "BATCH BROKEN" .claude/skills/dev-implement/SKILL.md` → exactly 2 matches (prose + banner), both inside Step 7f.
   - `grep -n "MODE SWITCH" .claude/skills/dev-implement/SKILL.md` → counts from #15 preserved (unchanged by this issue).
   - `grep -n "no-verify" .claude/skills/dev-implement/SKILL.md` → count from #15 preserved (1 occurrence in 7g); batch's `--no-verify` prohibition references the existing 7g rule rather than duplicating.
   - `grep -n "commit_mode = batch" .claude/skills/dev-implement/SKILL.md` → at least 2 matches (rationalization row carve-out + G-06 group-key prose).
   - `grep -n "I'll commit these steps together" .claude/skills/dev-implement/SKILL.md` → exactly 1 match, with the carve-out phrase.

## Test Cases

- **Happy path (AC-1, AC-2, AC-3)**: 12-step impl doc with 3 distinct group-keys (e.g., 5 steps under `docs/`, 4 under `src/auth/`, 3 under `tests/`) — prose must describe 3 group-boundary commits, each with the batch-format commit message listing its member steps.
- **Edge case — unrelated steps (degenerate)**: every step has a unique group-key — prose explicitly states each step forms a size-1 group that commits silently in batch mode (no approval).
- **Error case (AC-4)**: step 7 of 9 fails inside a 4-step group — prose must state: group not committed, BATCH BROKEN banner displays, `commit_mode` flips to `per-step` for the rest of the session, failing step re-engages per-step G-06 after fix, earlier group-members' uncommitted changes handled via per-step from that point.
- **Hook failure**: batch group-commit's pre-commit hook fails — prose must name `hook` as a valid banner reason and route through the same per-step revert path.
- **Group-key source precedence**: when both `**Group:** <slug>` metadata and file-prefix are present, prose states the explicit metadata wins.

## Security Considerations

- Batch commits use the same `git add <specific-files>` pattern as 7g; `git add -A` is never used.
- `--no-verify` forbidden (SRS §6.2) — inherited from 7g's existing safeguard paragraph.
- Batch failure triggers auto-revert to per-step (SRS §6.3 spirit) — no silent broken or partial-group commits.
- Batch commit message body is populated from developer-authored impl doc step descriptions — not external input. No untrusted data enters the commit message.
- BATCH BROKEN banner reason field is a fixed category (`build | lint | review | gate | hook`) — no free-form strings, no paths or diff content, no credentials.
- `commit_mode` input is AskUserQuestion-constrained (3 known values from #14); session-local, never persisted.

**Security Checklist:**
- [ ] `--no-verify` never emitted in any batch `git commit` invocation.
- [ ] Batch commits use `git add <specific-files>`, never `git add -A`.
- [ ] BATCH BROKEN banner reason is a fixed category, not free text.
- [ ] Group-key computation uses impl-doc-declared paths only — no shell interpolation of raw path strings.
- [ ] Rationalization row carve-out is narrow (only `commit_mode = batch` exempts) — not a general override.

## AC Mapping

| AC | How Addressed |
|----|---------------|
| AC-1 | G-06 batch prose defines `group_key` computation: explicit `**Group:**` metadata OR first-2-path-segments of primary file. |
| AC-2 | G-06 batch prose defines group close condition (next step's group-key differs, or final step) and commits on close — not per step. |
| AC-3 | Batch commit message format specified: subject `<type>(<scope>): <group-name> — N steps`, body lists `Step <N>: <description>` for each member. |
| AC-4 | G-06 fail path: group not committed, BATCH BROKEN banner displays, `commit_mode` flips to per-step, failing step re-engages per-step G-06 after fix. |
| SRS FR-04 AC-5 | Parent requirement — fully satisfied by ACs above. |
| Test "happy path" | Prose describes 3 commits for 12-step/3-group impl plan via group-boundary rule. |
| Test "all unrelated" | Size-1 group edge case explicitly named. |
| Test "step 7 fails" | Fail path explicitly names step-in-group failure triggers revert + banner. |

## Definition of Done

- [ ] All issue ACs (AC-1…AC-4) satisfied by updated prose.
- [ ] `grep "logic in #16"` → zero matches.
- [ ] `grep "BATCH BROKEN"` → exactly 2 matches inside Step 7f.
- [ ] `grep "commit_mode = batch"` → ≥2 matches (rationalization row + G-06).
- [ ] Rationalization row line 64 contains the carve-out phrase.
- [ ] Plan + implementation doc committed under `docs/plans/issue-16/`.

> Build / lint / test: N/A — `.paadhai.json` stack is `none`; docs-only change.

## Brainstorming Decisions

| Q | Decision | Source |
|---|----------|--------|
| Q1 | Hybrid: `**Group:**` tag wins, else first-2-path-segments of primary file | Issue notes + FR-04 AC-5 |
| Q2 | First 2 path segments | Operational interpretation of "module" |
| Q3 | Primary file = first file listed in step's Files section | Deterministic tie-break |
| Q4 | Close group when next step's group-key differs or at final step | Issue AC-2 |
| Q5 | Group not committed; BATCH BROKEN banner; flip to per-step for remainder of session | Issue AC-4 + §6.3 |
| Q6 | Uncommitted changes from successful group-members left on disk; handled via per-step | Issue test literal |
| Q7 | Size-1 groups commit silently as batch; mode stays `batch` | Issue test "degrades to per-step" |
| Q8 | Subject: `<type>(<scope>): <group-name> — N steps`; body lists `Step <N>: <description>` per member | Issue AC-3 |
| Q9 | Reading rule: `**Group:** <slug>` metadata optional; absent → file-prefix. Writing tags is dev-plan convention (out of scope here). | Issue notes |
| Q10 | Rationalization row amended with narrow `commit_mode = batch` carve-out | SRS §6.2 |
| Q11 | Expand G-06 batch bullet in place (Option B — same as #15) | SRS §7 |
| Q12 | `--no-verify` forbidden on batch commits; hook failure = batch failure | SRS §6.2 + issue notes |

## ADR

Declined — no new technology, pattern, or breaking change.
