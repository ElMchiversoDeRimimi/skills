## What it does

`new-specialist` creates an **area specialist**: a project [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) that owns what the project knows about one area (product, game design, systems) and that the other skills consult before settling anything in it. The specialist keeps that knowledge in one doc, `docs/specialists/<area>/README.md`, answers questions from a fresh [context window](https://www.aihero.dev/ai-coding-dictionary/context-window), and records area decisions as they land.

Only you can create one. The [agent](https://www.aihero.dev/ai-coding-dictionary/agent) never makes a specialist on its own initiative: when an area keeps coming up with nobody owning it, the agent stops and recommends `/new-specialist <area>`, and you decide whether the area deserves one. Even then, the specialist arrives as a pull request you review and merge.

## When to reach for it

You invoke this by typing `/new-specialist <area>`, and the agent won't reach for it on its own.

| Your situation | What to do |
| --- | --- |
| The same area's questions keep landing on you, session after session | `/new-specialist <area>` |
| An agent ended a round or a run by recommending `/new-specialist <area>` | Run it if you agree the area is real and stable |
| A one-off question in an unfamiliar area | Ask it directly, or use [research](https://aihero.dev/skills-research) for facts outside the repo |
| Project-wide vocabulary or a hard-to-reverse decision | [grill-with-docs](https://aihero.dev/skills-grill-with-docs): that belongs in `GLOSSARY.md` and ADRs, which every specialist reads |

## Prerequisites

Run [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) first. It writes the registry, `docs/agents/specialists.md`, and without it the skill stops. Each run then adds three things to the repo on a `specialist-<area>` branch:

| It writes | Where |
| --- | --- |
| The specialist agent | `.claude/agents/specialist-<area>.md` |
| The area doc, the specialist's memory | `docs/specialists/<area>/README.md` |
| A row naming the area, its scope, and when to consult it | the registry in `docs/agents/specialists.md` |

## Scope, authority, and the brief

Before it writes anything, a short [grilling](https://aihero.dev/skills-grilling) round settles four things with you: the **area** name, its **scope** (and where it borders the specialists you already have, so no two own the same question), its **authority** (what it may settle alone and what it must hand back to you), and **when to consult** it. An exploration subagent then bootstraps the area doc from what the repo already holds: the spec and tickets, ADRs, glossary terms, closed issues and PR discussions. Gaps go under **Open questions** rather than being invented. The product area is the worked example in the doc's seed (users and problems, value proposition, priorities, success metrics); other areas swap those middle sections for their own.

When a skill consults the specialist, what comes back is a short **brief**:

- an answer or recommendation, in the glossary's vocabulary
- its confidence, and why
- the sources it relied on
- what needs you: any part that is a direction decision rather than a fact

## Common questions

**How is a specialist different from a skill?**
A skill is a procedure: it says how to do something, and it is the same in every repo. A specialist is knowledge: it holds what this project has decided about one area, and it exists only in this repo. Skills consult specialists; specialists never run skills.

**Why can't agents create specialists themselves?**
Because a specialist shapes every later answer in its area. Drawing its scope and its authority line is a direction decision, so it sits behind a checkpoint like any other. An agent that sees an unowned area recurring recommends `/new-specialist <area>` and stops there.

**Does it load the whole project context?**
No, and that is the point. It starts fresh on every consultation and reads its own doc, `GLOSSARY.md`, and the ADRs that touch its area. The skill consulting it stays small too, because it gets a brief back instead of loading the area itself.

**Can it make decisions?**
Only the routine ones inside the authority line you agreed when you created it. Everything else comes back under "needs the user", and direction stays with you. When a decision lands, the specialist records it in its doc on the current branch, so it ships in the same PR and you review it there.

**Why no shell or web access?**
Its tools are Read, Grep, Glob, Edit and Write, and its edits are confined to its own folder. A specialist answers from the repo and keeps a doc. Running commands or browsing would widen what a consultation can touch for no gain; facts from outside the repo are a job for [research](https://aihero.dev/skills-research).

**How do I change or retire one?**
Edit or delete its three pieces (the agent file, the area doc, and its registry row) in a pull request, like any other change. There is no separate command for it.

**How does it show up in a grilling session?**
When a question in a round needs a fact from a listed area, the agent asks the specialist instead of a generic subagent, and its recommendation appears as the `➡️` answer tagged `(specialist: <area>)`. You still answer the question. Once you do, the specialist records the decision.

## It's working if

- The PR titled `Specialist: <area>` shows a scope, an authority line, and open questions you recognise, and nothing in the area doc you never said or the repo never held.
- Grilling rounds start carrying `➡️` answers tagged `(specialist: <area>)`, and you stop being asked area facts the repo already answers.
- PRs in that area include small edits to `docs/specialists/<area>/README.md` recording what was decided.
- Questions outside the area come back pointed at the right specialist or person, not answered anyway.

## Where it fits

`new-specialist` is a **run-once-per-area setup**, sitting beside [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills), which creates the registry it fills. Its readers are the skills that consult specialists: [grilling](https://aihero.dev/skills-grilling), which surfaces their recommendations in rounds and recommends this skill when an area keeps recurring, and the planning and build skills ([to-spec](https://aihero.dev/skills-to-spec), [to-tickets](https://aihero.dev/skills-to-tickets), [wayfinder](https://aihero.dev/skills-wayfinder), [implement-spec](https://aihero.dev/skills-implement-spec), [pr-feedback](https://aihero.dev/skills-pr-feedback)). For the whole map, see [ask-matt](https://aihero.dev/skills-ask-matt).
