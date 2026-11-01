# Area doc seed

Write this to `docs/specialists/<area>/README.md`. The headings marked _(all areas)_ apply to every area; the middle sections are the **product** worked example, so swap them for the area's own (game design: core loop, mechanics, progression, economy; systems: modules, integrations, performance budgets).

```markdown
# <Area> specialist

Owned by the `specialist-<area>` agent. Scope: <one line>. Borders: <other areas and their specialists>.

## Principles _(all areas)_

The few rules that settle most questions in this area. Each one line, each traceable to a decision below or an ADR.

## Users and problems

Who the product is for and the problems it solves for them, most important first. Use `GLOSSARY.md` terms.

## Value proposition

Why these users pick this product over the alternatives, in two or three sentences.

## Priorities

What matters now, in order, and what is explicitly not a priority yet.

## Success metrics

How the project knows the product works: each metric, its target, and how it's measured.

## Decisions _(all areas)_

Newest first. One line each:

- <YYYY-MM-DD>: <decision>. Decided by <user|agent>. <link to PR / issue / ADR>

## Open questions _(all areas)_

Gaps the specialist couldn't fill from the repo. Each one says who can answer it.
```
