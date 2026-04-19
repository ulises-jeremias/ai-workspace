# devcompanion — Operational Guide

`bin/devcompanion` is a standalone Python CLI that manages a background job queue
for your AI Workspace. It resolves project paths, queues jobs, runs them (with or
without an LLM), and keeps `knowledge/todos/pending.md` in sync.

---

## Architecture

```text
bin/devcompanion  (standalone Python CLI)
       │
       ├─ reads    projects/              → resolves project name → repo path
       ├─ reads    templates/jobs/        → job templates
       ├─ writes   ~/.local/share/ai-workspace/dev-companion/queue/
       │           ├── pending/           ← jobs waiting to run
       │           ├── processing/        ← job currently running
       │           ├── done/              ← completed jobs
       │           ├── failed/            ← failed jobs
       │           └── artifacts/<id>/    ← plan.md + result.json
       └─ writes   knowledge/todos/pending.md   ← auto-generated
```

**Queue home** defaults to `~/.local/share/ai-workspace/dev-companion/`.
Override with `AI_WORKSPACE_DC_HOME` env var.

**Runner** — `run-once` uses a built-in skeleton runner by default.
If `AI_WORKSPACE_RUNNER_DIR` is set and points to a directory containing a
`runner` module with a `main()` entry point, it will be used for full
LLM-powered execution.

---

## When to use devcompanion vs interactive session

| Situation | Use |
|-----------|-----|
| Quick task, needs back-and-forth | Interactive AI session (default) |
| Long-running task, can run async | `devcompanion queue` |
| Task that blocks the current session | `devcompanion queue` |
| Batch of tasks for multiple projects | `devcompanion queue` (one per project) |

**Rule of thumb:** if you'd say "do this while I work on something else" — queue it.

---

## Core workflow

### 1. Queue a job

```bash
# Using a template
./bin/devcompanion queue <project> --template <template-name>

# Custom request
./bin/devcompanion queue <project> --request "describe what you want done"

# Template + extra context
./bin/devcompanion queue <project> --template refactor --request "focus on auth module"

# Skip LLM (skeleton plan only — no API key needed)
./bin/devcompanion queue <project> --template code-review --no-llm
```

### 2. Run the oldest pending job

```bash
# Uses LLM if available, skeleton otherwise
./bin/devcompanion run-once

# Force skeleton (no LLM)
./bin/devcompanion run-once --no-llm
```

Artifacts are written to:
`~/.local/share/ai-workspace/dev-companion/queue/artifacts/<job-id>/`

### 3. Check status

```bash
./bin/devcompanion status
```

Shows pending / processing / done / failed jobs and indexed projects.

### 4. Mark done

```bash
./bin/devcompanion done <job-id>
```

Moves the job to `done/` and refreshes `knowledge/todos/pending.md`.

### 5. Sync todos manually

```bash
./bin/devcompanion sync-todos
```

Regenerates `knowledge/todos/pending.md` from current queue state.

---

## Available templates

```bash
./bin/devcompanion templates
```

| Template | Description |
|----------|-------------|
| `code-review` | Full code review for quality, security, maintainability |
| `create-pr` | Push branch and create a draft PR with generated description |
| `refactor` | Scoped refactoring with tests and PR (requires --request for scope) |
| `investigate` | Root cause analysis or open-ended investigation |
| `fix-ci` | Investigate and fix failing CI checks |

### Adding a custom template

```bash
cat > templates/jobs/my-template.yaml << 'EOF'
name: my-template
description: "What this template does"

request: |
  Perform X on the repository. Steps:

  1. First do this
  2. Then do that
  3. Create a PR
EOF
```

---

## Auto-generated files

Do not edit these manually — they are regenerated on every `queue`, `done`, and `sync-todos` call.

| File | Generated from |
|------|---------------|
| `knowledge/todos/pending.md` | Queue state |
| `projects.yaml` | `projects/` symlinks |

---

## Examples

### Code review on a project

```bash
./bin/devcompanion queue my-project --template code-review
./bin/devcompanion run-once
```

### Investigate a bug

```bash
./bin/devcompanion queue my-api --template investigate \
  --request "GET /users returns 500 on empty database"
./bin/devcompanion run-once
```

### Custom one-off task

```bash
./bin/devcompanion queue my-api \
  --request "add pagination to GET /users endpoint, follow existing patterns"
./bin/devcompanion run-once
```

---

## LLM provider order

When `dots_devcompanion_runner` is available, it uses this fallback chain:

1. **opencode** (local, free) — preferred
2. **Ollama** (local, free) — if opencode unavailable
3. **Anthropic** (cloud) — if `ANTHROPIC_API_KEY` set
4. **OpenAI** (cloud) — if `OPENAI_API_KEY` set
5. **Skeleton plan** — if no provider available

Without `dots_devcompanion_runner`, the built-in skeleton runner is used.

---

## Environment variables

| Variable | Purpose |
|----------|---------|
| `AI_WORKSPACE_DC_HOME` | Override queue home directory |
| `ANTHROPIC_API_KEY` | Enable Anthropic LLM provider |
| `OPENAI_API_KEY` | Enable OpenAI LLM provider |

---

## Troubleshooting

### "Project not found"

```bash
./bin/devcompanion projects          # list indexed projects
./bin/project-indexer clone owner/repo   # add missing project
```

### "No pending jobs"

```bash
./bin/devcompanion status            # verify queue state
```

### "Template not found"

```bash
./bin/devcompanion templates         # list available templates
ls templates/jobs/                   # check template files
```
