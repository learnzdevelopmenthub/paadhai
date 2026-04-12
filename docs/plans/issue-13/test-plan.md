---
issue: 13
title: Add verification gate to dev-parallel and document in claude-tools.md
branch: feature/13-add-verification-gate-dev-parallel
status: approved
approved_at: 2026-04-11
---

# Test Plan — Issue #13

## Test Framework

**None (markdown skills project).** `.paadhai.json` → `stack.language: none`. No runtime build/lint/test commands exist. Verification is performed via:

1. **Structural checks** — `Grep` / `Read` assertions against the modified files.
2. **AC verification matrix** — each AC maps to a specific structural check that proves it.
3. **Manual review** — verbatim diff of the `[VERIFY]` convention text in `claude-tools.md` against the source of truth in `dev-implement/SKILL.md`.
4. **Implementation-doc reviewer** (dev-plan Step 14) + PR review (dev-pr) as secondary gates.

No stub files are generated — there is no runtime to stub.

---

## Structural Checks

### A. `references/claude-tools.md`

| # | Check | Command | Expected |
|---|-------|---------|----------|
| A1 | `[VERIFY]` marker row exists in the main marker table | `Grep "^\| \`\[VERIFY\]\`"` in `references/claude-tools.md` | 1 match |
| A2 | `[VERIFY]` row sits between `[PROGRESS]` and the `Subagent Support` section | `Read` lines around the insertion point | `[VERIFY]` appears after `[PROGRESS]` and before `Subagent Support` header |
| A3 | `## [VERIFY] Convention` section exists | `Grep "^## \[VERIFY\] Convention"` | 1 match |
| A4 | Convention section contains all 5 gate steps | `Grep "IDENTIFY"`, `"RUN"`, `"READ"`, `"VERIFY"`, `"CLAIM"` scoped to `claude-tools.md` | all 5 present |
| A5 | Convention section contains red-flag list | `Grep "Red flags"` in `claude-tools.md` | 1 match |
| A6 | Convention section contains PASS format block | `Grep "GATE: PASS"` in `claude-tools.md` | ≥1 match |
| A7 | Convention section contains FAIL format block | `Grep "GATE: FAIL"` in `claude-tools.md` | ≥1 match |
| A8 | Docs-only edge case documented | `Grep -i "docs-only"` in `claude-tools.md` | ≥1 match |

### B. `.claude/skills/dev-parallel/SKILL.md`

| # | Check | Command | Expected |
|---|-------|---------|----------|
| B1 | Preamble shows `15 steps` (not `14 steps`) | `Grep "14 steps"` + `Grep "15 steps"` in `dev-parallel/SKILL.md` | 0 matches for `14 steps`, ≥2 matches for `15 steps` |
| B2 | TodoWrite checklist has 15 items numbered `Step N/15` | `Grep "Step .*/15:"` in `dev-parallel/SKILL.md` | ≥15 matches |
| B3 | No stale `Step N/14` references remain | `Grep "Step .*/14"` in `dev-parallel/SKILL.md` | 0 matches |
| B4 | New `## STEP 8 — Validate Subagent Reports` header exists | `Grep "^## STEP 8 — Validate Subagent Reports"` | 1 match |
| B5 | Step 8 contains 3 named checks (Presence, Evidence, Hedging) | `Grep "Presence"`, `"Evidence"`, `"Hedging"` scoped to Step 8 | all 3 present |
| B6 | Step 8 contains verify-only re-dispatch logic with 1-retry cap | `Grep -i "verify-only"` + `Grep "1 retry"` or `"retry cap"` | ≥1 match each |
| B7 | Step 8 contains escalation prompt (`retry / manual / abort`) | `Grep "retry.*manual.*abort"` | 1 match |
| B8 | Old Step 14 Handoff renamed to Step 15 | `Grep "^## STEP 15 — Handoff"` | 1 match |
| B9 | 2 new rationalization rows present | `Grep "trust it without inspecting"` + `Grep "partial evidence"` or `"One missing claim"` | 1 match each |
| B10 | Step 4 subagent prompt references `[VERIFY]` gate | `Grep "\[VERIFY\]"` in `dev-parallel/SKILL.md` | ≥1 match inside Step 4 block |
| B11 | Step 4 report format example includes `GATE: PASS` block | `Grep "GATE: PASS"` in `dev-parallel/SKILL.md` | ≥1 match inside Step 4 block |
| B12 | All `[PROGRESS]` markers use `/15` numbering consistently | `Grep "\[PROGRESS\].*Step .*/"` → count `/15` vs `/14` | all `/15`, zero `/14` |

### C. Cross-file consistency

| # | Check | Method | Expected |
|---|-------|--------|----------|
| C1 | `[VERIFY]` convention text in `claude-tools.md` matches the canonical gate in `dev-implement/SKILL.md § VERIFICATION GATE` | Manual read + diff of 5-step definition, red-flag list, PASS/FAIL format | byte-identical semantic content (headings may differ) |
| C2 | `dev-parallel` Step 4 does NOT duplicate the full gate text — only references it | `Grep -c "IDENTIFY"` in `dev-parallel/SKILL.md` | 0 matches (gate text lives only in `claude-tools.md` and `dev-implement/SKILL.md`) |

---

## AC Verification Matrix

| AC | Requirement | Proven by |
|----|-------------|-----------|
| **AC-1** | Gate added to dev-parallel, executed per-subagent before accept | B4 (Step 8 exists) + B10 (subagent prompt runs `[VERIFY]`) + B11 (report format requires `GATE: PASS`) |
| **AC-2** | Completion messages must include quoted verification output; reject without | B5 (Presence + Evidence checks in Step 8 validator) |
| **AC-3** | Hedging → re-dispatch with explicit verify instruction | B5 (Hedging check) + B6 (verify-only re-dispatch) + B7 (escalation on 2nd failure) |
| **AC-4** | `[VERIFY]` reusable pattern in `claude-tools.md` | A1 (marker row) + A2 (placement) + A3 (convention section) |
| **AC-5** | 5 gate steps + red-flag list documented | A4 (all 5 steps present) + A5 (red-flag list) + A6 (PASS format) + A7 (FAIL format) + C1 (matches canonical source) |

---

## Test Categories Summary

| Category | Count |
|----------|-------|
| Structural — claude-tools.md (A1–A8) | 8 |
| Structural — dev-parallel/SKILL.md (B1–B12) | 12 |
| Cross-file consistency (C1–C2) | 2 |
| **Total checks** | **22** |

Mapped to ACs: **5 ACs, 100% covered** (see AC Verification Matrix).

---

## Coverage Target

Not applicable (no runtime code). Coverage is instead defined as:

- **100% of structural checks pass** before merging
- **100% of ACs have at least one proving check**
- **Manual review (C1) passes** — `[VERIFY]` convention text is verbatim-equivalent to the canonical gate in `dev-implement/SKILL.md`

---

## How to Execute This Test Plan

During `/paadhai:dev-implement`:

1. The implementation-doc reviewer (dev-plan Step 14 equivalent) already approved the impl doc.
2. After each impl step, the dev-implement VERIFICATION GATE runs `Read`/`Grep` to verify the step's claim (this test plan supplies the exact commands).
3. After the final commit, run each check in the tables above as a sanity sweep.
4. During `/paadhai:dev-pr`, reviewer re-runs C1 manually before approving.