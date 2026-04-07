---
name: dev-audit
description: Use when reviewing a PR — architecture, security, and compatibility review with explicit sign-off
---

# dev-audit: Three-Dimension PR Audit

Architecture, security, and compatibility review of the PR with explicit human sign-off.

**Does NOT change project board status** — board update happens in `/dev-ship`.

---

## STEP 1 — Load Config

[READ] `.devflow.json` — hard stop if missing:

> No `.devflow.json` found. Run `/project-init` first.

[READ] `docs/plans/issue-<n>/plan.md` — derive issue number from current branch first.

Store:
- `{config.repo.develop_branch}`

---

## STEP 2 — Verify CI

[SHELL] Check CI status:
```bash
gh pr checks <pr-number>
```

If any check is red → stop:
> CI checks are failing. Fix CI first (run /dev-pr to diagnose).

If CI is green → proceed.

---

## STEP 3 — Get Diff

[SHELL] Get the PR diff (excluding docs/plans):
```bash
git diff origin/{config.repo.develop_branch}..HEAD -- . ':!docs/plans/'
```

---

## STEP 4 — Run Three Reviews

[PARALLEL][SMART-MODEL] Run all three reviews simultaneously:

### 4a — Architecture Review

Check:
- Layer violations (e.g., UI layer calling data layer directly)
- Coupling (tight dependencies that reduce testability)
- Naming consistency (methods, variables, files follow project conventions)
- Pattern alignment (new code follows existing architectural patterns)
- Separation of concerns (each component has one clear responsibility)

Report: **PASS** / **FAIL** with specific findings.

### 4b — Security Review

Check:
- Injection vulnerabilities (SQL, command, XSS, template)
- Hardcoded secrets or credentials
- Missing input validation on user-supplied data
- Authentication or authorization gaps
- Insecure dependencies (known CVEs in new packages)
- Sensitive data exposure in logs or responses

Report: **PASS** / **FAIL** with specific findings.

### 4c — Compatibility Review

Check:
- Breaking API changes (public interface changes without versioning)
- Dependency conflicts (new package versions conflicting with existing)
- Platform-specific code (assumes OS, file paths, env vars)
- Config schema breaks (changes to `.devflow.json` or similar config files)
- Migration requirements (schema changes needing database migrations)

Report: **PASS** / **FAIL** with specific findings.

---

## STEP 5 — Synthesize Report

Merge all three review findings into a unified report:

```
Audit Report — PR #<number>
════════════════════════════════════
Architecture   : PASS / FAIL
  - <finding>
  - <finding>

Security       : PASS / FAIL
  - <finding>
  - <finding>

Compatibility  : PASS / FAIL
  - <finding>
  - <finding>

Overall        : PASS / FAIL
════════════════════════════════════
```

---

## STEP 6 — Present Report + Sign-off

Display the full audit report.

**G-08: "Approve and proceed to merge? (yes / list fixes needed)"**

Wait for explicit decision.

- **Approved** → display handoff
- **Fixes requested** → implement fixes → commit → re-run full audit from Step 2

---

## STEP 7 — Handoff (on approval)

```
Audit complete. PR approved.
Next step: run /dev-ship to merge the PR.

PR     : #<number> <title>
Audit  : ✓ Architecture, Security, Compatibility
```
