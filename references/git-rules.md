# Paadhai — Deterministic Git Rules

> Rules that should be enforced deterministically (never bypassed by an agent's reasoning), regardless of which IDE or AI agent is in use.
>
> **Claude Code users** can install these as `settings.json` hooks (see `.claude-plugin/hooks.json` template). For other IDEs, treat this file as advisory and reference it from skills that perform git operations.

---

## R-G1: Conventional commits

Every commit message body must match one of:
- `<type>(<scope>): <subject>` — preferred
- `<type>: <subject>` — acceptable when scope is obvious

Allowed `<type>` values: `feat`, `fix`, `perf`, `refactor`, `test`, `chore`, `docs`, `ci`, `build`, `style`, `revert`.

Subject: max 72 chars, imperative mood ("add X" not "added X"), no trailing period.

**Why deterministic:** changelog generation in `/paadhai:dev-release` parses these prefixes to bucket commits. Mis-formatted commits silently drop from the changelog.

## R-G2: Never force-push to main or develop

Force pushing (`git push --force` / `--force-with-lease`) is forbidden against `{config.repo.main_branch}` and `{config.repo.develop_branch}`. Skills that re-write history (`git commit --amend` then push) must target a feature/fix branch only.

**Why deterministic:** force pushes overwrite shared history. Once main or develop is rewritten, every collaborator's local clone breaks.

## R-G3: Specific files, never `git add -A`

Skills must stage specific files by name:
```bash
git add src/auth.ts src/types.ts
```

Forbidden:
```bash
git add -A
git add .
git add --all
```

**Why deterministic:** `-A` accidentally stages secrets, large binaries, IDE state, or experimental scratch files. Specific staging makes commits reviewable.

## R-G4: No `--no-verify`, no `--no-gpg-sign`, no `-c commit.gpgsign=false`

These flags bypass pre-commit hooks (lint, format, secret scan) and signature requirements. They are forbidden unless the user explicitly authorizes it for this exact commit.

**Why deterministic:** pre-commit hooks are the project's last line of defense. Bypassing them for a "small fix" is how regressions ship.

## R-G5: Never commit without explicit user authorization

Skills may stage files, run commands, and produce diffs. They must wait for an explicit "yes" or "commit it" from the user before invoking `git commit`, unless the user has pre-authorized batch/auto-commit mode for this session via `/paadhai:dev-implement`'s commit-mode selector.

**Why deterministic:** the user's mental model of the working tree is the ground truth. Surprise commits rotate the tree out from under them.

## R-G6: Refs `#<issue>` in commit body

Every feature, fix, or test commit on a feature/fix branch must end with:
```
Refs #<issue-number>
```

`Fixes #<n>` is acceptable when the commit fully resolves the issue.

**Why deterministic:** GitHub Projects automation, milestone reports, and `/paadhai:dev-release` changelog all parse `Refs #N` and `Fixes #N`.

## R-G7: Branch naming

| Branch type | Prefix | Source |
|------------|--------|--------|
| Feature | `{config.branches.feature}` | `{config.repo.develop_branch}` |
| Fix | `{config.branches.fix}` | `{config.repo.develop_branch}` |
| Hotfix | `{config.branches.fix}<id>-hotfix` | `{config.repo.main_branch}` |
| Release | `{config.branches.release}` | `{config.repo.develop_branch}` |
| Rollback recovery | `{config.branches.fix}<version>-rollback` | `{config.repo.main_branch}` |

Branch names embed the issue number when available: `feature/42-add-login`, `fix/57-null-pointer`. This lets every skill auto-derive issue context from `git branch --show-current`.

## R-G8: Secret scan before commit

Pre-commit hook should scan staged content for known secret patterns (AWS keys, GitHub tokens, OpenAI keys, private keys, `.env` lines with `password=`, etc.). If detected, abort with the matching pattern and file path.

**Why deterministic:** an agent reading `.env` and including a snippet in a commit message has happened before. The hook is the last guard.

---

## Reference list (for use in skills)

When a skill performs git operations, it should mention which rules apply, e.g.:
```
Commit follows R-G1 (conventional), R-G3 (specific files), R-G6 (Refs #).
```

This makes it easy to audit skills for compliance and to detect drift over time.
