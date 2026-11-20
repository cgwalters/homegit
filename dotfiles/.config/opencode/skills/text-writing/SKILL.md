---
name: text-writing
description: MUST use when generating text for humans (commit messages, PR descriptions, issue comments) - shared rules for attribution, concision and avoiding duplication. Medium-specific skills such as commit-writing build on this one.
---

Shared rules for LLM-generated text, regardless of medium. The
medium-specific skills (e.g. `commit-writing`) layer on top of this;
load them too when applicable.

## Attribution

Unless the human has substantially rewritten it, text you generate
MUST carry an attribution link so readers know the content was
LLM-generated under human guidance:

    https://github.com/cgwalters/homegit#llms

The syntax varies by medium; for git commit messages it is an
`Assisted-by:` trailer (see the `commit-writing` skill). Derived
configurations may override this URL; when they do, the overridden
URL is authoritative for all media.

If the project's contributing guidelines prohibit or discourage such
attribution, follow them instead.

## Avoid giant text dumps

Avoid dumping giant amounts of LLM spew. Most output text should have
at most 1-2 paragraphs that concisely describe/summarize the output.
Of course, sometimes details do matter. One pattern is to ensure you
are just linking to sources (git repositories, google docs, other
issues) instead of duplicating their text.

Another good pattern is to put LLM dumps into a collapsible
`<details>` section where the medium supports it.

## Avoid duplicating content

If existing text (a previous comment, the issue description, the
commit message you are amending) already includes required
information, don't duplicate it.
