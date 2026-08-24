# Methodology — From Prompting to Loops

> How this workspace is designed and why it works.
> The harness is the **Workspace Layer** — a persistent reference workspace. The runtime is **agent-toolkit** (Capability Layer).

---

## The Discipline Stages

Three discipline stages layer on top of each other to take you from "typing prompts" to "designing autonomous AI processes":

| Stage | Question | What it does |
|-------|----------|-------------|
| **Stage 1 — Context engineering** | What does the agent *know* before it acts? | Schemas, packs, personas, knowledge base |
| **Stage 2 — Harness engineering** | What *scaffolds and observes* the agent? | Routing, telemetry, contracts, sub-agent dispatch |
| **Stage 3 — Loop engineering** | How does work *repeat autonomously*? | Schedulers, STATE/LOOP spine, maker/checker, cost budgets |

Each stage builds on the one below. You can use context engineering alone; to get loops, you need all three.

> **Stages vs loop tiers:** Stages describe the *discipline* (what you build). Loop tiers L1/L2/L3 describe *loop autonomy* (report-only / PR-gated / unattended on allowlist). A Stage 3 loop can run at tier L1, L2, or L3. Don't conflate them. See [docs/LOOPS.md](LOOPS.md#rollout-tiers).

---

## Stage 0 — The Ralph Loop Foundation

> *Named after Geoffrey Huntley's "RALPH" model — [ghuntley.com/loop](https://ghuntley.com/loop/)*

Everything builds on the Ralph Loop — a four-phase feedback cycle:

```text
┌─────────────────────────────────────────────────────────┐
│                      Ralph Loop                          │
│                                                          │
│  Backing Specs  →  Context Engineering                   │
│       ↑                   ↓                              │
│  Fix the Loop  ←  Persistent Memory                      │
└─────────────────────────────────────────────────────────┘
```

1. **Backing Specs** (`AGENTS.md`) — the invariant that doesn't change session-to-session
2. **Context Engineering** — inject the right information at the right time
3. **Persistent Memory** (`knowledge/`) — what we learned carries forward
4. **Fix the Loop** — specs and knowledge improve over time

The Ralph Loop turns each session into a training run for the next one.

---

## Stage 1 — Context Engineering

> *What does the agent know before it acts?*

Context engineering is the practice of giving the agent exactly the right information — no more, no less — so it can act correctly without asking.

### Surfaces

| Surface | What it provides | Where |
|---------|-----------------|-------|
| `AGENTS.md` | Orchestration rules, routing table, skill list | Repo root |
| `packs/*.yaml` | Workspace context bundles: repos, IDs, conventions | `packs/` (workspace) |
| `personas/*.md` | Behavioral constraints: allow/deny/handoffs | `personas/` (workspace selections) |
| `profiles/*.yaml` | Composable sessions: pack + persona + skills | `profiles/` |
| `knowledge/` | Persistent cross-session memory | `knowledge/` |

> Packs/personas in this workspace are *workspace state* (which projects, which modes). Reusable capability packs and generic persona catalogs live in **agent-toolkit**. See [docs/PACKS.md](PACKS.md) and [docs/PERSONAS.md](PERSONAS.md).

### Rules for good context engineering

1. **Validate every surface** — use `agent-toolkit workspace validate` to catch schema violations before they confuse the agent
2. **Tag knowledge entries** — `tags`, `project`, `created`, `stale_after` let you filter at retrieval time
3. **Keep personas narrow** — a reviewer persona that can accidentally commit is a safety hazard
4. **Load before you work** — `agent-toolkit workspace load --profile <name>` is one command to prime the session

---

## Stage 2 — Harness Engineering

> *What scaffolds and observes the agent during the run?*

The harness is the scaffolding that wraps the agent: routing, telemetry, contracts, sub-agent dispatch. It makes the agent's behavior observable and reproducible.

### Components

| Component | Role |
|-----------|------|
| `AGENTS.md` routing table | Dispatch the right skill or sub-agent per task type |
| `agent-toolkit workspace context` snapshot | Record the spec hash and active pack at session start |
| Job templates (`templates/jobs/`) | Declared contract: inputs, outputs, exit criteria |
| `agent-toolkit devcompanion` job queue | Background work with artifact output |
| Schema validation CI | Catch malformed context before it reaches the agent |

> All CLIs are shipped by **agent-toolkit**. The harness owns the schemas, templates, and durable state that those CLIs operate on.

### The AGENTS.md spec hash

Every session records which version of `AGENTS.md` it ran under:

