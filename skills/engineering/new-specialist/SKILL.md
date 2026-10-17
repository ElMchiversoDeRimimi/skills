---
name: new-specialist
description: "Create an area specialist (product, game design, systems...): a project subagent that owns its area's docs and that other skills consult instead of loading the whole project."
disable-model-invocation: true
argument-hint: "The area, e.g. product"
---

A **specialist** is a project subagent that owns one **area** of the project: it keeps that area's knowledge in `docs/specialists/<area>/README.md`, answers questions about it from a fresh context, and records area decisions as they land. Other skills consult it through the registry in `docs/agents/specialists.md` instead of loading the whole project. It recommends; the user decides direction.

The registry should exist. If `docs/agents/specialists.md` is missing, tell the user to run `/setup-matt-pocock-skills` and stop.

Stop and ask at every checkpoint in `docs/agents/checkpoints.md`.

## Steps

### 1. Scope it with the user

Call the Skill tool with "grilling" to settle, with the user:

- **Area name**: one short kebab-case word (`product`, `game-design`, `systems`). It names the agent (`specialist-<area>`) and the folder.
- **Scope**: what belongs to the area, and where it borders the areas already in the registry, so two specialists never own the same question.
- **Authority**: what the specialist may settle on its own (routine, per `docs/agents/checkpoints.md`) and what it must escalate to the user.
- **Consult when**: the situations in which other skills should ask it (one line, for the registry).

**Done when** all four are agreed and the area doesn't overlap an existing specialist.

### 2. Bootstrap the area's knowledge

Dispatch an exploration subagent to collect what the repo already knows about the area: the spec and tickets, ADRs, `GLOSSARY.md` terms, closed issues and PR discussions, existing docs. It reports facts with their sources; it writes nothing.

### 3. Write the three artifacts

On a branch named `specialist-<area>` (never the default branch):

- `.claude/agents/specialist-<area>.md` from [specialist-agent-template.md](specialist-agent-template.md), with the agreed scope, authority and consult-when filled in.
- `docs/specialists/<area>/README.md` from [area-doc-template.md](area-doc-template.md), filled with what step 2 found. Link to `GLOSSARY.md` terms and ADRs instead of copying them; leave a section empty rather than invent content, and list the gaps under **Open questions**.
- A new row in the registry table in `docs/agents/specialists.md`.

### 4. Open the PR

Commit, push, and open a PR titled `Specialist: <area>` whose body states the scope, the authority line, and the open questions. **The user merges, never you.** Give the user the PR link; the specialist is usable as soon as the PR is merged and a new session starts.
