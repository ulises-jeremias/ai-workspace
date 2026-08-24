# Glossary

Shared terminology for the AI Workspace + agent-toolkit ecosystem.

> **Ecosystem vs discipline:** The *ecosystem* has three layers — Infrastructure (workstation), Capability (agent-toolkit), Workspace (agentic-harness). The *discipline* has Stages 0–3 (Ralph Loop → Context → Harness → Loop Engineering). Loop *tiers* L1/L2/L3 are a third axis (loop autonomy). Don't conflate them.

## A

**agent**
: An AI-driven subprocess managed by the orchestrator. Agents have specialized roles (code review, security, planning) and are listed in `AGENTS.md`. Agents may be deployed as skills or as standalone processes.

**AGENTS.md**
: Root-level file that instructs the AI tool (Claude Code, opencode, Cursor) on how to behave in this workspace. The primary agent contract. Also called CLAUDE.md, GEMINI.md depending on the tool — symlinked to AGENTS.md for portability.

**agentic-harness**
: The persistent reference workspace — a git repository at `~/.agentic-harness` containing knowledge, packs, personas, loops, and project state. The **Workspace Layer** of the personal DX stack. Powered by **agent-toolkit** (Capability Layer). Not a runtime — the runtime CLIs ship from Toolkit.

## C

**context pack**
: See *pack* (workspace pack).

## D

**agentic-workstation**
: The portable workstation baseline — a chezmoi-managed repository at `~/.local/share/agentic-workstation` providing shell, editor, and installer glue for Herdr/tmux. Part of the **Infrastructure Layer**.

**agent-toolkit**
: The capability distribution layer — ships skills, agents, loop/queue/memory/project CLIs, and MCP. The **Capability Layer** that workspaces consume. The sole runtime owner for loops, queues, and skills.

## G

**glossary**
: This file. A shared vocabulary that the workspace, Toolkit, and workstation reference to ensure consistent terminology across docs, code, and agent instructions.

## H

**harness**
: As a *discipline*: Stage 2 (Harness Engineering) — the scaffolding that wraps an agent (routing, telemetry, contracts, sub-agent dispatch). As a *repo*: `agentic-harness`, the Workspace Layer reference implementation. The harness does not ship the loop/queue engines — those are Toolkit's.

## K

**knowledge base**
: The `knowledge/` directory in agentic-harness. Structured markdown files organized by type (skills, processes, learnings, todos) that persist across sessions. The loop's "memory."

## L

**loop**
: A recurring AI-driven process with durable state, safety gates, and cost budgets. Managed by `agent-toolkit loop`. Each loop has a LOOP.md definition, STATE.md state, and `runs/` directory with trace artifacts. Stage 3 discipline.

**loop run**
: A single execution of a loop. Creates a run directory with trace.jsonl, plan.md, and any output artifacts. Encoded as `runs/<run-id>/`.

**loop tier**
: Autonomy level for loops — L1 (report-only), L2 (PR-gated), L3 (unattended on allowlist). This is the *autonomy* axis, distinct from discipline Stages 1–3 and ecosystem layers.

**loop closure**
: The process of extracting learnings and decisions from a completed loop run and writing them back to the knowledge base. Ensures the loop improves over time.

## M

**MCP**
: Model Context Protocol — a standard for AI tools to interact with external systems (filesystem, GitHub, databases). agent-toolkit ships MCP templates.

## P

**pack**
: Two distinct meanings — don't conflate:
: - **Workspace pack** (`packs/*.yaml` in this repo): a context bundle for a specific client/project (repos, IDs, conventions). Loaded by `agent-toolkit workspace load packs/<name>.yaml`. Machine-local or committed per policy.
: - **Toolkit pack** (in `agent-toolkit`): a reusable capability bundle (skills, agents, prompts) distributed by the Capability Layer.

**persona**
: Two layers:
: - **Toolkit catalog** (`agent-toolkit` agents/): generic definitions (implementer, reviewer, researcher, architect, writer, debugger, tester, security-reviewer, …).
: - **Workspace selections** (`personas/*.md` in this repo): the workspace's active bindings — which personas are available and how they hand off in this workspace.

: Each persona declares allow/deny action lists, output format, and handoff rules. Activated by `agent-toolkit workspace use-persona <name>`.

**profile**
: A composable configuration that bundles a pack + persona. Listed by `agent-toolkit workspace profiles` and loaded with `agent-toolkit workspace load --profile <name>`.

## R

**runner**
: The agentic-workstation dev companion runner — a background process that executes loop jobs. Invoked by `agent-toolkit loop run` when available. Falls back to skeleton mode without agentic-workstation.

## S

**skill**
: A self-contained AI instruction bundle with `SKILL.md` (human-readable) and `skill.json` (manifest). Skills are the unit of distribution in **agent-toolkit**. They declare capabilities, boundaries, triggers, dependencies, and compatibility.

**skill catalog**
: `skill-catalog.yaml` — the agent-toolkit orchestration metadata file that maps skills to domains, responsibilities, roles, and dependency graph.

**snapshot**
: The output of `agent-toolkit workspace context` — a machine-readable summary of the current session state including active persona, loaded pack, spec hash, and persona constraints.

**stage**
: A discipline stage — Stage 0 (Ralph Loop), Stage 1 (Context Engineering), Stage 2 (Harness Engineering), Stage 3 (Loop Engineering). Distinct from ecosystem layers and loop tiers.

## T

**trace**
: A JSONL file at `runs/<run-id>/trace.jsonl` that records every event during a loop run (run_start, worktree_created, decision, run_end, etc.). Used for audit and loop closure.

## W

**worktree**
: A detached git checkout created by `agent-toolkit loop run` to execute work on a clean copy of the workspace. Automatically removed after the run completes or is cancelled.

**workspace**
: This repo when cloned — the persistent stateful directory that holds knowledge, packs, persona selections, and loop state. Same as `agentic-harness` in its Workspace Layer role.

**Workspace Layer**
: The persistent workspace/reference implementation layer of the personal DX stack. Currently `agentic-harness`. Holds durable state; consumes CLIs from agent-toolkit (Capability Layer).

**agent-toolkit workspace**
: The session snapshot CLI at `agent-toolkit workspace context`. Prints active state, loads packs/personas/profiles, validates schemas, and manages persona handoffs.
