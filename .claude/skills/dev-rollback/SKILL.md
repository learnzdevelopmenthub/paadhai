---
name: dev-rollback
description: Use when a bad release needs recovery — delete tag, revert merge, create hotfix branch, update board
---

# dev-rollback: Release Rollback

Recover from a bad release: delete the tag, revert the merge commit on main, create a hotfix branch.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.main_branch}` / `{config.repo.develop_branch}`
- `{config.branches.fix}`

---

## STEP 2 — Identify Release

Ask user:
> "Which version to roll back? (e.g., v0.2.0)"

[SHELL] Verify tag exists:
```bash
git tag --list "<version>"
```

If tag not found → stop:
> Tag `<version>` not found. Check `git tag --list` for available tags.

[SHELL] Find the merge commit on main for this release:
```bash
git log {config.repo.main_branch} --merges --oneline -5
```

Display:
```
Release Identified
═══════════════════════════
Tag          : <version>
Merge commit : <sha> <message>
Date         : <date>
```

---

## STEP 3 — Impact Assessment

[SHELL] Check commits after this tag on main:
```bash
git log <version>..{config.repo.main_branch} --oneline
```

[SHELL] Check if develop has diverged since the back-merge:
```bash
git log <version>..{config.repo.develop_branch} --oneline
```

Display:
```
Impact Assessment
═══════════════════════════
Commits after tag on main  : <count>
Develop divergence         : <count> commits
Risk                       : <LOW if 0 commits after / HIGH if commits exist>
```

If commits exist after the tag on main:
> WARNING: There are <count> commits on main after this tag. Rolling back will also revert these commits. Consider a hotfix instead.

---

## STEP 4 — Rollback Plan

Display the exact actions that will be taken:

```
Rollback Plan for <version>
═══════════════════════════
1. Delete GitHub Release for <version>
2. Delete tag <version> (local + remote)
3. Revert merge commit <sha> on {config.repo.main_branch}
4. Push revert to {config.repo.main_branch}
5. Create hotfix branch: {config.branches.fix}<version>-rollback
6. Push hotfix branch
```

---

## STEP 5 — Rollback Gate

**G-14: "Execute rollback? This deletes the tag and reverts the merge. (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

---

## STEP 6 — Execute Rollback (after G-14)

All steps execute in sequence — stop on first failure.

[SHELL] Delete GitHub Release:
```bash
gh release delete <version> --yes
```

[SHELL] Delete tag locally and remotely:
```bash
git tag -d <version>
git push origin :refs/tags/<version>
```

[SHELL] Revert merge commit on main:
```bash
git checkout {config.repo.main_branch}
git pull origin {config.repo.main_branch}
git revert -m 1 <merge-commit-sha> --no-edit
git push origin {config.repo.main_branch}
```

[SHELL] Create hotfix branch:
```bash
git checkout -b {config.branches.fix}<version>-rollback
git push -u origin {config.branches.fix}<version>-rollback
```

---

## STEP 7 — Summary

Display:
```
Rollback Complete
═══════════════════════════
Tag deleted      : <version> (local + remote)
Release deleted  : <version> on GitHub
Merge reverted   : <sha> on {config.repo.main_branch}
Hotfix branch    : {config.branches.fix}<version>-rollback
```

---

## STEP 8 — Handoff

```
Rollback complete. Hotfix branch is ready.

Branch  : {config.branches.fix}<version>-rollback
Action  : Fix the issue on this branch, then run /dev-pr to open a PR.
```
