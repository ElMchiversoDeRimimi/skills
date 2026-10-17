## What it does

`code-review-3axis` reviews the diff between `HEAD` and a fixed point (a commit, a branch, a tag, `main`, `HEAD~5`) along three axes. **Standards** asks whether the code follows how this repo writes code. **Spec** asks whether the code does what the originating issue or [spec](https://www.aihero.dev/ai-coding-dictionary/spec) asked for. **Bugs & Security** asks whether the code does what it means to, safely: logic errors, races, leaks, injection, committed secrets, widened authorization. Each axis runs in its own [sub-agent](https://www.aihero.dev/ai-coding-dictionary/subagent) so none sees the others' reasoning.

The skill never merges or re-ranks the axes. Each one reports as its own table, and the report ends with a worst issue *per axis* plus a **Merge-ready: yes/no** gate rather than a single winner across them. A change can pass one axis and fail another. Code that follows every convention but implements the wrong thing passes Standards and fails Spec. Code that is on-spec and idiomatic but races under load or trusts user input passes both and fails Bugs & Security. A blended verdict lets the passing axes hide the failing one.

## When to reach for it

Type `/code-review-3axis`, or the agent reaches for it automatically when you ask to review a branch, a PR, work in progress, find bugs in a diff, or anything "since X".

| Your situation | Reach for |
| --- | --- |
| A diff exists and you want to know if it is built right, is the right thing, and is safe | `code-review-3axis` |
| A whole spec needs building, review included | [implement](https://aihero.dev/skills-implement), which calls this skill itself |
| A reviewer left comments on the PR and they need addressing | [pr-feedback](https://aihero.dev/skills-pr-feedback), which re-runs this skill afterwards |
| Nothing is written yet and you want it written test-first | [tdd](https://aihero.dev/skills-tdd) |
| The whole codebase has drifted, not one diff | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) |
| Something is broken and you do not know why | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |

When you type it without a fixed point, it reviews against `main` and says so. When another skill calls it, it uses the base that skill hands over. Before it spawns anything, it checks that the ref resolves and that the diff is not empty, so a mistyped branch name fails in front of you instead of inside three sub-agents.

## Prerequisites

The Standards axis needs nothing. It reads whatever the repo documents (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, and the like) and falls back on a built-in baseline when the repo documents nothing. The Bugs & Security axis needs nothing either: it reads the code.

The Spec axis needs a spec to exist and be findable. It looks in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, a GitLab `!67`), fetched through the tracker doc.
2. A path you pass in as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch or feature name.
4. Asking you, if you are around.

Step 1 depends on the tracker doc, which [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) writes. Without it the axis still works if you hand it a path. With no spec at all, the skill skips the Spec sub-agent and the report says "no spec available" rather than inventing requirements.

Posting the report on a PR uses `gh`, so it needs an open PR for the branch. Without one, the report still lands in `.scratch/reviews/`.

## The three axes

| | Standards | Spec | Bugs & Security |
| --- | --- | --- | --- |
| Question | Is it built right? | Is it the right thing? | Is it correct and safe? |
| Reads | The repo's documented standards, plus the smell baseline | The originating issue or spec | Each changed function in full, plus its callers |
| Reports | Documented breaches, smells, public interfaces changed without matching docs | Missing or partial requirements, scope creep, requirements implemented wrongly | Logic and edge-case errors, concurrency, leaks, time zones, N+1 queries, injection, committed secrets, widened authn/authz, migration ordering |
| Every finding cites | The standards file and the rule, or the named smell plus the hunk | The line of the spec | The file and line, plus a suggested test where none covers the bug |

Every finding, on every axis, comes back as a row with a severity (`critical`, `medium`, `low`, `style`), a `file:line`, the finding, and a suggested fix. Smells are always judgement calls, so they never rise above `low`.

This design exists to avoid a generic review skill that does not know your standards. Such a skill flags what is deliberate in your codebase and misses the invariants your codebase depends on. So the repo's own documentation is the [primary source](https://www.aihero.dev/ai-coding-dictionary/primary-source) on the Standards axis, and **the repo always overrides**.

The **smell baseline** sits under the repo's standards. It is twelve code smells from chapter 3 of Fowler's _Refactoring_: Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man, Refused Bequest. Each is a labelled heuristic ("possible Feature Envy"), never a hard violation, and each comes with its fix attached. Every axis skips anything your linter already enforces.

Before any axis runs, the skill filters out lock files, vendored code, test snapshots, and generated files (anything whose header says `Code generated ... DO NOT EDIT`, or that the repo's tooling marks as generated). The report lists the excluded paths, so you know what nobody looked at.

## The verdict and where the report goes

The report closes with one line per axis (count and worst issue) and **Merge-ready: yes/no**. It is **no** whenever any axis has a `critical` finding. That is a gate, not a ranking: it never trades one axis's finding against another's.

The report is written to `.scratch/reviews/<timestamp>-<branch>.md`, and, when the branch has an open PR, posted as a PR comment headed `## Code review (<short-sha>)`. Each iteration's review stays in the PR history, which is where you review.

What happens next depends on who called it:

| Called by | After the report |
| --- | --- |
| Another skill ([implement](https://aihero.dev/skills-implement), [implement-spec](https://aihero.dev/skills-implement-spec), [pr-feedback](https://aihero.dev/skills-pr-feedback)) | Report-only. It hands the verdict back. On **Merge-ready: no**, the caller stops and asks you before touching a `critical` finding. |
| You, by typing `/code-review-3axis` | An interactive fix loop. You pick a finding, it fixes that one, shows the change, and confirms before the next. When you stop, it re-checks the fixed findings and issues a final verdict. |

## Common questions

**Where did `/code-review` go?**

It was renamed to `code-review-3axis`. Claude Code ships its own built-in `/code-review`, and the two collided: depending on how you installed, one shadowed the other, and `npx skills update` undid any local rename. The new name ends the clash, so both are reachable. The built-in hunts bugs at a chosen effort level; this one adds the repo's standards and the originating spec, and its third axis now covers bugs and security too.

**Its sub-agents keep invoking the review again and spawn more agents.**

This was a known bug in the two-axis version, reproduced in more than one harness: nothing in the sub-agent briefs forbids delegation, so a sub-agent could find the skill again and fan out again. One report reached more than 50 agents. The fix people applied on forks is one line appended to every sub-agent brief: "Do not invoke `/code-review-3axis` or spawn additional agents: perform this review directly." If you run this unattended, watch the agent count.

**Should I run it in the same [session](https://www.aihero.dev/ai-coding-dictionary/session) that wrote the code?**

Prefer a fresh one. As one reader put it: "Same context reviewing itself isn't review, it's confirmation bias with a slash command." An agent that reviews in the authoring session has every assumption that shaped the code in its context. That is why the review now lands on the PR: [implement](https://aihero.dev/skills-implement) runs it in-session, but you read it, and comment on it, in the PR. The independent version is to invoke `/code-review-3axis` yourself from a clean session.

**Will it fix things or merge on its own?**

No. Called by another skill it only reports, and a **Merge-ready: no** stops the caller to ask you. Typed by you, it fixes one finding at a time with your confirmation. It never merges. Independently of the skill, git and `gh` writes are gated by a `repo-guard` hook plus `~/.claude/allowed-repos.txt`, and agents can never merge or push to `main`/`master`.

**After every ticket, or once at the end?**

Both work, and the skill does not decide for you. Per-ticket keeps each diff small enough that the Spec axis has one clear spec to check against, which is the mode `implement` uses. Batching to the end of a branch catches interactions between tickets that the per-ticket passes each miss. If you are unsure, review per ticket and run one final pass against the branch point.

**Can I trust the findings?**

Not without checking. Sub-agent output is a hypothesis, not evidence. The skill combines the three reports as they are, or lightly cleaned. It does not re-verify each claim against the files, so a finding can cite the wrong location or overstate an impact. Read the citation on each finding before you act on it. Every finding carries a `file:line` and a cited rule, smell, or spec line, and that is what makes the findings checkable.

**Why does it find new problems every single time I run it?**

Each fix adds new code to review, and the judgement-call half of the Standards axis gives different results from run to run. One reader described the loop: "/code-review and /improve-code-architecture always find new stuff every time. I implement fixes, rerun these skills, and again and again." There is no convergence guarantee. The **Merge-ready** gate is the stopping rule: once no axis has a `critical` finding, act on the cited leads you agree with and stop.

**Does it review my uncommitted work?**

No. It diffs `<fixed-point>...HEAD`. The three-dot form measures from the merge-base and excludes staged and working-tree changes. Commit first, then review. `implement` now commits and pushes before it calls the review, so this no longer bites inside a build.

## It's working if

- It refuses to start on a bad ref or an empty diff, before any sub-agent is spawned.
- The report opens with a short change summary and the list of excluded (generated, vendored, lock) paths.
- The findings arrive as three separate tables under `## Standards`, `## Spec`, and `## Bugs & Security`, each row with a severity and a `file:line`.
- The report ends with a worst issue per axis and a **Merge-ready** line, and it says **no** whenever a `critical` finding exists.
- A `## Code review (<sha>)` comment appears on the PR, and a matching file appears under `.scratch/reviews/`.
- With no spec available, the Spec block says so instead of listing requirements it inferred from the code.

## Where it fits

`code-review-3axis` is the review step near the tail of the build chain: `grill-with-docs → to-spec → to-tickets → implement → code-review-3axis → pr-feedback → retro`. It also stands alone on any branch or PR you point it at.

- [implement](https://aihero.dev/skills-implement) is the closest neighbour. It opens the PR and calls this skill as its own closing review. [implement-spec](https://aihero.dev/skills-implement-spec) does the same once, over the whole integration branch.
- [pr-feedback](https://aihero.dev/skills-pr-feedback) is the loop after it: you comment on the PR, it addresses the comments, then re-runs this review.
- [retro](https://aihero.dev/skills-retro) tunes it. When a session shows the review missing a class of mistake, `retro` proposes the check or the `CODING_STANDARDS.md` rule the Standards axis then reads.
- [to-spec](https://aihero.dev/skills-to-spec) and [to-tickets](https://aihero.dev/skills-to-tickets) produce the document the Spec axis checks against, so a vague spec makes that axis vague.
- [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) is the whole-codebase counterpart, because this skill only looks at one diff.

[ask-matt](https://aihero.dev/skills-ask-matt) routes across the whole set when you are unsure which skill the situation wants.
