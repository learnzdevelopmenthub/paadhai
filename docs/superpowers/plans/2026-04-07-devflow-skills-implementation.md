# Paadhai Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete Paadhai tool — 10 generic AI agent skills covering the full SDLC, platform support files for 5 platforms, templates, and documentation.

**Architecture:** Each skill is a `SKILL.md` file with YAML frontmatter. Skills read `.paadhai.json` at runtime for all repo-specific values. Capability markers (`[READ]`, `[SHELL]`, `[DELEGATE]`, etc.) map to platform-native tools via reference files in `references/`.

**Tech Stack:** Markdown, YAML frontmatter, GitHub CLI (`gh`), bash, JSON

---

## File Structure

### Skills (`.claude/skills/`)
| File | Responsibility |
|------|---------------|
| `project-init/SKILL.md` | New/existing repo setup, write `.paadhai.json` |
| `project-plan/SKILL.md` | SRS generation from product idea |
| `release-plan/SKILL.md` | Break SRS into milestones + issues on GitHub |
| `dev-start/SKILL.md` | Issue intake, branch creation, board sync |
| `dev-plan/SKILL.md` | Brainstorm + plan + impl doc for an issue |
| `dev-implement/SKILL.md` | Execute impl doc step-by-step |
| `dev-pr/SKILL.md` | Push branch, open PR, poll CI |
| `dev-audit/SKILL.md` | Architecture + security + compatibility review |
| `dev-ship/SKILL.md` | Merge PR, update board, clean up branch |
| `dev-release/SKILL.md` | Release branch, tag, GitHub Release, back-merge |

### References (`references/`)
| File | Responsibility |
|------|---------------|
| `claude-tools.md` | Map capability markers to Claude Code tools |
| `cursor-tools.md` | Map capability markers to Cursor tools |
| `codex-tools.md` | Map capability markers to Codex CLI tools |
| `gemini-tools.md` | Map capability markers to Gemini CLI tools |

### Templates (`templates/`)
| File | Responsibility |
|------|---------------|
| `srs.md` | SRS template used by `/project-plan` |
| `pr-body.md` | PR body template used by `/dev-pr` |

### Platform Plugin Files
| File | Responsibility |
|------|---------------|
| `.claude-plugin/plugin.json` | Claude Code plugin manifest |
| `.claude-plugin/marketplace.json` | Claude Code marketplace metadata |
| `.cursor-plugin/plugin.json` | Cursor plugin manifest |
| `.cursor-plugin/marketplace.json` | Cursor marketplace metadata |
| `.codex-plugin/plugin.json` | Codex CLI plugin manifest |
| `.gemini/extensions/paadhai/gemini-extension.json` | Gemini CLI extension manifest |
| `CLAUDE.md` | Claude Code instruction/loader file |
| `AGENTS.md` | Universal instruction file (Cursor + Codex + OpenCode) |
| `GEMINI.md` | Gemini CLI context/loader file |

### Documentation (root)
| File | Responsibility |
|------|---------------|
| `README.md` | Install + quickstart for all platforms |
| `LICENSE` | MIT license |
| `CONTRIBUTING.md` | Open source contributor guide |

---

## Phase 0: Repository Initialization

### Task 0: Initialize git repository and project scaffolding

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Initialize git repo**

```bash
cd d:/Learnz/Projects/paadhai
git init
```

- [ ] **Step 2: Create .gitignore**

```
node_modules/
dist/
coverage/
*.log
.env
.DS_Store
Thumbs.db
```

- [ ] **Step 3: Create directory structure**

```bash
mkdir -p .claude/skills/project-init
mkdir -p .claude/skills/project-plan
mkdir -p .claude/skills/release-plan
mkdir -p .claude/skills/dev-start
mkdir -p .claude/skills/dev-plan
mkdir -p .claude/skills/dev-implement
mkdir -p .claude/skills/dev-pr
mkdir -p .claude/skills/dev-audit
mkdir -p .claude/skills/dev-ship
mkdir -p .claude/skills/dev-release
mkdir -p references
mkdir -p templates
mkdir -p .claude-plugin
mkdir -p .cursor-plugin
mkdir -p .codex-plugin
mkdir -p .opencode/skills
mkdir -p .opencode/plugins
mkdir -p .gemini/extensions/paadhai
```

- [ ] **Step 4: Initial commit**

```bash
git add .gitignore docs/srs.md
git commit -m "chore: initial project setup with SRS"
```

---

## Phase 1: Refactor Existing Skills (Generic Config)

All 4 existing skills must be rewritten to:
1. Read `.paadhai.json` at Step 1 (hard stop if missing, except `project-init`)
2. Replace ALL hardcoded values with config references: `{config.repo.owner}`, `{config.repo.name}`, `{config.github.project_id}`, `{config.stack.build_cmd}`, etc.
3. Add capability markers to every action (`[READ]`, `[SHELL]`, `[DELEGATE]`, etc.)
4. Use `{config.branches.feature}` instead of hardcoded `feature/`
5. Use `{config.repo.develop_branch}` instead of hardcoded `develop`

---

### Task 1: Rewrite `dev-start/SKILL.md`

**Files:**
- Modify: `.claude/skills/dev-start/SKILL.md`

**Current state:** 6 steps, hardcoded to `learnzdevelopmenthub/ninaivagam`, hardcoded project IDs (`PVT_kwHOCLuofc4BTYOm`, `PVTSSF_lAHOCLuofc4BTYOmzhAoxz4`, `47fc9ee4`, `98236657`).

**Target state:** 10 steps per SRS 4.4. All values from `.paadhai.json`.

- [ ] **Step 1: Read existing file**

Read `.claude/skills/dev-start/SKILL.md` to understand current structure.

- [ ] **Step 2: Rewrite the skill file**

The new file must have this exact structure:

```markdown
---
name: dev-start
description: Use when starting development — issue intake, pre-flight checks, branch creation, and project board sync
---

# dev-start: Issue Intake + Branch Creation

Pick an issue, run pre-flight checks, create the feature branch, move the issue to "In Progress".

**Status tracking:** This skill moves the issue to "In Progress" on the project board (after G-04 approval).

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/project-init` first.

Store config values for use throughout:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}`
- `{config.github.project_id}` / `{config.github.status_field_id}`
- `{config.github.statuses.in_progress}`
- `{config.branches.feature}`

---

## STEP 2 — Fetch Issue

If user provided an issue number:

[SHELL] Fetch issue details:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> \
  --jq '{number: .number, title: .title, milestone: .milestone.title, labels: [.labels[].name], body: .body}'
```

If NO issue number provided:

[SHELL] List open issues — ask user to pick:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/issues?state=open&per_page=20" \
  --jq '.[] | "#\(.number) [\(.milestone.title)] \(.title)"'
