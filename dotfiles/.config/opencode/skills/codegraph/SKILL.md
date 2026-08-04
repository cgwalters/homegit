---
name: codegraph
description: Cross-file call-graph and symbol search over a local SQLite index (CodeGraph CLI). Use for "how does X work", tracing callers/callees before a refactor, or blast-radius/affected-tests questions on a codebase big enough that grep round-trips are slow.
---

# codegraph — Local Code Knowledge Graph (CLI-only)

## Overview

[CodeGraph](https://github.com/colbymchenry/codegraph) builds a local SQLite graph of
symbols, calls, and imports for a project, using a Rust/tree-sitter kernel. It's
installed here as a **plain CLI** (`codegraph`, in `~/.local/bin`) — deliberately
**not** wired up as an MCP server. That means: no background daemon, no file watcher,
no auto-sync. You call it like any other CLI tool via `bash`, and you're responsible
for telling it when to (re)index.

Each project gets its own index under `<project>/.codegraph/` (SQLite + FTS5). Nothing
is shared between projects; nothing leaves the machine except anonymous usage counters
(telemetry is off — see below).

## When to Use

- "How does X work / how does X reach Y" in a codebase with more than a handful of
  files → `codegraph explore`
- Finding every caller/callee of a function before renaming or removing it → `callers`
  / `callees` / `impact`
- "Which tests should I run after touching these files" → `affected`
- Cross-file call-chain questions that would otherwise need several rounds of
  `grep`/`ast-grep` and manual stitching

Skip it for small projects or docs-only repos (this very repo, for instance) — `Grep`
and `Read` are simpler and indexing overhead isn't worth it. Prefer `ast-explore`
(ast-outline/ast-grep) for single-file structure or pure syntax-pattern search; reach
for `codegraph` when the question spans files via calls/imports.

## One-Time Setup Per Project

```bash
codegraph init <path>          # builds .codegraph/ and runs the first full index
```

`.codegraph/` is **not** auto-added to `.gitignore` — add it yourself the first time
you init a project:

```bash
echo '.codegraph/' >> .gitignore
```

## Keeping the Index Fresh

There is no watcher in this CLI-only setup, so the index goes stale as soon as files
change. Before trusting `query`/`explore`/`callers`/etc. results, sync:

```bash
codegraph sync <path>          # incremental update since last index
codegraph status <path>        # sanity check: shows pending-sync state, symbol counts
```

Cheap enough to run before every non-trivial codegraph command if you've edited files
since the last sync.

## Command Reference

| Goal | Command |
|------|---------|
| First-time index a project | `codegraph init <path>` |
| Re-sync after edits | `codegraph sync <path>` |
| Full re-index from scratch | `codegraph index <path>` |
| Check index health / staleness | `codegraph status <path>` |
| Remove the index | `codegraph uninit <path>` |
| **Explore an area (flagship)** | `codegraph explore <query...> [-p path] [--max-files N]` |
| Search symbols by name | `codegraph query <search> [-k kind] [-l limit] [-j]` |
| One symbol's source + call trail | `codegraph node <name> [-p path]` |
| Read a file with line numbers + dependents | `codegraph node -f <file> [--offset N] [--limit N] [--symbols-only]` |
| Project file structure | `codegraph files [--filter dir] [--pattern glob] [--format tree\|flat\|grouped]` |
| Who calls this symbol | `codegraph callers <symbol> [-l limit] [-j]` |
| What this symbol calls | `codegraph callees <symbol> [-l limit] [-j]` |
| Blast radius of changing a symbol | `codegraph impact <symbol> [-d depth] [-j]` |
| Test files affected by changed source | `codegraph affected [files...] [--stdin] [-d depth] [-f glob]` |

Add `-j`/`--json` to most commands for machine-readable output. All commands accept
`-p <path>` for the project root when you're not already there.

## Practical Examples

```bash
# "How does auth flow through this service?"
codegraph explore "authentication middleware" -p .

# Before renaming a function, find every call site
codegraph callers processPayment

# What would break if I change this function's signature?
codegraph impact processPayment -d 3

# Pipe a git diff's changed files to find affected tests
git diff --name-only main | codegraph affected --stdin

# Read a file with dependents, without dumping the whole thing
codegraph node -f src/billing/invoice.ts --symbols-only
```

## Common Mistakes

**Querying a stale index.** If you've been editing files in the same session, run
`codegraph sync <path>` first — there's no watcher doing it for you in this CLI-only
setup.

**Reaching for `codegraph` on a tiny/docs repo.** The setup and sync overhead isn't
worth it below a few dozen source files; use `Grep`/`ast-explore` instead.

**Forgetting `.gitignore`.** `codegraph init` does not gitignore `.codegraph/` for you.

**Confusing this with the MCP integration.** This install intentionally skips
`codegraph install` (which registers an MCP server + auto-sync daemon per-agent). If a
project turns out to need continuous auto-sync across many active editing sessions,
`codegraph install --target opencode` is the documented way to add that — this skill
just covers the lighter CLI-only workflow.

## Telemetry

CodeGraph telemetry is anonymous (no code, paths, or queries — see
[TELEMETRY.md](https://github.com/colbymchenry/codegraph/blob/main/TELEMETRY.md)) but
on by default. It has been turned off on this machine via `codegraph telemetry off`.
