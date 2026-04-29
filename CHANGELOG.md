# Changelog

## v2.3.0 — 2026-04-29

### Skill consolidation (breaking)
- **Merge `dev-debug` into `dev-unblock`** — single skill auto-classifies failures (conflict | test | lint | type | build) and escalates to 4-phase systematic debugging when root cause is unclear. `/dev-debug` is removed.
- **Fold `dev-hotfix` and `dev-rollback` into `dev-release`** as `--mode=hotfix` and `--mode=rollback`. `/dev-hotfix` and `/dev-rollback` are removed; `/dev-release` now covers the full release lifecycle.
- Net result: 22 skills → 19 skills.

### Spec-first planning (Kiro-style)
- **`dev-plan`** now emits three artifacts at the issue level:
  - `requirements.md` — EARS-format acceptance criteria with stable REQ-IDs
  - `design.md` — architecture, data contracts, key decisions, security
  - `tasks.md` — atomic task groups with `parallel: true|false` flags
- Replaces the previous `plan.md` + `implementation.md` two-doc format. Templates added under `templates/`.
- Legacy projects: `dev-test`, `dev-implement`, `dev-parallel` detect old format and warn with migration guidance.

### Auto-routing for parallel work
- **`dev-implement`** reads `tasks.md` and auto-routes parallel-flagged groups to `/dev-parallel` — no more manual dispatch decision. Sequential groups run inline; parallel groups dispatch a subagent each.
- **`dev-parallel`** detects caller via `PAADHAI_CALLER` env. Single-group mode (called by dev-implement) skips group derivation; multi-group mode (direct invocation) filters tasks.md to parallel-flagged groups.

### Hooks + deterministic rules
- New `references/git-rules.md` — eight cross-IDE deterministic git rules (R-G1 through R-G8) covering conventional commits, force-push protection, no `git add -A`, secret scan, etc.
- New `.claude-plugin/hooks.json` template — Claude Code-specific PreToolUse/PostToolUse hooks that enforce R-G1, R-G2, R-G3, R-G4, R-G6 deterministically. Optional, install via project-init.

### Token reduction
- VERIFICATION GATE block in `dev-implement` deduplicated — references `claude-tools.md § [VERIFY] Convention` instead of inlining the full spec.

### Migration notes
- Existing `docs/plans/issue-N/plan.md` + `implementation.md` continue to work. Skills auto-detect and warn. Re-run `/dev-plan` on an issue to regenerate as the new three-artifact schema.
- Slash commands `/dev-debug`, `/dev-hotfix`, `/dev-rollback` no longer exist. Update any aliases or scripts.

## v2.2.0 — 2026-04-12

### Features
- Add [VERIFY] gate and document in claude-tools.md (ec43814) (#13)
- Add 5-step verification gate to dev-implement (09d295d) (#12)
- Add rationalization prevention tables to dev-implement, dev-plan, dev-parallel (c3d21bb) (#11)

## v2.1.0 — 2026-04-08

### Features
- Add per-step progress dashboard to dev-implement (e1e3c40) (#19)
- Implement skill invocation announcement banners (c6c2769) (#18)
- Add [PROGRESS] marker and TodoWrite step tracking to multi-step skills (e10c94c) (#17)

### Bug Fixes
- Fix project-init: create repo before project, use node query, explicit link step (e6bcf6b)

### Documentation
- Add confirmed SRS for v2.0 (e50c1ea)

### Chores
- Bump project_version to 2.0 (884e22e)
- Remove docs/srs.md from .gitignore (7809863)
