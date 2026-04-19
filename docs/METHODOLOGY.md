# Methodology — The Agentic Harness

> Why this workspace exists and how it's designed to work.

---

## The Problem

AI tools are **stateless by default**. Every session starts fresh. Your AI assistant doesn't remember:

- What you told it about your project last week
- The ID of that ClickUp space you looked up three times
- The convention you corrected it on
- The todo you said "we'll handle that later"

You end up re-teaching the AI every session. The AI repeats the same mistakes. Patterns get lost.

---

## The Solution: Ralph Loop

> *Named after Geoffrey Huntley's "RALPH" model — see [ghuntley.com/loop](https://ghuntley.com/loop/)*

The AI Workspace implements the **Ralph Loop** — a four-phase feedback cycle:

```text
┌─────────────────────────────────────────────────────────┐
│                      Ralph Loop                          │
│                                                          │
│  Backing Specs  →  Context Engineering                   │
│       ↑                   ↓                              │
│  Fix the Loop  ←  Persistent Memory                      │
└─────────────────────────────────────────────────────────┘
```

### Layer 1 — Backing Specs

`AGENTS.md` is the backing spec. It tells the AI:

- What this workspace is for
- How to route tasks (which skill/subagent to use)
- What rules to follow
- What knowledge base to check

Every session, the AI reads `AGENTS.md` first. This is the **invariant** — the spec that doesn't change session to session.

### Layer 2 — Context Engineering

Context engineering means giving the AI exactly the right information at the right time:

- **Personas** constrain scope (reviewer sees but doesn't touch)
- **Packs** inject project-specific context (IDs, repos, conventions)
- **`workspace-context`** snapshots current state (todos, learnings, active project)

Good context engineering means the AI doesn't need to ask — it already knows.

### Layer 3 — Persistent Memory

`knowledge/` is the persistent memory layer:

- **Learnings**: corrections, patterns, preferences
- **Processes**: tool IDs, workflows, conventions
- **Todos**: deferred work
- **Skills**: new capabilities discovered

Every session should end with new discoveries saved. `assistant-memory add` is the write operation. `assistant-memory inject` is the read operation (paste at session start for maximum context).

### Layer 4 — Fix the Loop

The loop improves itself. When you correct the AI, it saves the correction. When it discovers a better pattern, it documents it. When a skill is missing from `AGENTS.md`, you add it.

The workspace gets smarter over time because the specs improve.

---

## Architecture Principles

### Stateless Sessions, Stateful Workspace

The AI session is stateless — each conversation is fresh. But the **workspace is stateful** — `knowledge/` persists across sessions. The gap between them is closed by `assistant-memory inject` and persona/pack loading.

### Orchestrator, Not Expert

The orchestrator session (`AGENTS.md`) doesn't try to be an expert at everything. It:

1. Understands what type of task this is
2. Delegates to the right skill or subagent
3. Reports results
4. Saves knowledge

Specialists (code-reviewer, security-reviewer, etc.) are better than a generalist at everything.

### Portable by Design

The workspace works with any AI tool that reads a file at session start:

| Tool | File |
|------|------|
| Claude Code | `AGENTS.md` |
| opencode | `AGENTS.md` |
| Cursor | `CLAUDE.md` → symlink |
| Gemini CLI | `GEMINI.md` → symlink |
| GitHub Copilot | `.github/copilot-instructions.md` → symlink |

One source of truth, multiple tool surfaces.

### Fork-and-Own

This framework is designed to be cloned and customized. There's no "right" configuration — your `AGENTS.md`, your `knowledge/`, your personas are yours. The upstream provides the scaffolding; you provide the specificity.

---

## Workflow Lifecycle

```text
Session Start
    │
    ▼
1. AI reads AGENTS.md
    │
    ▼
2. (Optional) Load pack or persona
    │
    ▼
3. Run: ./bin/workspace-context (inject state)
    │
    ▼
4. Work: discover → delegate → implement
    │
    ▼
5. Save: ./bin/assistant-memory add --type learning "..."
    │
    ▼
Session End
```

---

## Key Commands at Each Phase

```bash
# Session start
./bin/workspace-context                    # get state snapshot
./bin/assistant-memory inject              # inject knowledge context
./bin/workspace-context use-persona reviewer  # activate a persona

# During work
./bin/assistant-memory search "topic"      # check what we know
./bin/devcompanion queue my-project --template code-review  # queue background work

# Session end
./bin/assistant-memory add --type learning "Always do X before Y in this repo"
./bin/assistant-memory add --type todo "Follow up on the auth migration"
```
