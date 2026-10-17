## What it does

`implement` builds work that has already been decided. You point it at a [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket), a [spec](https://www.aihero.dev/ai-coding-dictionary/spec), or the plan you just agreed in the conversation, and it writes the code, drives [tdd](https://aihero.dev/skills-tdd) at the seams, typechecks as it goes, pushes the work to a branch with a pull request, and posts a [code-review-3axis](https://aihero.dev/skills-code-review-3axis) report on that PR.

It never reopens the plan. There is no interview, no clarifying round, no proposal of a different approach. Whatever was settled upstream is the input, and the skill's whole job is to turn that into a PR you can review. It never merges: you do. That is what separates it from typing "build this" at a fresh [agent](https://www.aihero.dev/ai-coding-dictionary/agent), which often redesigns the work while it builds it. It also stops and asks you at every checkpoint in your repo's `docs/agents/checkpoints.md` (direction, architecture, new dependencies, human-only steps where it recommends [wizard](https://aihero.dev/skills-wizard), critical review findings, merging).

## When to reach for it

You invoke this by typing `/implement` yourself, and the agent won't reach for it on its own. It ships with `disable-model-invocation: true`, so no other skill can call it either. Wherever [ask-matt](https://aihero.dev/skills-ask-matt) or [to-tickets](https://aihero.dev/skills-to-tickets) says "then `/implement` per ticket", that is an instruction to you, not something the agent will do unprompted.

Where the work currently lives decides whether this is the right skill:

| The work is… | Reach for |
| --- | --- |
| A ticket on the tracker | `/implement #42`, one ticket per [session](https://www.aihero.dev/ai-coding-dictionary/session), [clearing](https://www.aihero.dev/ai-coding-dictionary/clearing) context between tickets |
| A spec, not yet split up, and the build spans sessions | [to-tickets](https://aihero.dev/skills-to-tickets) first, then `/implement` per ticket |
| A spec, and the build is small | `/implement` directly against the spec |
| Only in the conversation you just had, and it's still small | `/implement` right there, in the same window |
| Not written down anywhere yet | [grill-with-docs](https://aihero.dev/skills-grill-with-docs), or [grill-me](https://aihero.dev/skills-grill-me) if there's no codebase |
| One concrete behaviour you want test-first, with no spec | [tdd](https://aihero.dev/skills-tdd) directly |
| Already built, and you want it checked | [code-review-3axis](https://aihero.dev/skills-code-review-3axis) directly |
| Already on a PR, and you left review comments | [pr-feedback](https://aihero.dev/skills-pr-feedback) |

The same-session case is worth naming because the skill's own first line doesn't cover it. `SKILL.md` says "the spec or tickets", which pushes the [model](https://www.aihero.dev/ai-coding-dictionary/model) to look for a file that doesn't exist. If the plan lives only in the thread, say so when you invoke it.

## Prerequisites

`implement` never works on the default branch. If you are on `main` or `master`, it first creates `<ticket-number>-<slug>` (or `<slug>` with no ticket); otherwise it uses the branch you are on. Opening the PR needs `gh` and a remote. With a local markdown tracker there is no PR: it names the branch for you to review locally.

If the tickets came from [to-tickets](https://aihero.dev/skills-to-tickets), [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) configured the tracker they live on. `code-review-3axis` reads the same configuration to find the originating spec at close-out.

## What one run does

A run has seven steps, in order:

1. Read the ticket or spec and work out the seams.
2. Make sure it is on a branch, never the default one.
3. Drive [tdd](https://aihero.dev/skills-tdd) at the pre-agreed seams, one red-green slice at a time.
4. Typecheck often, run single test files as it goes.
5. Run the full test suite once, at the end.
6. Commit, push, and open a PR (or push to the branch's existing one) that says what changed, how it was verified, and `Closes #<n>`.
7. Run [code-review-3axis](https://aihero.dev/skills-code-review-3axis), which posts its report on the PR. Fix the `medium` and `low` findings and push. On **Merge-ready: no**, stop and ask you before touching the `critical` findings.

The run ends by handing you the PR link. You review it in the PR (or locally with `gh pr checkout <n>`), then merge it or leave comments for [pr-feedback](https://aihero.dev/skills-pr-feedback).

One run covers one ticket. The tickets [to-tickets](https://aihero.dev/skills-to-tickets) produces are tracer-bullet vertical slices sized to fit a single fresh [context window](https://www.aihero.dev/ai-coding-dictionary/context-window), so the intended rhythm is: clear context, implement one ticket, review its PR, clear again. Each ticket is self-contained, so you can discard the previous ticket's context.

## Pre-agreed seams

The skill's central idea is the **seam**, the public boundary you observe behaviour at without reaching inside. Tests live at seams. When the seam is agreed before any code exists, the tests last, and you can rewrite the implementation underneath without changing them.

The "pre-agreed" part matters, and it is also the skill's weakest point. Nothing inside `implement` agrees the seams. `tdd` is the skill that asks, and it refuses to write a test at an unconfirmed seam. So in practice the agreement happens either upstream in the spec, or in the first exchange of the run. If it happens nowhere, the run becomes "just write the code" and nothing warns you. Naming the seams in the spec is what stops that.

## Common questions

**It finished, but my ticket is still open and the acceptance criteria are still unchecked.**

Correct, and expected until you merge. `implement` never closes the ticket by hand. The PR body carries `Closes #<n>`, so the ticket closes when you merge the PR. It does not tick the `- [ ]` boxes on the originating issue either; reconcile those yourself. On a local markdown tracker there is no PR, so close the ticket yourself once you have reviewed the branch. This matters most on a dependency chain, because `to-tickets` defines the frontier as tickets whose blockers are all closed. Until you merge, nothing becomes visibly unblocked.

**Can I point it at all my tickets at once, or run several in parallel?**

Not with `/implement`: one invocation, one ticket. For a whole spec in one run, use [implement-spec](https://aihero.dev/skills-implement-spec), which gives each ticket on the ready frontier to a [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) in its own worktree, then merges the results onto one integration branch. Running several `/implement` sessions side by side in one checkout is worse than unsupported. One field report describes a `git commit --amend` in one session landing on another session's commit, a stash vanishing from `refs/stash`, and commits landing on the wrong branch, all in a single afternoon across three issues. The sessions share one working directory, one index, and one HEAD. Users work around this with git worktrees, but `refs/stash` is shared across worktrees too, so worktrees alone do not fix the stash case.

**Will it merge the PR, or push to `main`?**

No. Every run ends on a branch with a PR, and the merge is yours. People found the old behaviour (committing straight to the current branch) too eager, because the code landed before they could verify it. Now the PR is the checkpoint: you review it there or locally with `gh pr checkout <n>`, and leave comments for [pr-feedback](https://aihero.dev/skills-pr-feedback) to address. This is enforced outside the skill too: git and `gh` writes are gated by a `repo-guard` hook plus `~/.claude/allowed-repos.txt`, and agents can never merge or push to `main`/`master`. [pr](https://aihero.dev/skills-pr) is there if you want the PR body reshaped.

**Why did it stop and ask me in the middle of the run?**

The review came back **Merge-ready: no**, which means some axis found a `critical` issue. `implement` fixes `medium` and `low` findings on its own, but a `critical` one is a checkpoint: it asks you before touching it, because the fix may mean revisiting the plan rather than patching the code.

**Is the review biased, since the same session wrote the code?**

Somewhat, because an agent reviewing the code it just wrote leans toward its own solution. That is why the report is posted on the PR, where you read it with fresh eyes, and why [code-review-3axis](https://aihero.dev/skills-code-review-3axis) runs its three axes in separate sub-agents. Running it yourself in a fresh session against a fixed point is a valid extra check. The old complaint that the review could not see uncommitted changes no longer applies: `implement` commits and pushes before it reviews.

**One ticket burned 150k tokens. Am I using it wrong?**

Probably not. The ticket is more likely too big. A run does codebase exploration, a red-green loop per seam, a full suite, and a review, so a non-trivial ticket exceeding 100k [tokens](https://www.aihero.dev/ai-coding-dictionary/token) is normal rather than a sign something broke. The fix is upstream. Right-size the tickets in [to-tickets](https://aihero.dev/skills-to-tickets) so each fits one fresh window. If a single ticket keeps going over, split it rather than raising the [effort](https://www.aihero.dev/ai-coding-dictionary/effort) level.

**`/implement #2` in a fresh session worked on something completely unrelated.**

The agent resolved `#2` against another numbered list in context, such as a todo file or checklist, rather than the configured tracker. `implement` now fetches a passed reference from the issue tracker and states its title before starting, and asks when the reference is ambiguous. Check that title matches the ticket you meant; passing the issue URL or `owner/repo#2` removes the ambiguity entirely.

## It's working if

- The session opens by reading the ticket or spec and restating what it will build, rather than asking you what to build.
- You can see an actual `tdd` Skill tool call in the trace, not just tests appearing in the diff.
- Typechecks and single test files run repeatedly during the run, and the full suite runs once near the end.
- The run reaches an open PR, with a `## Code review` comment on it, without you prompting it to carry on.
- It stops and asks you whenever that comment says **Merge-ready: no**.
- Nothing lands on `main` until you merge.
- The diff is one ticket's worth of change: a vertical slice through every layer, not several tickets swept together.

## Where it fits

`implement` is the build step of the main chain:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review-3axis → pr-feedback → retro
```

Its neighbours are [to-tickets](https://aihero.dev/skills-to-tickets), which produces the tickets it consumes and declares the blocking edges that decide their order; [tdd](https://aihero.dev/skills-tdd), which it drives internally at each seam; [code-review-3axis](https://aihero.dev/skills-code-review-3axis), which it runs on the PR; and [pr-feedback](https://aihero.dev/skills-pr-feedback), which takes over once you comment on that PR. It sits downstream of the planning skills and trusts them. It does not re-validate the shape of what it was handed, so a badly-structured map or a horizontally-layered ticket gets built as written.

That trust is why [wayfinder](https://aihero.dev/skills-wayfinder) merges onto the chain at [to-spec](https://aihero.dev/skills-to-spec) rather than looping its map straight into `implement`. Go straight to `implement` from a map only when the effort turned out small.

[ask-matt](https://aihero.dev/skills-ask-matt) is the router over the whole set when you are not sure which flow you are in.