```

Display:
```
Issue #<number>: <title>
Milestone : <milestone>
Labels    : <labels>
```

---

## STEP 3 — Pre-flight Checks

[SHELL] Check working tree and branch:
```bash
git status
git branch --show-current
```

- If not on `{config.repo.develop_branch}` → switch to it
- If dirty state → offer to stash: `git stash push -m "paadhai: pre dev-start"` or stop

[SHELL] Ensure develop is up to date:
```bash
git fetch origin && git pull origin {config.repo.develop_branch}
```

[SHELL] Check if branch already exists:
```bash
git branch --list "{config.branches.feature}<number>-*"
```
→ If yes: ask user to switch or delete it.

---

## STEP 4 — Derive Branch Name

Format: `{config.branches.feature}{issue-number}-{short-kebab-case-title}`
- Max 50 chars total
- Lowercase, hyphens only, no special characters
- Strip articles: a, an, the, and, or, for, with, to

---

## STEP 5 — Action Summary + Human Gate

Display:
```
Issue   : #<number> <title>
Branch  : {branch-name}
Board   : Will move to "In Progress"
```

**G-04: "Create branch and start issue? (yes/no)"**

Wait for explicit user confirmation. Do not proceed without "yes".

---

## STEP 6 — Execute (after G-04 approval)

All actions execute automatically after approval — no intermediate confirmations.

[DELEGATE][FAST-MODEL] Execute all at once:

**6a. Create branch and push:**
```bash
git checkout -b {branch-name}
git push -u origin {branch-name}
```

**6b. Move issue to "In Progress" on project board:**
```bash
ITEM_ID=$(gh api graphql \
  -f query='{ repository(owner: "{config.repo.owner}", name: "{config.repo.name}") { projectsV2(first: 1) { nodes { items(first: 100) { nodes { id content { ... on Issue { number } } } } } } } }' \
  --jq '.data.repository.projectsV2.nodes[0].items.nodes[] | select(.content.number == <number>) | .id')

gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"{config.github.project_id}\", itemId: \"$ITEM_ID\", fieldId: \"{config.github.status_field_id}\", value: { singleSelectOptionId: \"{config.github.statuses.in_progress}\" } }) { projectV2Item { id } } }"
```

If GraphQL fails, warn but do not block — branch creation is the critical path.

---

## STEP 7 — Display Results

```
✓ Branch created : {branch-name}
✓ Tracking       : origin/{branch-name}
✓ Project board  : #<number> → In Progress
```

---

## STEP 8 — Handoff

```
Branch is ready. Next step: run /dev-plan to create the implementation plan.

Issue   : #<number> <title>
Branch  : {branch-name}
Project : In Progress ✓
```

Do not start planning or implementation here. This skill's job is done.
```

- [ ] **Step 3: Verify no hardcoded values remain**

Search the written file for any of: `learnzdevelopmenthub`, `ninaivagam`, `PVT_kw`, `PVTSSF_`, `47fc9ee4`, `98236657`. Must find zero matches.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/dev-start/SKILL.md
git commit -m "refactor(dev-start): replace hardcoded values with .paadhai.json config

All repo names, project IDs, status field IDs, and branch prefixes
now read from .paadhai.json at Step 1."
```

---

### Task 2: Rewrite `dev-plan/SKILL.md`

**Files:**
- Modify: `.claude/skills/dev-plan/SKILL.md`

**Current state:** 8 steps, hardcoded to `learnzdevelopmenthub/ninaivagam`, uses `npm run build/lint/test`.

**Target state:** 16 steps per SRS 4.5. Generic config, capability markers, stack-agnostic commands.

- [ ] **Step 1: Read existing file**

Read `.claude/skills/dev-plan/SKILL.md`.

- [ ] **Step 2: Rewrite the skill file**

The new file must have this structure:

```yaml
---
name: dev-plan
description: Use when planning GitHub issues — brainstorm, design review, version validation, generate plan + implementation doc
---
```

**Key sections to include (in order):**

1. **STEP 1 — Load Config**: `[READ] .paadhai.json` — hard stop if missing. Store `{config.repo.owner}`, `{config.repo.name}`, `{config.stack.build_cmd}`, `{config.stack.lint_cmd}`, `{config.stack.test_cmd}`.

2. **STEP 2 — Identify Issue**: `[SHELL]` `git branch --show-current` → derive issue number. `[SHELL]` Fetch issue via `gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number>`.

3. **STEP 3 — Read Relevant Code**: `[DELEGATE][FAST-MODEL]` Read existing source files relevant to the issue (based on labels/title). Do not skip — makes questions and plan accurate.

4. **STEP 4 — Scope Validation**: Check clarity (one-sentence description), feasibility (ACs, blockers), architecture fit (new feature vs bug fix vs refactor). If unclear → ask user.

5. **STEP 5 — Brainstorming Questions**: Ask 5–7 targeted questions one at a time. Tailor to issue labels (`api`, `db`, `test`, `auth`, `infra`). Always ask: relevant ACs from SRS? Anything about existing codebase? Alignment with patterns?

6. **STEP 6 — Design Review**: Read 2-3 similar implementations. Check: pattern alignment, tradeoffs, architectural implications, standards compliance.

7. **STEP 7 — Version Validation**: `[DELEGATE][FAST-MODEL]` `[SEARCH]` current stable versions of core packages. Check breaking changes, config compatibility, platform-specific issues. Skip for well-known stable APIs.

8. **STEP 8 — Generate Plan**: Structured plan with: Overview, Files to Create, Files to Modify, Implementation Steps (4-10), Test Cases, AC Mapping, Definition of Done. DoD includes `{config.stack.build_cmd}`, `{config.stack.lint_cmd}`, `{config.stack.test_cmd}` (not hardcoded npm commands).

9. **STEP 9 — Present Plan**: Show plan. Say: "Does this plan look correct? Approve it or tell me what to change." **G-05 (plan approval).**

10. **STEP 10 — Confirmation Loop**: Approve → save. Changes → update → re-present. Question → answer → update.

11. **STEP 11 — Save Plan**: Write to `docs/plans/issue-<n>/plan.md` with YAML header (issue, title, branch, milestone, status: confirmed, confirmed_at).

12. **STEP 12 — Generate Implementation Doc**: `docs/plans/issue-<n>/implementation.md`. Every step has: exact command/code, expected output, status (`pending`/`done`). Progress table. Deviations section. Must reflect version validation.

13. **STEP 13 — Review Implementation Doc**: `[DELEGATE][SMART-MODEL]` Reviewer checks: all steps complete with exact commands? File contents missing? Technical errors? Expected output defined? Could a low-context model follow without guessing? PASS/FAIL only. Fix and retry until PASS.

14. **STEP 14 — User Confirms Implementation Doc**: Present doc. **G-05 (impl doc approval).** Wait for explicit confirmation.

15. **STEP 15 — Commit**: Commit plan + impl doc.

16. **STEP 16 — Handoff**: "Run /dev-implement (fast model recommended since doc is fully detailed)."

**Critical rules:**
- ALL `gh api` calls use `{config.repo.owner}/{config.repo.name}` — zero hardcoded repo names
- ALL build/lint/test commands use `{config.stack.*}` — not `npm run X`
- ALL branch references use `{config.repo.develop_branch}` — not `develop`
- Capability markers on every action

- [ ] **Step 3: Verify no hardcoded values**

Search for: `learnzdevelopmenthub`, `ninaivagam`, `npm run build`, `npm run lint`, `npm test`, `npm run test`. Must find zero.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/dev-plan/SKILL.md
git commit -m "refactor(dev-plan): replace hardcoded values with .paadhai.json config

All repo names, stack commands, and branch names now read from config.
Added capability markers to all actions per SRS 4.5."
```