```text
Spec       : AGENTS.md@ca723537e215
```

When you update `AGENTS.md`, the hash changes. Mismatches indicate that a session ran on a stale spec.

---

## Stage 3 — Loop Engineering

> *How does work repeat autonomously?*
> "You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents."
> — Peter Steinberger

A **loop** is a recurring goal: you define a purpose and the AI iterates — with sub-agents, verification, and external state — until the goal is met or the loop decides to hand off to you.

### The 6 parts of a loop

| Part | Role |
|------|------|
| **Automation / Scheduling** | When does the loop fire? (cron, timer, trigger) |
| **Worktree isolation** | Each run gets its own git worktree |
| **Skills** | Reusable task prompts (from `agent-toolkit`) |
| **Plugins / Connectors** | MCP and CLI reach (GitHub, ClickUp, CI) |
| **Sub-agents** | Maker (implementer) + Checker (verifier receipt / skill) |
| **Memory / State spine** | `LOOP.md` (intent) + `STATE.md` (current state) |
| **Hard gate** | `agent-toolkit loop` wraps `gh` during runs (allowlist/deny/receipts) |

### Rollout tiers

Always start at L1. Graduate to L3 only with a proven allowlist.

| Tier | Autonomy | When |
|------|----------|------|
| **L1** | Report-only | Exploring a new loop pattern |
| **L2** | Assisted (allowlisted mutations) | Actions verified; humans still own merge |
| **L3** | Unattended on allowlist | High-confidence, narrow scope + hard gate |

> These are **loop tiers** (autonomy), not discipline Stages. A Stage 3 loop at tier L1 only reports; at tier L3 it may act unattended within its allowlist.

### Quick start

```bash
# Scaffold from a reference pattern
agent-toolkit loop init daily-triage

# Run once to see what it would do (L1 = report only)
agent-toolkit loop run daily-triage

# Review the output
cat loops/daily-triage/runs/<id>/report.md

# Check cost so far
agent-toolkit loop audit daily-triage
```

See [docs/LOOPS.md](LOOPS.md) for the full reference.

---

## Glossary

| Term | Definition |
|------|-----------|
| **backing spec** | `AGENTS.md` — the invariant orchestration instructions |
| **pack** | `packs/*.yaml` — workspace context bundle (distinct from Toolkit capability packs) |
| **persona** | `personas/*.md` — workspace persona selection (binding to Toolkit's catalog) |
| **profile** | `profiles/*.yaml` — pack + persona + skills composition |
| **knowledge** | `knowledge/` — persistent cross-session memory |
| **harness** | Scaffolding that wraps an agent (routing, contracts, telemetry) — Stage 2 discipline |
| **loop** | Recurring autonomous process with STATE/LOOP spine — Stage 3 discipline |
| **loop tier** | L1 (report) / L2 (PR-gated) / L3 (unattended on allowlist) — autonomy axis, not Stage |
| **maker** | Implementer sub-agent in a loop |
| **checker/verifier** | Verifier sub-agent in a loop; signs off before writes |
| **worktree** | Isolated git working tree created per loop run |
| **exit condition** | DSL signal that ends a loop iteration (goal_met, budget_exhausted, …) |

---

## Workflow Lifecycle

```text
Session Start
    │
    ▼
1. AI reads AGENTS.md (spec hash recorded)
    │
    ▼
2. Load pack or profile
    agent-toolkit workspace load --profile oss-contrib
    │
    ▼
3. Prime context
     agent-toolkit workspace context         # state snapshot
     agent-toolkit memory inject             # knowledge dump
     agent-toolkit memory todo               # pending follow-ups
    │
    ▼
4. Work (discover → delegate → implement)
    │
    ▼
5. Save
    agent-toolkit memory add --type learning "..."
    │
    ▼
Session End
    │
    ▼
Loop runs autonomously between sessions (if configured)
```

---

## Key Commands

```bash
# Context
agent-toolkit workspace validate          # check schema violations
agent-toolkit workspace load --profile oss-contrib
agent-toolkit memory search --tag oss "deploy"
agent-toolkit memory review --stale     # check decayed entries

# Loops
agent-toolkit loop init daily-triage              # scaffold from template
agent-toolkit loop run daily-triage              # one iteration
agent-toolkit loop status                        # all loops at a glance
agent-toolkit loop audit                         # cost and success rate
agent-toolkit loop cost daily-triage             # estimate per run

# Background work (one-shot)
agent-toolkit devcompanion queue my-project --template code-review
agent-toolkit devcompanion run-once
```
