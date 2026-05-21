---
name: commit-review
description: Review commits before pushing or opening a PR — checklist for message quality, code hygiene, testing, and Rust-specific concerns
---

# commit-review — Pre-push / Pre-PR Commit Checklist

## When to Load This Skill

Load this skill before:
- Pushing a branch or opening a pull request
- Declaring a commit task complete after implementation work
- Reviewing someone else's commits at their request
- Responding to PR feedback (to verify fixup handling is correct)

## Workflow

### 1. Get the diff

```bash
# Single tip commit
git diff HEAD~1..HEAD

# All commits since diverging from main
git log --oneline main..HEAD
git diff main..HEAD
```

### 2. Run the checklist

Work through each section below. Fix issues before proceeding.

### 3. Fix and squash

For anything that needs fixing:

```bash
# Fix the code/message, then squash into the right commit
git add -p                          # stage only relevant hunks
git commit --fixup=<hash>           # create a fixup commit
git rebase --autosquash main        # fold fixups into place
```

Never leave `fixup!` commits or "Address review feedback" standalone commits in history. Squash them before the branch is merged.

---

## Checklist

### Commit Message Quality

Subject line format: `component: Verb summary` — imperative mood, no trailing period, ≤72 chars. Good: `auth: Add token refresh on 401`. Bad: `Fixed the login bug`.

Body answers **why**, not what. A reviewer can read the diff; they cannot read your mind. Skip the body only for truly self-evident changes.

Specifically avoid in the body:
- "Changed X to Y" — that's what the diff shows
- `Changes:` / `Files changed:` bulleted lists of implementation details
- Restating the subject line in prose

Trailers to check:
- `Assisted-by:` present (unless the project explicitly prohibits it)
- No `Signed-off-by:` (that's for the human to add manually before push)
- `Closes: #N` if the commit resolves a tracked issue

### Commit Organization

Each commit should be a coherent, reviewable unit. Check that:
- Formatting/whitespace changes are not mixed with logic changes
- "Prep" commits that rename or restructure are separate from behavioral changes
- No commit silently depends on a later commit to compile or pass tests (bisectability)

### Code Quality

**No duplicate utilities.** Before introducing a new helper, check that one doesn't already exist:

```bash
# Example: looking for an existing path-joining helper
rg 'fn join_path\|fn build_path\|fn make_path' src/
```

**No magic strings or numbers.** Literals used more than once or whose meaning isn't obvious at the call site should be constants.

**Error handling.** Every `?` propagation should carry enough context for a user to locate the problem. Prefer `.with_context(|| format!("...: {path}"))` over bare `?`.

**No parsing structured data with text tools.** If the input is JSON, TOML, YAML, XML — use a proper parser. `grep`/`sed`/`awk` on structured formats is fragile and wrong.

### Testing

- New behavior should have tests. Ask: "if someone broke this, would CI catch it?"
- Prefer table-driven / data-driven tests over one-function-per-case. A `vec![]` of `(input, expected)` pairs is almost always cleaner.
- Tests should assert the right thing, not just "it didn't panic".

### Rust-Specific

- No new `unsafe` block without a `// SAFETY:` comment explaining the invariant.
- `.unwrap()` on a `Result` or `Option` in non-test code needs justification. Prefer `.context("...")` (anyhow) or `.expect("invariant: ...")` with an explanation.
- Prefer `rustix` over `libc` for syscall wrappers — safer types, no raw pointers.
- TOCTOU: never do `if path.exists() { open(path) }`. Open directly and handle the error.
- Before adding a new dependency, check whether an existing crate already in `Cargo.toml` covers it, or whether a well-known alternative (`bstr`, `camino`, `rustix`, etc.) is a better fit.

### Architecture

- Does the change introduce shared mutable state that could be avoided?
- Is the public API surface reasonable, or is implementation detail leaking?
- If a non-obvious consequence exists (e.g. "this makes the manifest part of the GC root"), does the commit message call it out?

---

## Final Diff Sanity

```bash
git status                          # no unintended tracked changes
git diff HEAD~1..HEAD --stat        # verify file list looks right
git diff HEAD~1..HEAD               # skim for debug prints, TODOs in hot paths, accidental binary changes
```

Red flags to scan for:
- `dbg!`, `println!`, `console.log`, `fmt.Println` left in production paths
- `TODO` / `FIXME` / `HACK` added in non-test code without an issue reference
- Large binary files (check `--stat` for unexpectedly large sizes)
- `.env`, credential files, or private keys