---

### Task 3: Rewrite `dev-implement/SKILL.md`

**Files:**
- Modify: `.claude/skills/dev-implement/SKILL.md`

**Current state:** Mostly generic but hardcodes `npm run build/lint/test`. Missing `.paadhai.json` read step. No capability markers.

**Target state:** Per SRS 4.6. Config-driven, capability markers, resumable.

- [ ] **Step 1: Read existing file**

- [ ] **Step 2: Rewrite the skill file**

```yaml
---
name: dev-implement
description: Use when implementing confirmed plans — execute steps with code review, auto-commit, and subagent delegation
---
```

**Key sections:**

1. **STEP 1 — Load Config**: `[READ] .paadhai.json`. Store `{config.stack.build_cmd}`, `{config.stack.lint_cmd}`, `{config.stack.test_cmd}`.

2. **Resumption block**: If user says "continue", read impl doc → find first `pending` step → check `git status` for uncommitted work → resume. Never re-do `done` steps.

3. **STEP 2 — Load Implementation Doc**: Derive issue from branch. `[READ]` impl doc + plan. Display: issue, branch, step count, doc path. Ask: model preference, auto-commit mode.

4. **STEP 3 — Analyze Task Dependencies**: Scan for sequential vs independent patterns. Offer subagent-driven if 3+ independent tasks with <20% dependencies.

5. **STEP 4 — Choose Execution Path**: If independent-heavy → offer subagent-driven or sequential. If sequential-heavy → sequential only. If mixed → offer choice.

6. **STEP 5 — Pre-Implementation Check**: `[SHELL]` Verify correct branch + clean state.

7. **STEP 6 — Route**: If subagent-driven → hand off to `superpowers:subagent-driven-development`. If sequential → continue to Step 7.

8. **STEP 7 — Implementation Loop** (per step):
   - 7a: `[READ]` files before modifying
   - 7b: `[DELEGATE]` Implement (model per user choice)
   - 7c: `[DELEGATE][SMART-MODEL]` Code review (skip for config/docs/deps). PASS/FAIL. Fix until PASS.
   - 7d: `[SHELL]` `{config.stack.build_cmd}` + `{config.stack.lint_cmd}` (skip if no source changed)
   - 7e: Update impl doc (mark `done`, add deviation)
   - 7f: Show step summary. **G-06** or auto-commit.
   - 7g: `[SHELL]` Commit — specific files, conventional format, `Refs #<number>`

9. **STEP 8 — Full Test Run**: `[SHELL]` `{config.stack.build_cmd}` + `{config.stack.lint_cmd}` + `{config.stack.test_cmd}`. Fix failures before proceeding.

10. **STEP 9 — Summary**: Commits made, test results, lint, build.

11. **STEP 10 — Handoff**: "Run /dev-pr to open the pull request."

**Commit format table:** feat, fix, test, chore, refactor, docs, perf. Subject max 72 chars, imperative mood. Always `Refs #<number>`.

- [ ] **Step 3: Verify no hardcoded values**

Search for `npm run`, hardcoded branch names. Must find zero.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/dev-implement/SKILL.md
git commit -m "refactor(dev-implement): add config loading and capability markers

Stack commands now read from .paadhai.json. Added [READ], [SHELL],
[DELEGATE], [SMART-MODEL] markers per SRS 4.6."
```

---

### Task 4: Replace `dev-ship/SKILL.md` (strip to SRS 4.9 only)

**Files:**
- Modify: `.claude/skills/dev-ship/SKILL.md`

**Current state:** Combines dev-pr + dev-audit + dev-ship + dev-release into one 9-step monster. Hardcoded to ninaivagam.

**Target state:** Per SRS 4.9 ONLY — merge PR, update board, clean up branch. The PR, audit, and release functionality moves to separate skills in Phase 2.

- [ ] **Step 1: Read existing file**

- [ ] **Step 2: Rewrite the skill file**

```yaml
---
name: dev-ship
description: Use when shipping — merge PR to develop, update project board, clean up feature branch
---
```

**Key sections (SRS 4.9):**

1. **STEP 1 — Load Config**: `[READ] .paadhai.json`. Store all needed config values.

2. **STEP 2 — Display Context**: PR number, title, target branch (`{config.repo.develop_branch}`).

3. **STEP 3 — Final Confirmation**: **G-09: "Merge PR #<n> to {config.repo.develop_branch}? (yes/no)"**. Wait for explicit approval.

4. **STEP 4 — Execute (after G-09)**: All at once, no intermediate confirmations:
   - `[DELEGATE][FAST-MODEL]` Squash merge PR: `gh pr merge <pr-number> --squash --delete-branch`
   - `[DELEGATE][FAST-MODEL]` Move board to "Done": GraphQL mutation using `{config.github.project_id}`, `{config.github.status_field_id}`, `{config.github.statuses.done}`

5. **STEP 5 — Local Cleanup**:
   - `[SHELL]` `git checkout {config.repo.develop_branch} && git pull origin {config.repo.develop_branch}`
   - `[SHELL]` Delete local feature branch

6. **STEP 6 — Display Results**: Commits merged, issue closed, board updated.

7. **STEP 7 — Milestone Check**: `[SHELL]` Check if all milestone issues are closed.
   - If open remain → show remaining, suggest next `/dev-start`
   - If all closed → "All issues closed. Run /dev-release when ready."

- [ ] **Step 3: Verify — no PR creation, no audit, no release logic remains**

The file must NOT contain: `gh pr create`, `git diff` for review, audit/security/architecture review, `git tag`, `gh release`, release branch logic.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/dev-ship/SKILL.md
git commit -m "refactor(dev-ship): strip to merge-only per SRS 4.9

Removed PR creation (now /dev-pr), audit (now /dev-audit), and
release (now /dev-release). All config from .paadhai.json."
```

---

## Phase 2: Create New Skills

---

### Task 5: Create `project-init/SKILL.md`

**Files:**
- Create: `.claude/skills/project-init/SKILL.md`

- [ ] **Step 1: Write the skill file**

```yaml
---
name: project-init
description: Use when setting up a new or existing project — verify GitHub access, initialize repo, write .paadhai.json
---
```

**Key sections (SRS 4.1 + 4.1.1):**

1. **STEP 1 — Verify Prerequisites**:
   - `[SHELL]` `gh auth status` — display authenticated account. If fails → stop, show `gh auth login`.
   - `[SHELL]` Check if git repo exists (`git rev-parse --is-inside-work-tree`). If not → `git init`.

