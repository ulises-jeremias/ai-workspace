# AGENTS.md — AI Workspace Orchestrator

**Purpose**: Stateless session that orchestrates multi-repository work across any project or team.

**Language**: Match the user's language for conversation → English for commits, PRs, tickets, docs.

---

## Work Context

- **Current directory**: This workspace (not a repo itself)
- **Repos**: `./projects/` symlinks (quick access) · `./repos/` cloned on-demand
- **Knowledge**: `./knowledge/` — your processes, tool patterns, learnings, todos
- **Personas**: `./personas/` — specialized AI personas for different work modes
- **Packs**: `./packs/` — context bundles for switching between clients/projects

---

## Routing

| Task type | Delegate to |
|-----------|-------------|
| Discovery / first look at a repo | `dev-assistant` skill |
| Generic delivery workflow | `workflow-generic-project` skill |
| Code review / refactor / security | `code-reviewer` / `refactor-cleaner` / `security-reviewer` |
| UI/UX design | `ui-ux-pro-max` skill |
| JIRA tasks | `jira-assistant` skill |
| Confluence tasks | `confluence-assistant` skill |
| ClickUp tasks | `clickup-cli` skill |
| Deferred / background work | `./bin/devcompanion queue` |

> **Customize this table** to match your installed skills and team tools.
> If using [dots-ai](https://github.com/ulises-jeremias/dots-ai), skills are installed via `dots-skills sync` and agents via `~/.config/opencode/agents/` or `~/.claude/agents/`.

---

## Operating Rules

**Always:**

- Check `knowledge/` before asking the user a question already answered
- Run discovery before making significant changes to any repo
- For delivery: follow plan → implement → review → PR phases
- Use `workdir` to change repo context — never `cd && command`
- Report findings in the user's language; write all output artifacts (PRs, tickets, commits) in English
- Run `./bin/workspace-context` at session start if available

**Never:**

- Assume we are inside a repo without verifying
- Commit without code review
- Skip the plan phase for non-trivial work

---

## Skills

### Delivery

| Skill | When |
|-------|------|
| `dev-assistant` | Repo inspection, discovery, convention verification |
| `workflow-generic-project` | Delivery phases for any client project |

### Productivity

| Skill | When |
|-------|------|
| `jira-assistant` | Router for any JIRA operation |
| `confluence-assistant` | Router for Confluence operations |
| `clickup-cli` | ClickUp tasks, sprints, Docs, comments |

### Technical

| Skill | When |
|-------|------|
| `ui-ux-pro-max` | UI/UX design, components, layouts |
| `github-cli-workflow` | Push branch, create draft PR (GitHub) |
| `gitlab-cli-workflow` | Push branch, create draft MR (GitLab) |
| `workstation-triage` | Workstation health diagnostics |

### Subagents

| Subagent | When |
|----------|------|
| `code-reviewer` | Quality, security, maintainability review |
| `security-reviewer` | Vulnerability audit |
| `tdd-guide` | Test-driven development |
| `refactor-cleaner` | Dead code removal, simplification |
| `explore` | Fast codebase search |
| `docs-lookup` | Documentation and API references |
| `architect` | System design and architecture decisions |
| `build-error-resolver` | Build, TypeScript, lint, and CI failures |
| `database-reviewer` | PostgreSQL, schema design, query optimization |
| `performance-optimizer` | Performance profiling and optimization |
| `planner` | Feature planning and task breakdown |
| `typescript-reviewer` | TypeScript type safety improvements |
| `e2e-runner` | Playwright end-to-end testing |

> **Add your team's custom skills here** as you configure them.
> With [dots-ai](https://github.com/ulises-jeremias/dots-ai) installed, all these agents are available out of the box.

---

## Knowledge Base

Check `knowledge/` **before asking**. Save discoveries **after learning**.

```bash
./bin/assistant-memory search "topic"             # Find existing knowledge
./bin/assistant-memory add --type learning "..."  # Save new pattern
./bin/assistant-memory add --type todo "..."      # Track follow-up
./bin/assistant-memory inject                     # Output context for session start
./bin/assistant-memory todo                       # Review pending items
```

Rules:

1. **Check before asking** — if we learned it before, use it
2. **Save after learning** — document corrections and new patterns
3. **Save after discovering** — record reusable IDs, patterns, decisions
4. **Review todos** — check `knowledge/todos/pending.md` at session start

→ [`knowledge/README.md`](knowledge/README.md)

---

## Personas

Personas define focused work modes with specific constraints:

```bash
# Available personas (customize to your needs)
personas/implementer.md    # Write code, bias toward action
personas/reviewer.md       # Analyze and critique, no changes
personas/researcher.md     # Explore and summarize, no implementation
personas/architect.md      # System design, tradeoffs, ADRs
personas/writer.md         # Documentation and prose only
```

→ [`docs/PERSONAS.md`](docs/PERSONAS.md)

---

## Packs

Packs bundle context for a specific client or project:

```bash
# Load a pack at session start
./bin/workspace-context load packs/my-client.yaml
```

→ [`docs/PACKS.md`](docs/PACKS.md)

---

## devcompanion — when to queue vs interactive

**Queue a job** (use `./bin/devcompanion`) when you hear any of these:

| User says | Action |
|-----------|--------|
| "do a code review of X" | `queue <project> --template code-review` |
| "review the code / security of X" | `queue <project> --template code-review` |
| "create the PR for X" | `queue <project> --template create-pr` |
| "fix the CI for X" | `queue <project> --template fix-ci` |
| "investigate the problem in X" | `queue <project> --template investigate --request "..."` |
| "refactor X" | `queue <project> --template refactor --request "..."` |
| "do it in the background" / "async" | `queue <project> --request "..."` |
| "queue this" / "defer this" | `queue <project> --request "..."` |

After queuing, **always** run `./bin/devcompanion run-once` to process immediately,
or tell the user to let the worker pick it up.
**Always** show the generated `plan.md` artifact to the user.

```bash
# Full workflow
./bin/devcompanion queue <project> --template <name>   # queue
./bin/devcompanion run-once                            # execute (LLM-powered)
./bin/devcompanion status                              # check queue
./bin/devcompanion done <job-id>                       # mark complete

# Manage repos
./bin/project-indexer clone owner/my-repo              # clone + symlink
./bin/project-indexer list                             # list indexed projects
```

→ [`docs/PROJECTS.md`](docs/PROJECTS.md) · [`docs/DEVCOMPANION.md`](docs/DEVCOMPANION.md)

---

## Portability

| AI Tool | Config read |
|---------|-------------|
| Claude Code | `AGENTS.md` |
| OpenCode / Cursor | `CLAUDE.md` → symlink to `AGENTS.md` |
| Gemini CLI | `GEMINI.md` → symlink to `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md` → symlink to `AGENTS.md` |

---

## Notes

- Session is **stateless** — each task can target a different repo
- Customize this file to reflect your team's skills, routing, and conventions
- See [`docs/WORKFLOWS.md`](docs/WORKFLOWS.md) for detailed task patterns
- See [`docs/METHODOLOGY.md`](docs/METHODOLOGY.md) for the agentic harness philosophy
- See [dots-ai](https://github.com/ulises-jeremias/dots-ai) for the workstation tooling layer
