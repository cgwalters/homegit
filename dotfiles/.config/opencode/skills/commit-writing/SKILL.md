---
name: commit-writing
description: MUST use when writing or editing git commit messages, to get the style and the required Assisted-by trailer right
---

Rules for git commit messages, layered on the `text-writing` skill
(load it first for the shared attribution/concision rules).

## Required trailer

Commits you generate MUST end with an `Assisted-by:` trailer
carrying the attribution link from the `text-writing` skill, unless
the project's contributing guidelines prohibit or discourage it, or
the human wrote the message themselves.

Never add a `Signed-off-by` line — that is for the human to do
manually before pushing. If a commit you are rebasing already has a
signoff, keep it.

## Style

Check the repo for a CONTRIBUTING.md or equivalent and follow it.
Otherwise, Linux kernel style:

- Subject line with an imperative mood: "Add integration with...",
  not "Adds integration with...". Prefix with a subsystem when the
  repo uses them (`kernel: Add find API w/correct hyphen-dash equality`).
- Body focuses on *why*, not what — the reader can see the what from
  the diff. A few sentences of design intent or the problem being
  solved is often enough; call out non-obvious consequences briefly.
- Avoid restating the diff, "Changes:" bullet lists of implementation
  details, "Files changed" sections, and generic or robotic tone.

## Amending and review feedback

When addressing review feedback, squash fixes into the relevant prior
commit with `git commit --fixup=<sha>` + `git rebase --autosquash`
(preserve the trailer on the squashed result). Never leave "Address
review feedback" as a standalone commit.

Before pushing or opening a PR, run through the `commit-review`
skill's checklist.
