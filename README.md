# AI Workspace

> A portable agentic harness — persistent memory, project context, and workflow orchestration for your AI assistant.

[![CI](https://github.com/ulises-jeremias/ai-workspace/actions/workflows/ci.yml/badge.svg)](https://github.com/ulises-jeremias/ai-workspace/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Works with Claude Code, OpenCode, Cursor, Gemini CLI, and GitHub Copilot.

---

## What is this?

The **AI Workspace** is a framework that sits between you and your AI tool. It gives your AI:

- **Persistent memory** across sessions via `knowledge/`
- **Project context** with symlinked repos and packs
- **Workflow orchestration** with skills, personas, and job queues
- **Consistent conventions** so the AI knows *how* to work, not just *what* to do

```text
Your AI Tool  ←→  AI Workspace  ←→  Your Repos
               (this repo)
               Memory, context,
               routing, skills
```

### Companion to dots-ai

This workspace is designed to work alongside [dots-ai](https://github.com/ulises-jeremias/dots-ai) — the workstation layer that distributes AI skills, agents, MCP templates, and CLI helpers. While `dots-ai` manages the **tooling installation**, this workspace manages the **runtime context** — memory, project switching, and orchestration.

You can use this workspace **standalone** (works perfectly without `dots-ai`) or as its natural runtime companion.

---

## Quick Start

```bash
# 1. Clone as your personal workspace
git clone https://github.com/ulises-jeremias/ai-workspace.git ~/.ai-workspace
cd ~/.ai-workspace

# 2. Run setup wizard
./scripts/workspace-init.sh

# 3. Index your repos
./bin/project-indexer clone owner/my-repo

# 4. Open in your AI tool — reads AGENTS.md automatically
opencode        # or: claude / cursor / gemini
```

### One-liner (fresh start, no upstream history)

```bash
git clone https://github.com/ulises-jeremias/ai-workspace.git ~/.ai-workspace \
  && cd ~/.ai-workspace \
  && rm -rf .git && git init \
  && ./scripts/workspace-init.sh
```

---

## Structure

```text
ai-workspace/
├── AGENTS.md              # AI orchestration instructions (main config)
├── CLAUDE.md              # Symlink → AGENTS.md (OpenCode / Cursor)
├── GEMINI.md              # Symlink → AGENTS.md (Gemini CLI)
├── CONTRIBUTING.md        # How to extend the workspace
├── LICENSE                # MIT
├── bin/
│   ├── project-indexer    # Clone repos + manage symlinks
│   ├── assistant-memory   # Knowledge base CLI
│   ├── devcompanion       # Background job queue
│   └── workspace-context  # Session state snapshot
├── docs/                  # Guides and references
├── knowledge/             # Persistent AI memory (processes, learnings, todos)
├── personas/              # Work mode definitions (implementer, reviewer, etc.)
├── packs/                 # Context bundles per client/project
├── templates/jobs/        # Job templates for devcompanion
├── projects/              # Symlinks to repos (gitignored, local)
└── repos/                 # Cloned repos (gitignored, local)
```

---

## Docs

| Guide | Description |
|-------|-------------|
| [`docs/SETUP.md`](docs/SETUP.md) | Initial setup and AI tool configuration |
| [`docs/METHODOLOGY.md`](docs/METHODOLOGY.md) | The agentic harness philosophy |
| [`docs/WORKFLOWS.md`](docs/WORKFLOWS.md) | Task routing and skill usage patterns |
| [`docs/PERSONAS.md`](docs/PERSONAS.md) | Work mode personas |
| [`docs/PACKS.md`](docs/PACKS.md) | Context packs for project switching |
| [`docs/PROJECTS.md`](docs/PROJECTS.md) | Managing repos and symlinks |
| [`docs/DEVCOMPANION.md`](docs/DEVCOMPANION.md) | Background job queue guide |
| [`docs/KNOWLEDGE.md`](docs/KNOWLEDGE.md) | Knowledge base usage |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | How to extend and contribute |

---

## Key Concepts

### Agentic Harness

The workspace acts as a **harness** — it doesn't replace your AI tool, it amplifies it by providing context, memory, and routing that survives across sessions.

### Ralph Loop

The four-layer loop your AI runs in:

```text
Backing Specs → Context Engineering → Persistent Memory → Fix the Loop
```

Each session, the AI reads `AGENTS.md` → checks `knowledge/` → works → saves discoveries back. The loop improves itself over time.

### Personas

Personas constrain what the AI *does* in a session — not who it is. `personas/reviewer.md` means "analyze and report, no changes". Use them to avoid scope creep.

### Packs

Packs bundle project-specific context (repos, process docs, IDs) so you can switch between clients with a single command.

---

## Integration with dots-ai

If you have [dots-ai](https://github.com/ulises-jeremias/dots-ai) installed:

| dots-ai provides | This workspace provides |
|------------------|------------------------|
| Skills installation (`dots-skills`) | Runtime skill routing |
| Agent definitions (subagents) | Orchestration layer (`AGENTS.md`) |
| CLI helpers (`dots-*`) | Project management (`bin/`) |
| Dev companion runner | Dev companion queue + templates |
| Health check (`dots-doctor`) | Workspace state (`bin/workspace-context`) |

The `devcompanion` in this workspace can delegate to `dots-devcompanion` for LLM-powered execution when available.

---

## Validation

```bash
# Verify setup
./bin/project-indexer list          # shows indexed repos
./bin/assistant-memory todo         # shows pending items
./bin/workspace-context             # session state snapshot

# Queue a test job
./bin/devcompanion queue my-project --template code-review
./bin/devcompanion run-once --no-llm
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `project-indexer: command not found` | Run `chmod +x ./bin/*` |
| DevCompanion: "No LLM provider" | Set `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` |
| Pending jobs stuck | Run `./bin/devcompanion status` |
| Skills not loading | Check your AI tool's skill pack configuration |
| dots-ai not detected | Install from [github.com/ulises-jeremias/dots-ai](https://github.com/ulises-jeremias/dots-ai) |

---

## License

MIT — see [LICENSE](LICENSE)
