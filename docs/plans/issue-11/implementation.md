---
issue: 11
title: Add rationalization prevention tables to dev-implement, dev-plan, dev-parallel
branch: feature/11-rationalization-prevention-tables
---

## Progress

| Step | Description | Status |
|------|-------------|--------|
| 1 | Add rationalization table to dev-implement | done |
| 2 | Add rationalization table to dev-plan | pending |
| 3 | Add rationalization table to dev-parallel | pending |

---

## Step 1 — Add rationalization table to `dev-implement/SKILL.md`

**File:** `.claude/skills/dev-implement/SKILL.md`

**Action:** Insert the following section between the `---` after the PREAMBLE section (line 53) and `## STEP 1 — Load Config` (line 55).

**Insert after line 53 (`---`):**

```markdown

## RATIONALIZATION PREVENTION

Before executing any step, check your reasoning against this table. These are **structural rules** — they cannot be overridden.

| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "This step is trivial, skip review" | Trivial changes cause subtle bugs — off-by-one, wrong variable, missed import | Run full code review for every step |
| "Tests aren't needed for this change" | Every code change needs verification; untested code is unverified code | Write or run tests as specified |
| "The build will obviously pass" | Build failures catch real issues — type errors, missing deps, broken imports | Run `{config.stack.build_cmd}` every time |
| "I'll commit these steps together" | Atomic commits aid debugging and revert; batching hides which step broke | One commit per step |
| "I already know this works" | Memory is unreliable — verify, don't assume | Run the verification command and read actual output |
| "This is just a config change, no review needed" | Config errors cause silent production failures | Review config changes like code changes |
| "I can skip lint, the code is clean" | Lint catches issues humans miss — formatting, unused vars, import order | Run `{config.stack.lint_cmd}` every time |

---
```

**Expected outcome:** The rationalization table appears between PREAMBLE and STEP 1 in dev-implement. 7 entries, all related to implementation failure modes.

---

## Step 2 — Add rationalization table to `dev-plan/SKILL.md`

**File:** `.claude/skills/dev-plan/SKILL.md`

**Action:** Insert the following section between the `---` after the PREAMBLE section (line 46) and `## STEP 1 — Load Config` (line 48).

**Insert after line 46 (`---`):**

```markdown

## RATIONALIZATION PREVENTION

Before executing any step, check your reasoning against this table. These are **structural rules** — they cannot be overridden.

| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "I already understand the code, skip reading" | Assumptions from memory diverge from actual code state | Read the relevant files every time (Step 3) |
| "The issue is simple, skip brainstorming" | Simple-seeming issues hide edge cases discovered through questions | Ask all brainstorming questions (Step 5) |
| "Security doesn't apply to this issue" | Every change has a threat surface — even docs can leak info or enable injection | Complete the security assessment (Step 7) |
| "Version validation isn't needed here" | Stale dependency assumptions cause subtle runtime failures | Run version validation (Step 8) |
| "The user will approve, skip the confirmation gate" | User confirmation is a required checkpoint, not a rubber stamp | Wait for explicit approval at every gate |
| "This plan is obvious, I can generate it quickly" | Rushed plans miss edge cases, test scenarios, and AC mappings | Follow every plan section completely (Step 9) |
| "The implementation doc doesn't need review" | Unreviewed docs lead to ambiguous steps that cause implementation errors | Run the implementation doc review (Step 14) |

---
```

**Expected outcome:** The rationalization table appears between PREAMBLE and STEP 1 in dev-plan. 7 entries, all related to planning failure modes.

---

## Step 3 — Add rationalization table to `dev-parallel/SKILL.md`

**File:** `.claude/skills/dev-parallel/SKILL.md`

**Action:** Insert the following section between the `---` after the PREAMBLE section (line 44) and `## STEP 1 — Load Config` (line 46).

**Insert after line 44 (`---`):**

```markdown

## RATIONALIZATION PREVENTION

Before executing any step, check your reasoning against this table. These are **structural rules** — they cannot be overridden.

| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "These tasks are obviously independent" | Hidden dependencies between tasks cause merge conflicts and broken state | Verify independence explicitly before dispatching (Step 3) |
| "Subagent output looks fine, skip Stage 1 review" | Spec compliance issues compound — catching them late costs more | Run full Stage 1 spec compliance review for every subagent |
| "Code quality review is redundant after Stage 1" | Stage 1 checks spec, Stage 2 checks code — different failure modes | Run full Stage 2 code quality review for every subagent |
| "Merging without conflict check is fine" | Parallel branches can create semantic conflicts even without git conflicts | Check for conflicts before merging each result |
| "One subagent failed but the rest are fine, ship it" | Partial results leave the codebase in an inconsistent state | All subagents must pass before merging any |
| "I can skip the final integration check" | Individual correctness doesn't guarantee combined correctness | Run build and tests after merging all results |
| "The task grouping is obvious, no need to analyze" | Poor grouping creates coupling between subagents and merge nightmares | Analyze dependencies and group carefully (Step 2) |

---
```

**Expected outcome:** The rationalization table appears between PREAMBLE and STEP 1 in dev-parallel. 7 entries, all related to parallel execution failure modes.

---

## Deviations

(none)