2. **STEP 2 — Detect Existing Project**:
   - `[SHELL]` Check for GitHub remote: `git remote get-url origin`
   - If remote exists → switch to **Existing Project Flow** (Step 2b)
   - If no remote → continue with **New Project Flow** (Step 3)

   **Step 2b — Existing Project Detection:**
   - `[SHELL]` Extract `owner/repo` from remote URL
   - `[SHELL]` Verify repo on GitHub: `gh repo view {owner/repo}`
   - `[DELEGATE][FAST-MODEL]` Auto-detect: default branch, `develop` branch exists?, open milestones, open issues, project boards

3. **STEP 3 — Gather Project Info** (single input round):
   - New: repo name, visibility (public/private), branch strategy (develop→main default), language/framework, build/lint/test commands, project board (new or existing)
   - Existing: pre-fill detected values, ask user to confirm or override

4. **STEP 4 — Discover Project Board IDs** (if using existing board):
   - `[DELEGATE][FAST-MODEL]` `gh project list --owner {owner}` → find project
   - `[DELEGATE][FAST-MODEL]` Query project field IDs via GraphQL

5. **STEP 5 — Action Summary + Human Gate**:
   - Display ALL planned actions: repo to create (or existing), `.paadhai.json` full content, branch to push, project board action
   - For existing projects: clearly mark what already exists (no action) vs what will be created
   - **G-01: "Proceed with setup? (yes/no)"**

6. **STEP 6 — Execute (after G-01)**:
   All at once after approval:
   - `[WRITE]` `.paadhai.json` to project root
   - `[SHELL]` Create GitHub repo (new) or skip (existing)
   - `[SHELL]` Create `develop` branch if missing, push
   - `[DELEGATE][FAST-MODEL]` Create/link project board

7. **STEP 7 — Display Results**: Repo URL, branches, project board URL, `.paadhai.json` path.

8. **STEP 8 — Smart Handoff**:
   - New project → "Run /project-plan to define your requirements"
   - Existing, no SRS → "Run /project-plan"
   - Existing, SRS but no issues → "Run /release-plan"
   - Existing, issues exist → "Run /dev-start #<number>"

**`.paadhai.json` schema** (written by this skill, include full example in the skill):
```json
{
  "version": "1",
  "repo": { "owner": "", "name": "", "develop_branch": "develop", "main_branch": "main" },
  "github": { "project_id": "", "project_number": 0, "status_field_id": "", "statuses": { "todo": "", "in_progress": "", "done": "" } },
  "stack": { "language": "", "build_cmd": "", "lint_cmd": "", "test_cmd": "" },
  "branches": { "feature": "feature/", "fix": "fix/", "release": "release/" }
}
```

**Error handling:**
- `gh` not installed → stop, show install instructions
- Auth fails → stop, show `gh auth login`

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/project-init/SKILL.md
git commit -m "feat(project-init): add project initialization skill

Supports new and existing GitHub repos. Writes .paadhai.json,
creates repo/branch/board. Per SRS 4.1 + 4.1.1."
```

---

### Task 6: Create `project-plan/SKILL.md`

**Files:**
- Create: `.claude/skills/project-plan/SKILL.md`

- [ ] **Step 1: Write the skill file**

```yaml
---
name: project-plan
description: Use when defining requirements — transform a product idea into a confirmed SRS document
---
```

**Key sections (SRS 4.2):**

1. **STEP 1 — Load Config**: `[READ] .paadhai.json` — hard stop if missing.

2. **STEP 2 — Read Existing Context**: `[READ]` any existing docs or codebase context.

3. **STEP 3 — Product Description**: Ask user to describe the product/feature set (free-form). Single input round.

4. **STEP 4 — Clarifying Questions**: Ask 5–8 questions all at once: users, core problems, non-goals, tech preferences, constraints, timeline, known risks. Single input round.

5. **STEP 5 — Research**: `[DELEGATE][FAST-MODEL]` `[SEARCH]` Validate tech stack choices, check version compatibility.

6. **STEP 6 — Generate SRS**: Use `templates/srs.md` template. Complete SRS with: product overview, goals/non-goals, user personas, functional requirements, technical stack, architecture, non-functional requirements, constraints, open questions.

7. **STEP 7 — Present SRS**: Show full document. **G-02: "Approve this SRS? (yes / list changes)"**

8. **STEP 8 — Revision Loop**: Changes requested → apply → re-present → repeat G-02.

9. **STEP 9 — Save**: `[DELEGATE][FAST-MODEL]` Save to `docs/srs.md`, commit: `docs(srs): add confirmed SRS v{version}`.

10. **STEP 10 — Handoff**: "Run /release-plan to create your GitHub project."

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/project-plan/SKILL.md
git commit -m "feat(project-plan): add SRS generation skill

Transforms product idea into confirmed SRS via guided questions.
Per SRS 4.2."
```

---

### Task 7: Create `release-plan/SKILL.md`

**Files:**
- Create: `.claude/skills/release-plan/SKILL.md`

- [ ] **Step 1: Write the skill file**

```yaml
---
name: release-plan
description: Use when creating milestones and issues — break confirmed SRS into GitHub milestones and issues
---
```

**Key sections (SRS 4.3):**

1. **STEP 1 — Load Config + SRS**: `[READ] .paadhai.json` + `[READ] docs/srs.md` — hard stop if either missing.

2. **STEP 2 — Analyze Requirements**: Group functional requirements into milestones (e.g. v0.1, v0.2).

3. **STEP 3 — Create Issues**: Break each milestone into atomic, independently-deliverable issues. For each: title, description (Summary, Acceptance Criteria with checkboxes, Test Checklist, Expected Outcome, Notes), labels.

4. **STEP 4 — Present Release Plan**: Show all milestones + all issues with full content + issue count. **G-03: "Approve this release plan? (yes / list changes)"**

5. **STEP 5 — Revision Loop**: Changes → apply → re-present → repeat.

6. **STEP 6 — Create on GitHub** (after G-03):
   - `[PARALLEL][FAST-MODEL]` Create all milestones simultaneously
   - `[PARALLEL][FAST-MODEL]` Create all issues with labels + milestone assignments
   - `[DELEGATE][FAST-MODEL]` Add all issues to project board with status "Todo" using `{config.github.statuses.todo}`

7. **STEP 7 — Summary**: Milestone count, issue count, project board URL, list of created issues.

8. **STEP 8 — Handoff**: "Run /dev-start #<issue-number> to begin development."

**Issue template** (embedded in skill):
```markdown
## Summary
<what this issue builds>

## Acceptance Criteria
- [ ] AC-1: <specific, testable criterion>
- [ ] AC-2: <specific, testable criterion>

## Test Checklist
- [ ] Happy path: <describe>
- [ ] Edge case: <describe>
- [ ] Error case: <describe>

## Expected Outcome
<what the system does when this issue is complete>

## Notes
<dependencies, constraints, decisions>
```

**Issue rules:**
- Each independently deliverable
- At least 2 acceptance criteria each
- Test checklist required
- Must be assigned to a milestone

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/release-plan/SKILL.md
git commit -m "feat(release-plan): add milestone and issue creation skill

