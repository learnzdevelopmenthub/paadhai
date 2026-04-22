---
issue: 15
title: Implement auto-commit logic with failure revert in dev-implement
branch: feature/15-auto-commit-failure-revert
milestone: v2.3 — Workflow Efficiency
status: confirmed
confirmed_at: 2026-04-22
---

## Overview

Implement the auto-commit mode logic in `.claude/skills/dev-implement/SKILL.md`: when `commit_mode = auto-commit` is selected, commit silently after each passing step (build, lint, code review, and verification gate all PASS). If any of those fail, revert `commit_mode` to `per-step` for the remainder of the session and notify the developer with a MODE SWITCH banner. Option B chosen — extend G-06 prose in place at Step 7f; no renumbering of sub-steps 7g/7h.

## Files to Create

- `docs/plans/issue-15/plan.md` — this plan document
- `docs/plans/issue-15/implementation.md` — step-by-step implementation doc

## Files to Modify

- `.claude/skills/dev-implement/SKILL.md`:
  1. Expand the G-06 bullet inside Step 7f to contain full auto-commit semantics (pass path, revert triggers, MODE SWITCH banner, post-revert behavior).
  2. Add one sentence at the end of Step 7g stating `--no-verify` is never used and that a failing pre-commit hook counts as a step failure.

## Implementation Steps

1. **Expand G-06 prose at Step 7f in `SKILL.md`**
   - Replace the current one-liner:
     `**G-06**: If commit_mode = per-step → wait for user approval before committing. If commit_mode = auto-commit → commit automatically (logic in #15). If commit_mode = batch → defer to batch grouping logic (logic in #16).`
   - With a multi-bullet block describing:
     - **per-step** → wait for explicit user approval (unchanged).
     - **auto-commit pass path** → if build, lint, code review (7c), and verification gate (7d.1) all PASS, commit automatically using 7g — no approval prompt. Unconfigured check commands (empty `{config.stack.build_cmd}` or `{config.stack.lint_cmd}`) are treated as non-blocking (matching check is skipped, not failed).
     - **auto-commit fail path** → on any FAIL (build, lint, review, or verification gate), flip `commit_mode` from `auto-commit` to `per-step` for the remainder of the session, display the MODE SWITCH banner, then fall through to per-step G-06 for this failing step after the fix.
     - **batch** → unchanged; still defers to #16.
   - Include the MODE SWITCH banner literal exactly:
     ```
     ────────────────────────────────────────
     MODE SWITCH: auto-commit → per-step
     Reason: <build | lint | review | gate> failed on step <N>
     All remaining steps will use per-step approval.
     ────────────────────────────────────────
     ```
   - Expected: G-06 section describes all 3 modes with full auto-commit semantics; placeholder `(logic in #15)` removed.

2. **Add `--no-verify` safeguard under Step 7g**
   - Insert a single paragraph at the end of 7g, after the commit-type table and subject-line rule:
     > Auto-commit uses the same `git commit` invocation as per-step — `--no-verify` is never used. If a pre-commit hook fails, treat it as a step failure: the commit aborts, the MODE SWITCH banner displays with reason `hook`, `commit_mode` flips to `per-step`, and G-06 re-engages for the failing step.
   - Expected: post-edit grep for `--no-verify` returns exactly one occurrence, inside the new paragraph.

3. **Verify internal consistency**
   - `grep -n "logic in #15" .claude/skills/dev-implement/SKILL.md` → zero matches.
   - `grep -n "MODE SWITCH" .claude/skills/dev-implement/SKILL.md` → exactly one occurrence, inside Step 7f.
   - `grep -n "no-verify" .claude/skills/dev-implement/SKILL.md` → exactly one occurrence, inside Step 7g.
   - `grep -n "commit_mode" .claude/skills/dev-implement/SKILL.md` → original Step 2 occurrence plus expanded 7f references; no orphan references.
   - Expected: all four greps match the stated counts.

## Test Cases

