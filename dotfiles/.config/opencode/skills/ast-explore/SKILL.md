---
name: ast-explore
description: Efficiently read codebases using tree-sitter based tools (PREFER THIS over raw grep/rg for Rust, Python, Go, Markdown etc)
---

# ast-explore — Structural Code Navigation with ast-outline and ast-grep

## Overview

Two complementary tools for efficient code understanding without reading full file contents:

- **`ast-outline`** — structural navigator: shows signatures, line numbers, docstrings, no bodies. 2–10× smaller than source.
- **`ast-grep`** — pattern searcher: finds AST-level code patterns across a whole codebase. Think "grep that understands syntax."

**Core principle:** Go broad → narrow. Never open a file cold when `ast-outline` gives you the shape for free.

## When to Use

Use this skill any time you are about to:
- `Read` a file you haven't seen before
- `grep` for a function or class definition
- Hunt for callers of an API
- Check where `.unwrap()`, `panic!`, or other patterns appear

**Supported languages (ast-outline):** Rust, Python, TypeScript/JS, Go, Java, Kotlin, Scala, C#, Markdown, YAML, CSS/SCSS, SQL, PHP, Ruby

**ast-grep** supports the full tree-sitter language list. Run `ast-grep run --help` for the lang flag details.

## Workflow: Broad → Narrow

```
New directory/project
        │
        ▼
ast-outline digest <dir>          ← architecture map (may be large; scope to subdir for monorepos)
        │
        ▼
ast-outline <file>                ← file shape: all signatures + line ranges
        │
        ▼
ast-outline show <file> Symbol    ← body of ONE symbol (verify with Read if output looks wrong)
        │
        ▼
Read <file> (offset/limit)        ← fallback only when you need more context
```

**Skip steps freely.** If you already know the symbol name, jump straight to `show`.

**Large codebases:** `digest` on a big monorepo can produce many pages. Scope it: `ast-outline digest crates/lib/` rather than `ast-outline digest crates/`. Add `--no-private --no-fields` to compress further.

## ast-outline Quick Reference

| Goal | Command |
|------|---------|
| Architecture map of a dir | `ast-outline digest <dir>` |
| Compact architecture map | `ast-outline digest <dir> --no-private --no-fields` |
| File structure (no bodies) | `ast-outline <file>` |
| Public API only | `ast-outline <file> --no-private --no-fields` |
| One function/class body | `ast-outline show <file> Symbol` |
| Where things are imported from | `ast-outline <file> --imports` or `ast-outline digest <dir> --imports` |
| Signature only (no body) | `ast-outline show <file> Symbol --signature` |
| Multiple symbols at once | `ast-outline show <file> Foo Bar Baz` |
| Multiple files/dirs at once | `ast-outline digest dir1/ dir2/ file.rs` |

### Reading the Output

```
# crates/blockdev/src/blockdev.rs [large] (931 lines, ~8,873 tokens, 4 types, 40 methods)
pub struct Device  L92-443     ← line range tells you where to Read if needed
    pub name: String  L93
    pub serial: Option<String>  L94
```

Size labels: `[tiny]` `[medium]` `[large]` `[huge]` (≥100k tokens — outline only shows headers in digest).  
`# WARNING: N parse errors` means the outline is partial — fall back to Read for that region.

### Symbol Matching Rules

- Suffix-based: `TakeDamage` matches `Player.TakeDamage`
- Type names return the whole type body
- If a name is **ambiguous** (multiple matches), `show` returns all of them. Disambiguate with `Type.method` or `module::fn_name` syntax.
- Markdown: case-insensitive substring of heading text
- YAML: dotted key path (`spec.containers[0].image`)
- CSS: selector token, pseudos stripped (`.btn-primary` finds `.btn-primary:hover`)
- SQL: table or column name (`users`, `users.email`)

**`--no-private` meaning per language:** Rust — omits non-`pub` items (`pub(crate)` is still shown). Python — omits `_`-prefixed names. TypeScript/Java — omits `private` members.

## ast-grep Quick Reference

`ast-grep` matches **syntax nodes**, not text. `$VAR` captures one node; `$$$` captures zero or more.

| Goal | Command |
|------|---------|
| Find a pattern (one lang) | `ast-grep run --pattern 'PATTERN' --lang LANG .` |
| Find across all files | `ast-grep run --pattern 'PATTERN' --lang LANG <dir>` |
| List files with matches | `ast-grep run --pattern '...' --lang LANG --files-with-matches .` |
| Context lines around match | `ast-grep run -C 3 --pattern '...' --lang LANG .` |
| Rewrite matched pattern | `ast-grep run --pattern 'OLD' --rewrite 'NEW' --lang LANG .` |
| Interactive rewrite | `ast-grep run -i --pattern 'OLD' --rewrite 'NEW' --lang LANG .` |

### Pattern Syntax

```
$NAME        one AST node (any kind)
$$$          zero or more nodes (variadic)
$_           any single node, unnamed capture

# Rust examples
$X.unwrap()                        → find all .unwrap() calls
fn $F($$$) {$$$}                   → all functions (sync or async)
fn $F($$$) -> Result<$$$> {$$$}   → Result-returning functions (sync)
let _ = $EXPR;                     → swallowed/ignored results
```

Patterns match **structure**, not text — whitespace and comments are irrelevant.

**Note on Rust `async fn`:** `async fn $F($$$) -> Result<$$$> {$$$}` may not match because the `async` keyword is a separate AST node. Use `fn $F($$$) {$$$}` (without return type) to capture both sync and async, then filter by the outline if needed.

### Practical Examples

```bash
# Find all .unwrap() calls in a Rust codebase
ast-grep run --pattern '$_.unwrap()' --lang rust .

# Find Python functions using a specific argument name
ast-grep run --pattern 'def $F(self, $$$ctx$$$):' --lang python .

# Find TypeScript async functions
ast-grep run --pattern 'async function $F($$$) {$$$}' --lang typescript .

# Find Go defer calls
ast-grep run --pattern 'defer $F($$$)' --lang go .

# Find where an error is swallowed (Rust)
ast-grep run --pattern 'let _ = $EXPR;' --lang rust .
```

### When ast-grep Beats grep

Use `ast-grep` (not `Grep`/`grep`) when:
- You want **all call sites** of a function, not just the definition
- You want to ignore whitespace, formatting, and comments
- You need to capture sub-parts of a match (`$VAR`)
- You want to refactor: find-and-replace at the AST level

Use `Grep` when:
- Searching in comments, strings, or documentation
- The pattern is a simple literal that doesn't appear in code structure
- You need regex features (lookahead, char classes) with no language semantics needed

## Common Mistakes

**Reading before outlining.** Running `Read file.rs` on a 900-line file when `ast-outline file.rs` gives you the structure in 40 lines.

**Grepping for definitions.** `grep "fn get_user"` finds the definition but also every comment and test. `ast-outline show service.rs get_user` returns only the real definition.

**Forgetting batch support.** Both tools accept multiple paths: `ast-outline digest crates/foo/ crates/bar/` — don't loop.

**Skipping `--imports` when tracing types.** Add `--imports` to `outline`/`digest` to see where a referenced type actually lives, then `show` it there.

**ast-grep pattern too strict.** If a pattern returns nothing, try adding `$$$` to allow extra nodes: `fn $F($$$) {$$$}` instead of `fn $F() {}`. For Rust async functions, drop the `async` keyword from the pattern — it's a separate AST node that can break matching.

**`show` output looks wrong.** If `ast-outline show` returns something unexpected, cross-check with `Read <file> offset=<L> limit=<N>` using the line numbers from `ast-outline <file>`.