Breaks SRS into milestones + atomic issues on GitHub.
Per SRS 4.3."
```

---

### Task 8: Create `dev-pr/SKILL.md`

**Files:**
- Create: `.claude/skills/dev-pr/SKILL.md`

- [ ] **Step 1: Write the skill file**

```yaml
---
name: dev-pr
description: Use when opening a pull request — push branch, create PR, poll CI, report results
---
```

**Key sections (SRS 4.7):**

1. **STEP 1 — Load Config**: `[READ] .paadhai.json` + plan file.

2. **STEP 2 — Push Branch**: `[SHELL]` `git push origin {branch-name}`.

3. **STEP 3 — Build PR Body**: Use `templates/pr-body.md`. Fill from plan: Summary (3-5 bullets), Changes (file list), Test Plan (build/lint/test + specific scenarios), Acceptance Criteria, Notes. Include `Closes #<number>`.

4. **STEP 4 — Create PR**: `[SHELL]` `gh pr create --base {config.repo.develop_branch} --title "..." --body "..."`.

5. **STEP 5 — Display PR URL**.

6. **STEP 6 — Poll CI**: `[SHELL]` `gh pr checks <pr-number> --watch` (max 5 min).

7. **STEP 7 — CI Results**:
   - **G-07**: Show CI result.
   - If passes → display green, hand off.
   - If fails → `[DELEGATE][SMART-MODEL]` analyze failure logs, return diagnosis. Show diagnosis to user. If fix needed: fix → commit `fix(ci): resolve <job>` → re-push → re-poll.

8. **STEP 8 — Handoff**: "Run /dev-audit to review the PR."

**Does NOT change board status** (per SRS 9.4).

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/dev-pr/SKILL.md
git commit -m "feat(dev-pr): add PR creation and CI polling skill

Push branch, create PR, poll CI, diagnose failures.
Per SRS 4.7."
```

---

### Task 9: Create `dev-audit/SKILL.md`

**Files:**
- Create: `.claude/skills/dev-audit/SKILL.md`

- [ ] **Step 1: Write the skill file**

```yaml
---
name: dev-audit
description: Use when reviewing a PR — architecture, security, and compatibility review with explicit sign-off
---
```

**Key sections (SRS 4.8):**

1. **STEP 1 — Load Config**: `[READ] .paadhai.json` + plan file.

2. **STEP 2 — Verify CI**: `[SHELL]` `gh pr checks <pr-number>`. If red → stop, tell user to fix CI first.

3. **STEP 3 — Get Diff**: `[SHELL]` `git diff origin/{config.repo.develop_branch}..HEAD -- . ':!docs/plans/'`.

4. **STEP 4 — Run Three Reviews** (parallel if supported):
   - `[PARALLEL][SMART-MODEL]` **Architecture review**: layer violations, coupling, naming consistency, pattern alignment
   - `[PARALLEL][SMART-MODEL]` **Security review**: injection vulnerabilities, hardcoded secrets, missing input validation, auth gaps, insecure deps
   - `[PARALLEL][SMART-MODEL]` **Compatibility review**: breaking API changes, dependency conflicts, platform-specific code, config schema breaks

5. **STEP 5 — Synthesize Report**: Merge findings into unified report. PASS/FAIL per dimension + bullet findings.

6. **STEP 6 — Present Report**: **G-08**: Show report to user. Require explicit sign-off.
   - If approved → display handoff
   - If fixes requested → implement → re-run audit → repeat

7. **STEP 7 — Handoff**: "Run /dev-ship to merge the PR."

**Does NOT change board status** (per SRS 9.4).

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/dev-audit/SKILL.md
git commit -m "feat(dev-audit): add three-dimension PR audit skill

Architecture + security + compatibility review with parallel execution.
Per SRS 4.8."
```

---

### Task 10: Create `dev-release/SKILL.md`

**Files:**
- Create: `.claude/skills/dev-release/SKILL.md`

- [ ] **Step 1: Write the skill file**

```yaml
---
name: dev-release
description: Use when releasing — cut release branch, tag, publish GitHub Release, back-merge to develop
---
```

**Key sections (SRS 4.10):**

1. **STEP 1 — Load Config**: `[READ] .paadhai.json`.

2. **STEP 2 — Verify Milestone Completion**: `[SHELL]` Check all milestone issues closed. If open → stop, show remaining.

3. **STEP 3 — Ask Version**: Ask user for version number (e.g. `v0.1.0`).

4. **STEP 4 — Prepare Release Branch**:
   - `[SHELL]` `git checkout {config.repo.develop_branch} && git pull origin {config.repo.develop_branch}`
   - `[SHELL]` `git checkout -b {config.branches.release}<version>`

5. **STEP 5 — Test**: `[DELEGATE][FAST-MODEL]` Run full test suite: `{config.stack.build_cmd}`, `{config.stack.lint_cmd}`, `{config.stack.test_cmd}`. If fail → fix first.

6. **STEP 6 — Push + Create PR**:
   - `[SHELL]` Push release branch
   - `[SHELL]` Create PR: release → `{config.repo.main_branch}`

7. **STEP 7 — Display Release PR URL**.

8. **STEP 8 — Final Confirmation**: **G-10: "Confirm: Merge release PR and publish release? (yes/no)"**. Wait for explicit approval.

9. **STEP 9 — Execute Release** (after G-10):
   - `[SHELL]` Merge PR: `gh pr merge --merge --delete-branch`
   - `[SHELL]` Tag: `git tag -a <version> -m "<version> — <milestone>"`
   - `[SHELL]` Push tags: `git push origin --tags`
   - `[SHELL]` Back-merge: `git checkout {config.repo.develop_branch} && git merge {config.repo.main_branch} && git push`
   - `[SHELL]` Create release: `gh release create <version> --generate-notes --target {config.repo.main_branch}`

10. **STEP 10 — Display Release URL**.

11. **STEP 11 — Next Milestone**: Show open issues for next milestone, suggest `/dev-start`.

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/dev-release/SKILL.md
git commit -m "feat(dev-release): add release automation skill

Release branch, PR to main, tag, GitHub Release, back-merge.
Per SRS 4.10."
```

---

## Phase 3: Platform Reference Files

### Task 11: Create all reference files

**Files:**
- Create: `references/claude-tools.md`
- Create: `references/cursor-tools.md`
- Create: `references/codex-tools.md`
- Create: `references/gemini-tools.md`

- [ ] **Step 1: Create `references/claude-tools.md`**

```markdown
# Claude Code — Capability Marker Mapping

This file maps Paadhai capability markers to Claude Code native tools.
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

## Subagent Support

Claude Code fully supports subagent dispatch via the `Agent` tool.

- `[PARALLEL]` → multiple `Agent` calls in a single message (true parallelism)
- `[DELEGATE]` → single `Agent` call with focused brief
- Model selection via `model` parameter: `"haiku"`, `"sonnet"`, `"opus"`

## Fallback

No fallback needed — Claude Code supports all markers natively.
```

- [ ] **Step 2: Create `references/cursor-tools.md`**

```markdown
# Cursor — Capability Marker Mapping

This file maps Paadhai capability markers to Cursor native tools.
Loaded at session start via `CURSOR.md`.

