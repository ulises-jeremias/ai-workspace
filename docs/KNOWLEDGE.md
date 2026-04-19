# Knowledge Base

> Reusable memory for the AI assistant to avoid repeating information.

---

## Purpose

The knowledge base stores:

- **Processes**: How you work with tools (ClickUp, JIRA, Confluence, etc.)
- **Skills**: New capabilities discovered during sessions
- **Learnings**: Patterns, corrections, and insights from work
- **Todos**: Pending items for follow-up

This prevents the AI from asking the same questions repeatedly and preserves hard-won context across sessions.

---

## Structure

```text
knowledge/
├── README.md              # Index
├── skills/
│   └── discovered.md      # New skills found during sessions
├── processes/
│   ├── general.md         # General workflow patterns
│   ├── clickup.md         # ClickUp patterns and IDs
│   ├── jira.md            # JIRA patterns
│   └── confluence.md      # Confluence patterns
├── learnings/
│   └── general.md         # Session learnings and corrections
└── todos/
    └── pending.md         # Pending items (auto-generated if using devcompanion)
```

---

## CLI Usage

### Add new entry

```bash
# New skill discovery
./bin/assistant-memory add --type skill "The dev-assistant skill inspects AGENTS.md first"

# New learning
./bin/assistant-memory add --type learning "Always run tests before committing in this project"

# Pending todo
./bin/assistant-memory add --type todo "Investigate slow query in reports endpoint"
```

### Search knowledge

```bash
./bin/assistant-memory search "deploy"
./bin/assistant-memory search "jira"
```

### List contents

```bash
./bin/assistant-memory list
```

### Review pending items

```bash
./bin/assistant-memory todo
./bin/assistant-memory review
```

### Inject context at session start

```bash
./bin/assistant-memory inject
# Outputs a markdown block — paste it at the start of your AI session
```

---

## Rules

1. **Check before asking** — If we learned something before, use it
2. **Save after learning** — When the user corrects you or teaches something, document it
3. **Save after discovering** — If you find a reusable pattern, record it
4. **Review pending todos** — At session start, check `knowledge/todos/pending.md`

---

## Adding Process Documentation

When you start working with a new tool or project:

1. Create or update `knowledge/processes/<tool>.md`
2. Document: setup, key IDs, common patterns, preferences
3. Keep IDs and config as placeholders if sharing the workspace

Example entry in `processes/jira.md`:

```markdown
## Key Project IDs

| Project | Key |
|---------|-----|
| My API  | API |
| Backend | BE  |
```

---

## Injecting Knowledge at Session Start

For maximum context, paste this at the start of a new AI session:

```bash
./bin/assistant-memory inject
```

Or use `workspace-context` for a full snapshot:

```bash
./bin/workspace-context
```

Both outputs are designed to be pasted directly into an AI conversation.
