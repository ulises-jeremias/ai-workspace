# Contributing

This repo is your **personal AI workspace** — a fork-and-own framework. Contributions here mean extending it for your own needs. If you want to contribute back to the upstream, open a PR at [github.com/ulises-jeremias/ai-workspace](https://github.com/ulises-jeremias/ai-workspace).

---

## What belongs here

| Type | Where |
|------|-------|
| Tool process documentation | `knowledge/processes/` |
| Workflow and routing patterns | `knowledge/processes/general.md` |
| New skill discoveries | `knowledge/skills/discovered.md` |
| Learnings and corrections | `knowledge/learnings/` |
| CLI tool improvements | `bin/` |
| Job templates | `templates/jobs/` |
| Personas | `personas/` |
| Context packs | `packs/` |
| Setup / onboarding docs | `docs/` |

## What belongs elsewhere

| If it's... | Put it in |
|-----------|-----------|
| Machine setup, dotfiles, shell config | Your workstation/dotfiles repo (e.g. [dots-ai](https://github.com/ulises-jeremias/dots-ai)) |
| Reusable skill definitions | Your skills pack / `dots-skills` managed directory |
| Team-wide patterns and examples | Your team's knowledge base |

---

## Workflow

```bash
# 1. Branch from main
git checkout -b feat/add-my-improvement

# 2. Make your changes

# 3. Commit (English)
git commit -m "docs(knowledge): add process for tool X"

# 4. Push and open PR (if contributing upstream)
git push -u origin feat/add-my-improvement
gh pr create
```

---

## Commit message conventions

```text
feat(scope):     New capability
fix(scope):      Bug or error fix
docs(scope):     Documentation only
chore(scope):    Maintenance, deps, CI
```

Common scopes: `knowledge`, `bin`, `docs`, `templates`, `personas`, `packs`, `ci`

---

## PR checklist

- [ ] No secrets, tokens, credentials, or personal IDs included
- [ ] Knowledge entries use placeholder examples (not real IDs)
- [ ] CLI scripts are executable (`chmod +x bin/my-script`)
- [ ] Docs files use UPPERCASE names (`docs/MY-DOC.md`)
- [ ] No team-specific names, URLs, or tool instances hardcoded
- [ ] Pre-commit passes locally (`pre-commit run --all-files`)

---

## Adding processes

When adding a new tool process (e.g., a new project management tool):

- [ ] Create `knowledge/processes/<tool>.md`
- [ ] Use placeholder IDs, not real ones
- [ ] Document the skill/CLI invocation pattern
- [ ] Add an entry to the routing table in `AGENTS.md`

---

## Related projects

- [dots-ai](https://github.com/ulises-jeremias/dots-ai) — Workstation AI layer (skills, agents, CLI helpers)
- [dotfiles](https://github.com/ulises-jeremias/dotfiles) — Desktop configuration (HorneroConfig)