| Marker | Cursor Tool | Notes |
|--------|------------|-------|
| `[READ]` | Built-in file read | Cursor reads files natively |
| `[SHELL]` | Terminal command execution | Run commands in integrated terminal |
| `[SEARCH]` | Codebase search | Cursor's built-in search |
| `[WRITE]` | File edit/create | Cursor's edit capabilities |
| `[PARALLEL]` | **Sequential fallback** | Execute one at a time |
| `[DELEGATE]` | **Inline execution** | No subagent — execute in current context |
| `[FAST-MODEL]` | Current session model | No model selection |
| `[SMART-MODEL]` | Current session model | No model selection |

## Subagent Support

Cursor does NOT support subagent dispatch. All `[PARALLEL]` and `[DELEGATE]` tasks execute sequentially in the current context.

## Fallback Behavior

- `[PARALLEL]` → execute tasks one at a time in listed order
- `[DELEGATE]` → execute inline in current session
- `[FAST-MODEL]` / `[SMART-MODEL]` → use whatever model the session is running
```

- [ ] **Step 3: Create `references/codex-tools.md`**

```markdown
# Codex CLI — Capability Marker Mapping

This file maps Paadhai capability markers to Codex CLI native tools.
Loaded at session start via Codex configuration.

| Marker | Codex Tool | Notes |
|--------|-----------|-------|
| `[READ]` | File read | Codex reads files in sandbox |
| `[SHELL]` | Shell execution | Commands run in sandbox |
| `[SEARCH]` | `grep` / `find` | Standard CLI search tools |
| `[WRITE]` | File write | Write within sandbox |
| `[PARALLEL]` | **Sequential fallback** | No parallel execution |
| `[DELEGATE]` | **Inline execution** | No subagent support |
| `[FAST-MODEL]` | Current model | No model selection |
| `[SMART-MODEL]` | Current model | No model selection |

## Subagent Support

Codex CLI does NOT support subagent dispatch.

## Fallback Behavior

- `[PARALLEL]` → sequential execution
- `[DELEGATE]` → inline execution
- `[FAST-MODEL]` / `[SMART-MODEL]` → current session model
```

- [ ] **Step 4: Create `references/gemini-tools.md`**

```markdown
# Gemini CLI — Capability Marker Mapping

This file maps Paadhai capability markers to Gemini CLI native tools.
Loaded at session start via `GEMINI.md`.

| Marker | Gemini Tool | Notes |
|--------|------------|-------|
| `[READ]` | `read_file` | Read file contents |
| `[SHELL]` | `run_shell` | Execute shell commands |
| `[SEARCH]` | `search_files` | Search codebase |
| `[WRITE]` | `edit_file` / `create_file` | Create or modify files |
| `[PARALLEL]` | **Partial support** | Some parallel execution via extensions |
| `[DELEGATE]` | **Inline execution** | Limited subagent support |
| `[FAST-MODEL]` | `gemini-flash` | Use fastest Gemini model |
| `[SMART-MODEL]` | `gemini-pro` | Use most capable Gemini model |

## Subagent Support

Gemini CLI has partial subagent support via extensions. When available, `[DELEGATE]` uses extension dispatch. When not available, falls back to inline execution.

## Fallback Behavior

- `[PARALLEL]` → sequential if extensions unavailable
- `[DELEGATE]` → inline if no extension support
- `[FAST-MODEL]` → `gemini-flash` (or current model if unavailable)
- `[SMART-MODEL]` → `gemini-pro` (or current model if unavailable)
```

- [ ] **Step 5: Commit all reference files**

```bash
git add references/
git commit -m "feat(references): add platform capability marker mappings

Claude Code, Cursor, Codex CLI, and Gemini CLI tool mappings.
Per SRS sections 6 and 7."
```

---

## Phase 4: Templates

### Task 12: Create template files

**Files:**
- Create: `templates/srs.md`
- Create: `templates/pr-body.md`

- [ ] **Step 1: Create `templates/srs.md`**

This is the SRS template used by `/project-plan` (Step 6). It should be a skeleton with placeholders:

```markdown
# Software Requirements Specification
# {project_name}

---

| Field       | Value              |
|-------------|--------------------|
| Document    | Software Requirements Specification (SRS) |
| Project     | {project_name}     |
| Version     | {version}          |
| Status      | Draft              |
| Created     | {date}             |

---

## 1. Introduction

### 1.1 Purpose
{purpose_description}

### 1.2 Product Scope
{scope_description}

### 1.3 Problem Statement
{problem_statement}

### 1.4 Definitions
| Term | Definition |
|------|-----------|
| | |

### 1.5 Intended Audience
{audience}

---

## 2. Overall Description

### 2.1 Product Perspective
{perspective}

### 2.2 User Roles
| Role | Description |
|------|-------------|
| | |

### 2.3 Key Assumptions
{assumptions}

---

## 3. Functional Requirements

### FR-1: {feature_name}
**Description:** {description}
**Priority:** {High/Medium/Low}
**Acceptance Criteria:**
- [ ] AC-1: {criterion}
- [ ] AC-2: {criterion}

---

## 4. Technical Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Language | | |
| Framework | | |
| Database | | |
| Hosting | | |

---

## 5. Architecture Overview
{architecture_description}

---

## 6. Non-Functional Requirements

### 6.1 Performance
{performance_requirements}

### 6.2 Security
{security_requirements}

### 6.3 Reliability
{reliability_requirements}

---

## 7. Constraints
| Constraint | Detail |
|------------|--------|
| | |

---

## 8. Open Questions
| ID | Question | Status |
|----|----------|--------|
| Q-01 | | Open |

---

*End of SRS*
```

- [ ] **Step 2: Create `templates/pr-body.md`**

This is the PR body template used by `/dev-pr` (Step 3):

```markdown
## Summary
{summary_bullets}

## Changes
{file_changes}

## Test Plan
- [ ] `{build_cmd}` — zero errors
- [ ] `{lint_cmd}` — zero errors
- [ ] `{test_cmd}` — all pass
{specific_test_scenarios}

## Acceptance Criteria
{acceptance_criteria}

## Notes
{notes}

Closes #{issue_number}
```

- [ ] **Step 3: Commit**

```bash
git add templates/
git commit -m "feat(templates): add SRS and PR body templates

SRS template for /project-plan, PR body template for /dev-pr.
Per SRS 4.2 and 4.7."
```

---

## Phase 5: Platform Plugin Manifests + Loader Files

### Task 13: Create plugin manifests and instruction files

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`
- Create: `.cursor-plugin/plugin.json`
- Create: `.cursor-plugin/marketplace.json`
- Create: `.codex-plugin/plugin.json`
- Create: `.gemini/extensions/paadhai/gemini-extension.json`
- Create: `CLAUDE.md`
- Create: `AGENTS.md`
- Create: `GEMINI.md`

- [ ] **Step 1: Create `.claude-plugin/plugin.json`**

Claude Code plugin manifest. Skills live at plugin root `skills/` (NOT inside `.claude-plugin/`).