- **Happy path (AC-1, AC-2)**: A 5-step implementation with `auto-commit` and every step passing 7c + 7d + 7d.1 — prose must describe silent commit via 7g with no approval prompt.
- **Edge case (AC-3)**: Prose names all four failure sources — build, lint, review, verification gate — as revert triggers, plus pre-commit hook failure via 7g safeguard.
- **Edge case — empty `build_cmd`**: Prose explicitly states that empty `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` are non-blocking (skipped, not failed).
- **Error case (AC-4)**: Prose states `commit_mode` flips to `per-step` and "remains per-step for all subsequent steps" (or equivalent) — grep confirms this phrasing.
- **Verification-gate interaction (Q2)**: Prose names the verification gate (7d.1) as a revert trigger alongside build/lint/review.

## Security Considerations

- Auto-commit uses the same `git add <specific-files>` pattern as per-step; scope unchanged.
- `--no-verify` explicitly forbidden (SRS §6.2) — enforced by new prose under 7g.
- Any failure triggers auto-revert to per-step (SRS §6.3) — no silent broken commits.
- `commit_mode` input is AskUserQuestion-constrained (3 known values); session-local, never persisted to disk.
- MODE SWITCH banner reason is a fixed category name — no paths, diff content, or credentials.

**Security Checklist:**
- [ ] `commit_mode` values constrained at entry point.
- [ ] MODE SWITCH banner reason is a fixed category, not free text.
- [ ] `--no-verify` never emitted in any `git commit` invocation.
- [ ] Auto-commit uses `git add <specific-files>`, never `git add -A`.

## AC Mapping

| AC | How Addressed |
|----|---------------|
| AC-1 | G-06 auto-commit pass path requires build + lint PASS and code review PASS ("no blocking issues") before silent commit. |
| AC-2 | G-06 auto-commit path delegates commit message format to existing 7g block — same convention as per-step. |
| AC-3 | G-06 fail path names build, lint, review, and (per Q2) verification gate as revert triggers; MODE SWITCH banner is the notification. |
| AC-4 | G-06 prose states mode flips to `per-step` for the remainder of the session; re-prompt only happens on a fresh `/dev-implement` invocation. |
| Test "happy path" | Prose describes no-approval auto-commit for passing steps. |
| Test "step 3 fails lint" | Prose describes mode switch on lint FAIL plus per-step for steps 4-N. |
| Test "empty build_cmd" | Prose explicitly names empty check commands as non-blocking. |

## Definition of Done

- [ ] All issue ACs (AC-1…AC-4) satisfied by updated prose.
- [ ] `grep "logic in #15"` → zero matches.
- [ ] `grep "MODE SWITCH"` → exactly one match inside Step 7f.
- [ ] `grep "no-verify"` → exactly one match inside Step 7g.
- [ ] Internal consistency check in implementation Step 3 passes.
- [ ] Plan + implementation doc committed under `docs/plans/issue-15/`.

> Build / lint / test: N/A — `.paadhai.json` stack is `none`; docs-only change.

## Brainstorming Decisions

| Q | Decision | SRS Ref |
|---|----------|---------|
| Q1 | Empty check commands treated as non-blocking | FR-04 AC-3 |
| Q2 | Verification gate FAIL also triggers revert | FR-06 + FR-04 AC-4, §6.3 |
| Q3 | Failing step does not commit in auto-commit; falls through to per-step G-06 after fix | FR-04 AC-4 |
| Q4 | Plain-text MODE SWITCH banner before per-step G-06 re-engages | FR-04 AC-4 |
| Q5 | No cross-session persistence; re-prompt on resume | FR-04, Q-02 (open) |
| Q6 | Code review stays binary PASS/FAIL; PASS = "no blocking issues" | FR-04 AC-3 |
| Q7 | dev-parallel path out of scope; commit_mode applies only to sequential Step 7 | FR-04 |
| Q8 | `--no-verify` forbidden; documented at 7g | §6.2 |

## ADR

Declined — no new technology, pattern, or breaking change.
