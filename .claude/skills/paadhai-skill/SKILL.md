---
name: paadhai-skill
description: Use when creating or editing Paadhai skills — scaffold with conventions, register in CLAUDE.md and plugin.json
---

# paadhai-skill: Skill Scaffolding

Create new Paadhai skills with proper conventions, register them in CLAUDE.md and plugin.json.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/project-init` first.

This confirms we are in a Paadhai-managed project.

---

## STEP 2 — Gather Skill Info

Ask user:

1. **Skill name** — kebab-case (e.g., `dev-foo`, `project-bar`)
2. **Trigger description** — "Use when..." (what condition activates this skill)
3. **Purpose** — one sentence describing what the skill does
4. **Modifies code?** — yes/no (determines whether gates are needed)
5. **Pipeline position** — after which existing skill? or standalone utility?

Validate:
- Name must be kebab-case, no spaces, no uppercase
- Name must not conflict with existing skills
- Trigger description must start with "Use when"

---

## STEP 3 — Read Conventions

[READ] `references/claude-tools.md` — load capability marker mappings.

[READ] one existing skill as reference template (e.g., `.claude/skills/dev-start/SKILL.md`).

[READ] `CLAUDE.md` — current skill table (to find correct insertion point).

[READ] `.claude-plugin/plugin.json` — current skill registry.

---

## STEP 4 — Determine Next Gate Number

[SHELL] Find the highest gate number in use:
```bash
grep -roh "G-[0-9]*" .claude/skills/ | sort -t- -k2 -n | tail -1
```

Next gate = highest + 1. If skill does not modify code (from Step 2), no gate is needed.

---

## STEP 5 — Generate Skill Scaffold

Build the SKILL.md content following all Paadhai conventions:

```markdown
---
name: <skill-name>
description: <trigger-description>
---

# <skill-name>: <Short Title>

<purpose — one sentence>

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/project-init` first.

Store:
- <relevant config values for this skill>

---

<user-specific steps with proper markers>

---

## STEP N — Handoff

\`\`\`
<next skill recommendation>
\`\`\`
```

Ensure:
- YAML frontmatter with trigger-based description (not summary)
- STEP 1 always loads `.paadhai.json`
- `[READ]` before any file modification
- `git add <specific-files>` never `git add -A`
- Config values from `{config.*}`, never hardcoded
- Gate labels use the correct G-number from Step 4
- Handoff section is the last step
- Capability markers match `references/claude-tools.md`

Display the full generated SKILL.md to user for review.

---

## STEP 6 — Approval Gate

**G-15: "Create this skill and register it? (yes / edit)"**

- **yes** → proceed to Step 7
- **edit** → take feedback, regenerate, re-present (repeat Step 5)

---

## STEP 7 — Write Skill (after G-15)

[SHELL] Create skill directory:
```bash
mkdir -p .claude/skills/<skill-name>
```

[WRITE] `.claude/skills/<skill-name>/SKILL.md` with the generated content.

---

## STEP 8 — Register Skill

[READ] `CLAUDE.md`

[WRITE] Add a new row to the skills table in pipeline order:
```markdown
| `/<skill-name>` | <purpose> |
```

[READ] `.claude-plugin/plugin.json`

[WRITE] Add entry to the `skills` array:
```json
{ "name": "<skill-name>", "path": "skills/<skill-name>/SKILL.md" }
```

Update the `description` field to reflect the new skill count.

---

## STEP 9 — Commit

[SHELL] Commit the new skill and registration:
```bash
git add .claude/skills/<skill-name>/SKILL.md CLAUDE.md .claude-plugin/plugin.json
git commit -m "feat(skills): add /<skill-name> skill

<purpose description>

Refs #<issue-number-if-applicable>"
```

---

## STEP 10 — Verify

[READ] `.claude/skills/<skill-name>/SKILL.md` — confirm file exists and has correct frontmatter.

[READ] `CLAUDE.md` — confirm table entry present.

[READ] `.claude-plugin/plugin.json` — confirm array entry present.

Convention compliance check:
- [ ] YAML frontmatter with `name:` and `description:`
- [ ] STEP 1 loads `.paadhai.json`
- [ ] All config values from `{config.*}`
- [ ] `git add <specific-files>` never `git add -A`
- [ ] `[READ]` before any file modification
- [ ] Gate labels use correct G-number
- [ ] Handoff section is last step
- [ ] Capability markers match `references/claude-tools.md`

---

## STEP 11 — Summary

Display:
```
Skill Created
═══════════════════════════
Name          : <skill-name>
Path          : .claude/skills/<skill-name>/SKILL.md
Gate(s)       : G-<number> (or none)
Registered in : CLAUDE.md, .claude-plugin/plugin.json
Pipeline      : after /<previous-skill>
```