```json
{
  "name": "paadhai",
  "version": "1.0.0",
  "description": "AI-native SDLC pipeline — 10 skills covering the full software development lifecycle",
  "author": { "name": "Paadhai Project" },
  "license": "MIT",
  "skills": [
    { "name": "project-init", "path": "skills/project-init/SKILL.md" },
    { "name": "project-plan", "path": "skills/project-plan/SKILL.md" },
    { "name": "release-plan", "path": "skills/release-plan/SKILL.md" },
    { "name": "dev-start", "path": "skills/dev-start/SKILL.md" },
    { "name": "dev-plan", "path": "skills/dev-plan/SKILL.md" },
    { "name": "dev-implement", "path": "skills/dev-implement/SKILL.md" },
    { "name": "dev-pr", "path": "skills/dev-pr/SKILL.md" },
    { "name": "dev-audit", "path": "skills/dev-audit/SKILL.md" },
    { "name": "dev-ship", "path": "skills/dev-ship/SKILL.md" },
    { "name": "dev-release", "path": "skills/dev-release/SKILL.md" }
  ]
}
```

**Note:** Skills are in `.claude/skills/` during development. The plugin.json `path` fields reference the plugin's own skills directory for distribution. During dev, Claude Code reads skills from `.claude/skills/` natively.

- [ ] **Step 2: Create `.claude-plugin/marketplace.json`**

```json
{
  "name": "paadhai",
  "display_name": "Paadhai — AI SDLC Pipeline",
  "description": "Complete software development lifecycle as AI agent skills. From repo init to production release.",
  "version": "1.0.0",
  "author": { "name": "Paadhai Project" },
  "license": "MIT",
  "source": ".",
  "category": "Development Workflow",
  "tags": ["sdlc", "devops", "github", "workflow", "ai-agent"],
  "keywords": ["sdlc", "devops", "github", "workflow", "ai-agent"]
}
```

- [ ] **Step 3: Create `.cursor-plugin/plugin.json`**

Cursor 2.5+ plugin manifest. Uses same `SKILL.md` format. Can also include `.mdc` rules files.

```json
{
  "name": "paadhai",
  "displayName": "Paadhai — AI SDLC Pipeline",
  "version": "1.0.0",
  "description": "AI-native SDLC pipeline — 10 skills covering the full software development lifecycle",
  "author": "Paadhai Project",
  "license": "MIT",
  "keywords": ["sdlc", "devops", "github", "workflow"]
}
```

**Note:** Cursor reads skills from `skills/<name>/SKILL.md` at plugin root and rules from `rules/*.mdc`.

- [ ] **Step 4: Create `.cursor-plugin/marketplace.json`**

```json
{
  "name": "paadhai",
  "display_name": "Paadhai — AI SDLC Pipeline",
  "description": "Complete software development lifecycle as AI agent skills.",
  "version": "1.0.0",
  "author": "Paadhai Project",
  "license": "MIT",
  "category": "Development Workflow",
  "tags": ["sdlc", "github", "workflow"]
}
```

- [ ] **Step 5: Create `.codex-plugin/plugin.json`**

Codex CLI plugin manifest. Codex uses `.codex-plugin/plugin.json` + `skills/<name>/SKILL.md`.

```json
{
  "name": "paadhai",
  "version": "1.0.0",
  "description": "AI-native SDLC pipeline — 10 skills covering the full software development lifecycle",
  "author": "Paadhai Project",
  "license": "MIT"
}
```

**Note:** Codex reads `AGENTS.md` at project root for instructions and `skills/<name>/SKILL.md` for skills. Config in `.codex/config.toml`.

- [ ] **Step 6: Create `.gemini/extensions/paadhai/gemini-extension.json`**

Gemini CLI extension manifest. Gemini reads `GEMINI.md` as context file from the extension directory.

```json
{
  "name": "paadhai",
  "version": "1.0.0",
  "contextFileName": "GEMINI.md"
}
```

**Note:** Copy `GEMINI.md` into `.gemini/extensions/paadhai/` so Gemini loads it as extension context. The root `GEMINI.md` serves as the project-level context file.

- [ ] **Step 7: Create `CLAUDE.md` instruction file**

Claude Code reads this at session start. It is the ONLY platform that reads `CLAUDE.md`.

```markdown
# Paadhai — Claude Code

Read `references/claude-tools.md` for capability marker → tool mappings.

## Available Skills

| Command | Purpose |
|---------|---------|
| `/project-init` | Set up new or existing project |
| `/project-plan` | Generate SRS from product idea |
| `/release-plan` | Create milestones + issues on GitHub |
| `/dev-start` | Pick issue, create branch |
| `/dev-plan` | Brainstorm + plan + impl doc |
| `/dev-implement` | Execute implementation step by step |
| `/dev-pr` | Push branch, open PR, poll CI |
| `/dev-audit` | Architecture + security + compatibility review |
| `/dev-ship` | Merge PR, update board, clean up |
| `/dev-release` | Tag, release, back-merge |

## Config

All skills read from `.paadhai.json` at project root. Run `/project-init` to create it.
```

- [ ] **Step 8: Create `AGENTS.md` universal instruction file**

This is the cross-platform instruction file read by **Cursor**, **Codex CLI**, and **OpenCode**. OpenCode prefers `AGENTS.md` over `CLAUDE.md`. Codex reads `AGENTS.md` natively.

```markdown
# Paadhai — AI Agent Instructions

This file provides Paadhai context to AI coding agents. It is read automatically by Cursor, Codex CLI, and OpenCode.

## Platform Detection

Detect your platform and load the correct reference file:
- If you are **Cursor** → read `references/cursor-tools.md`
- If you are **Codex CLI** → read `references/codex-tools.md`
- If you cannot determine platform → read `references/cursor-tools.md` (safe default: sequential fallback)

## Available Skills

| Command | Purpose |
|---------|---------|
| `/project-init` | Set up new or existing project |
| `/project-plan` | Generate SRS from product idea |
| `/release-plan` | Create milestones + issues on GitHub |
| `/dev-start` | Pick issue, create branch |
| `/dev-plan` | Brainstorm + plan + impl doc |
| `/dev-implement` | Execute implementation step by step |
| `/dev-pr` | Push branch, open PR, poll CI |
| `/dev-audit` | Architecture + security + compatibility review |
| `/dev-ship` | Merge PR, update board, clean up |
| `/dev-release` | Tag, release, back-merge |

## Config

All skills read from `.paadhai.json` at project root. Run `/project-init` to create it.

## Fallback Behavior

If your platform does not support subagents:
- `[PARALLEL]` → execute tasks sequentially in listed order
- `[DELEGATE]` → execute inline in current context
- `[FAST-MODEL]` / `[SMART-MODEL]` → use current session model
```

- [ ] **Step 9: Create `GEMINI.md` context file**

Gemini CLI reads this at session start (both from project root and from extension directory).

