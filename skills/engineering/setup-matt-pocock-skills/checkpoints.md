# Checkpoints

When an agent working in this repo stops and asks the user before going on. The agents do the work; the user sets direction and approves the steps below. Edit this list to tune how much control you keep: every skill reads it.

## Always stop and ask

- **Direction**: changing the scope, the destination of a wayfinder map, or what a ticket or spec delivers.
- **Architecture**: any decision that would deserve an ADR (hard to reverse, surprising without context, the result of a real trade-off).
- **New dependencies**: adding a package, service, or third-party API.
- **Human-only steps**: anything needing credentials, a dashboard, payment, or a manual action. Stop and recommend `/wizard` for it; never invent values or leave the step half done.
- **Critical review findings**: a `code-review-3axis` verdict of **Merge-ready: no**.
- **Merging**: the user merges every PR. Agents open and update PRs, never merge them, and never push to the default branch.

## Never stop for

Routine work inside an agreed ticket: creating branches, committing, pushing to non-default branches, opening or updating PRs, fixing `medium` and `low` review findings, and replying to review comments.

## How to stop

Write a short brief: what you were doing, the decision needed, your recommendation, and the options. When the work has a PR, also post the brief there as a comment starting with `> *Agent:*`, so the decision is recorded where the user reviews.
