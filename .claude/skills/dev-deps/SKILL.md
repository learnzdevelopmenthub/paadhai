---
name: dev-deps
description: Use when auditing project dependencies — scan for CVEs, license violations, and outdated packages
---

# dev-deps: Dependency Audit

Scan project dependencies for security vulnerabilities, license compliance issues, and outdated packages.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/project-init` first.

Store:
- `{config.stack.language}`
- `{config.stack.build_cmd}` / `{config.stack.test_cmd}`
- `{config.repo.owner}` / `{config.repo.name}`

---

## STEP 2 — Detect Package Manager

Based on `{config.stack.language}` and lock files present:

| Language | Lock file | Tool |
|----------|-----------|------|
| JavaScript / TypeScript | `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` | npm / yarn / pnpm |
| Python | `Pipfile.lock` / `requirements.txt` / `pyproject.toml` | pip / pipenv / poetry |
| Rust | `Cargo.lock` | cargo |
| Go | `go.sum` | go modules |
| Ruby | `Gemfile.lock` | bundler |

[SHELL] Confirm detected package manager:
```bash
ls package.json package-lock.json yarn.lock pnpm-lock.yaml Pipfile Cargo.toml go.mod Gemfile 2>/dev/null
```

Display detected manager and proceed. If unrecognized → warn and ask user to confirm.

---

## STEP 3 — Vulnerability Scan (SCA)

[SHELL] Run vulnerability scan for detected package manager:

**npm:**
```bash
npm audit --json 2>/dev/null || echo '{"error":"npm audit failed"}'
```

**pip:**
```bash
pip-audit --format json 2>/dev/null || echo '{"error":"pip-audit not installed"}'
```

**cargo:**
```bash
cargo audit --json 2>/dev/null || echo '{"error":"cargo audit not installed"}'
```

**go:**
```bash
govulncheck ./... 2>/dev/null || echo 'govulncheck not installed'
```

If tool not installed → warn and skip gracefully:
> <tool> not installed. Skipping vulnerability scan. Install with: <install-command>

Categorize findings by severity: CRITICAL / HIGH / MEDIUM / LOW.

---

## STEP 4 — License Compliance

[SHELL] Check dependency licenses:

**npm:**
```bash
npx license-checker --json 2>/dev/null || echo '{"error":"license-checker unavailable"}'
```

**pip:**
```bash
pip-licenses --format=json 2>/dev/null || echo '{"error":"pip-licenses not installed"}'
```

**cargo:**
```bash
cargo license --json 2>/dev/null || echo '{"error":"cargo-license not installed"}'
```

Flag licenses requiring review: GPL, AGPL, LGPL (strong copyleft), unknown/unlicensed.

If tool not installed → warn and skip gracefully.

---

## STEP 5 — Outdated Packages

[SHELL] Check for outdated packages:

**npm:**
```bash
npm outdated --json 2>/dev/null || echo '{}'
```

**pip:**
```bash
pip list --outdated --format=json 2>/dev/null || echo '[]'
```

**cargo:**
```bash
cargo outdated --format json 2>/dev/null || echo '{"error":"cargo-outdated not installed"}'
```

**go:**
```bash
go list -m -u all 2>/dev/null | grep '\[' || echo 'no updates'
```

Separate: patch updates / minor updates / major updates.

---

## STEP 6 — Synthesize Report

Display consolidated report:

```
Dependency Audit Report
═══════════════════════════════════════
Package Manager : <detected>
Scan Date       : <today>

VULNERABILITIES
───────────────
CRITICAL : <count> packages
HIGH     : <count> packages
MEDIUM   : <count> packages
LOW      : <count> packages
Status   : <PASS / FAIL>

LICENSE COMPLIANCE
──────────────────
Copyleft (GPL/AGPL) : <count> — <list>
Unknown / Unlicensed : <count> — <list>
Status               : <PASS / WARNING / FAIL>

OUTDATED PACKAGES
─────────────────
Major updates : <count>
Minor updates : <count>
Patch updates : <count>
Status        : <PASS / INFO>

OVERALL : <PASS / WARNING / FAIL>
```

---

## STEP 7 — Auto-Fix Option

If CRITICAL or HIGH vulnerabilities found:

> Found <count> CRITICAL/HIGH vulnerabilities. Auto-fix? (yes / no / manual)
> - **yes** → run fix command, verify build + tests, revert if tests break
> - **no** → display manual fix instructions
> - **manual** → display the list and exit

If **yes**:

[SHELL] Run fix:
```bash
npm audit fix          # npm
pip install --upgrade <packages>  # pip
cargo update           # cargo
```

[SHELL] Verify fix didn't break anything:
```bash
{config.stack.build_cmd}
{config.stack.test_cmd}
```

If tests break → revert:
```bash
git restore package-lock.json  # or equivalent
```

Display fix result:
```
Auto-Fix Result
═══════════════════════════
Fixed    : <count> vulnerabilities
Remaining: <count> (require manual intervention)
Build    : <passing / failed — reverted>
Tests    : <passing / failed — reverted>
```

---

## STEP 8 — Handoff

```
Dependency audit complete.

Status   : <PASS / WARNING / FAIL>
Critical : <count>
Action   : <none needed / review flagged licenses / fix remaining vulns>

This is a standalone utility — no pipeline next step.
Re-run /dev-deps periodically or before each release.
```