```markdown
# Paadhai — Gemini CLI

Read `references/gemini-tools.md` for capability marker → tool mappings.

## Available Skills

| Command | Purpose |
|---------|---------|
| `/project-init` | Set up new or existing project |
| `/project-plan` | Generate SRS from product idea |
| `/release-plan` | Create milestones + issues on GitHub |
| `/dev-start` | Pick issue, create branch |
| `/dev-plan` | Brainstorm + plan + impl doc |
| `/dev-implement` | Execute implementation step by step |
| `/dev-pr` | Push branch, open PR, poll CI |
| `/dev-audit` | Architecture + security + compatibility review |
| `/dev-ship` | Merge PR, update board, clean up |
| `/dev-release` | Tag, release, back-merge |

## Config

All skills read from `.paadhai.json` at project root. Run `/project-init` to create it.

## Subagent Support

Gemini CLI has partial subagent support via extensions.
- `[FAST-MODEL]` → `gemini-flash`
- `[SMART-MODEL]` → `gemini-pro`
- `[PARALLEL]` → sequential if extensions unavailable
- `[DELEGATE]` → inline if no extension support
```

- [ ] **Step 10: Copy GEMINI.md into extension directory**

```bash
cp GEMINI.md .gemini/extensions/paadhai/GEMINI.md
```

- [ ] **Step 11: Commit all platform files**

```bash
git add .claude-plugin/ .cursor-plugin/ .codex-plugin/ .opencode/ .gemini/ CLAUDE.md AGENTS.md GEMINI.md
git commit -m "feat(platform): add plugin manifests and instruction files

Claude Code (.claude-plugin/), Cursor (.cursor-plugin/), Codex CLI
(.codex-plugin/), Gemini CLI (.gemini/extensions/paadhai/).
CLAUDE.md for Claude Code, AGENTS.md for Cursor/Codex/OpenCode,
GEMINI.md for Gemini CLI. Per SRS section 7."
```

---

## Phase 6: Documentation

### Task 14: Create README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

Structure:
1. **Header**: Paadhai (பாதை) — AI-Native SDLC Pipeline
2. **What is Paadhai?**: One paragraph — 10 skills, full SDLC, works with Claude Code/Cursor/Codex/OpenCode/Gemini
3. **Pipeline Overview**: ASCII diagram from SRS 2.2
4. **Quick Start**: 
   - Prerequisites (git, gh, AI agent)
   - Install per platform (Claude Code: `/plugin install paadhai`, Cursor: marketplace, others: clone + copy)
   - First commands: `/project-init` → `/project-plan` → `/release-plan` → `/dev-start`
5. **Skills Reference**: Table of all 10 skills with one-line description
6. **Configuration**: `.paadhai.json` schema overview
7. **Platform Support**: Table showing which platforms support which capabilities
8. **Contributing**: Link to CONTRIBUTING.md
9. **License**: MIT

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with install and quickstart guide"
```

---

### Task 15: Create LICENSE

**Files:**
- Create: `LICENSE`

- [ ] **Step 1: Write MIT license file**

Standard MIT license text with:
- Year: 2026
- Copyright holder: Paadhai Project

- [ ] **Step 2: Commit**

```bash
git add LICENSE
git commit -m "docs: add MIT license"
```

---

### Task 16: Create CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: Write CONTRIBUTING.md**

Structure:
1. **Welcome**: Brief intro to contributing
2. **Getting Started**: Fork, clone, install prerequisites
3. **Development Workflow**: Use Paadhai itself (dogfooding) — `/dev-start`, `/dev-plan`, etc.
4. **Skill File Format**: YAML frontmatter + markdown, capability markers, `.paadhai.json` config references
5. **Commit Convention**: conventional commits (feat, fix, test, chore, refactor, docs, perf)
6. **Pull Request Process**: Branch from develop, PR to develop, CI must pass, audit required
7. **Code of Conduct**: Standard contributor covenant reference

- [ ] **Step 2: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: add contributor guide"
```

---

### Task 17: Final verification

- [ ] **Step 1: Verify no hardcoded values in any skill file**

Search all `.claude/skills/*/SKILL.md` files for:
- `learnzdevelopmenthub`
- `ninaivagam`
- `PVT_kw`
- `PVTSSF_`
- `47fc9ee4`
- `98236657`
- `npm run build` (should be `{config.stack.build_cmd}`)
- `npm run lint` (should be `{config.stack.lint_cmd}`)
- `npm test` or `npm run test` (should be `{config.stack.test_cmd}`)

Must find ZERO matches.

- [ ] **Step 2: Verify all 10 skill files exist**

```bash
ls -la .claude/skills/*/SKILL.md
```

Expected: 10 files (project-init, project-plan, release-plan, dev-start, dev-plan, dev-implement, dev-pr, dev-audit, dev-ship, dev-release).

- [ ] **Step 3: Verify all reference files exist**

```bash
ls -la references/*.md
```

Expected: 4 files (claude-tools, cursor-tools, codex-tools, gemini-tools).

- [ ] **Step 4: Verify all template files exist**

```bash
ls -la templates/*.md
```

Expected: 2 files (srs.md, pr-body.md).

- [ ] **Step 5: Verify all platform files exist**

```bash
ls -la .claude-plugin/plugin.json .claude-plugin/marketplace.json
ls -la .cursor-plugin/plugin.json .cursor-plugin/marketplace.json
ls -la .codex-plugin/plugin.json
ls -la .gemini/extensions/paadhai/gemini-extension.json .gemini/extensions/paadhai/GEMINI.md
ls -la CLAUDE.md AGENTS.md GEMINI.md
```

- [ ] **Step 6: Verify docs exist**

```bash
ls -la README.md LICENSE CONTRIBUTING.md
```

- [ ] **Step 7: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "chore: final verification fixes"
```

---

## Execution Order Summary

| Task | Phase | Description | Dependencies |
|------|-------|-------------|-------------|
| 0 | 0 | Git init + scaffolding | None |
| 1 | 1 | Rewrite dev-start | Task 0 |
| 2 | 1 | Rewrite dev-plan | Task 0 |
| 3 | 1 | Rewrite dev-implement | Task 0 |
| 4 | 1 | Rewrite dev-ship (strip) | Task 0 |
| 5 | 2 | Create project-init | Task 0 |
| 6 | 2 | Create project-plan | Task 0 |
| 7 | 2 | Create release-plan | Task 0 |
| 8 | 2 | Create dev-pr | Task 0 |
| 9 | 2 | Create dev-audit | Task 0 |
| 10 | 2 | Create dev-release | Task 0 |
| 11 | 3 | Reference files (4) | Task 0 |
| 12 | 4 | Template files (2) | Task 0 |
| 13 | 5 | Plugin manifests + instruction files (CLAUDE.md, AGENTS.md, GEMINI.md) | Tasks 1-12 (needs skill paths) |
| 14 | 6 | README.md | Tasks 1-13 |
| 15 | 6 | LICENSE | Task 0 |
| 16 | 6 | CONTRIBUTING.md | Task 0 |
| 17 | 6 | Final verification | Tasks 1-16 |

**Parallelizable groups:**
- Tasks 1-4 (Phase 1 refactors) — all independent
- Tasks 5-10 (Phase 2 new skills) — all independent
- Tasks 11-12 (Phase 3-4) — independent of each other
- Task 15-16 — independent of each other
