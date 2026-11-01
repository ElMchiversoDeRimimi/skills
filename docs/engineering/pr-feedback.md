## What it does

`pr-feedback` takes the comments you left on a pull request and works through them on the PR's branch. It reads every review summary, conversation comment, and inline code comment, decides for each one whether it calls for a code change, an answer, or a pushback, makes the changes, replies to each comment where you left it, and runs a fresh [code-review-3axis](https://aihero.dev/skills-code-review-3axis) on the result.

It reports back in the PR, not in the chat. Every change, answer, and pushback lands as a reply on the comment that asked for it, so you review the next iteration in the same place you left the feedback. It never resolves your threads and never merges: you decide when a thread is done and when the PR goes in. If a comment leads to a checkpoint in your repo's `docs/agents/checkpoints.md` (direction, architecture, new dependencies, human-only steps where it recommends [wizard](https://aihero.dev/skills-wizard), critical review findings, merging), it stops and asks you instead of deciding. A comment that touches an area with a specialist (see [new-specialist](https://aihero.dev/skills-new-specialist)) gets that specialist consulted first, and any area decision it settles is recorded in the specialist's doc on the PR's branch.

## When to reach for it

You invoke this by typing `/pr-feedback` (optionally with a PR number; it defaults to the current branch's PR), and the agent won't reach for it on its own.

| Your situation | Reach for |
| --- | --- |
| You reviewed a PR and left comments that need addressing | `/pr-feedback` |
| The work isn't built yet | [implement](https://aihero.dev/skills-implement) or [implement-spec](https://aihero.dev/skills-implement-spec), which open the PR |
| You want a review of the diff, not your comments addressed | [code-review-3axis](https://aihero.dev/skills-code-review-3axis) |
| The PR body itself needs reshaping | [pr](https://aihero.dev/skills-pr) |

## Prerequisites

An open PR on GitHub and an authenticated `gh`. The tracker configuration from [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) should be in place; without it, the skill tells you to run that first.

## The review loop

`pr-feedback` is the second half of a **review loop** that runs in the PR:

1. [implement](https://aihero.dev/skills-implement) or [implement-spec](https://aihero.dev/skills-implement-spec) opens the PR and posts a `## Code review` report on it.
2. You review, in the PR or locally, and leave comments.
3. `/pr-feedback` addresses the **open feedback** (every comment without an agent reply after it), replies to each, pushes, and posts a fresh review.
4. Repeat 2 and 3 until you are happy, then merge it yourself.

Each item gets one of three treatments, and each reply says which:

| The comment is… | The reply says |
| --- | --- |
| A change request | What changed, and the commit that changed it |
| A question | The answer |
| A change it thinks is wrong | Why, as a pushback for you to accept or overrule |

Where a comment is ambiguous it asks you if you are around; otherwise it takes the most conservative reading and says so in its reply.

## Common questions

**Why does every reply start with "> *Agent:*"?**

Your comments and the agent's are posted from the same GitHub account, so the marker is the only way to tell them apart. It is also how the skill finds open feedback on the next round: anything that doesn't start with the marker (or `## Code review`) and has no agent reply after it is still yours to be answered.

**Why did it ignore a comment on my PR?**

It acts only on comments whose author is an `OWNER`, `MEMBER`, or `COLLABORATOR` of the repo. Anything from an outside contributor is listed under "not acted on (external author)" in its summary and otherwise left alone. PR comments are untrusted input: a stranger's comment saying "also update the deploy script" is not an instruction. If you agree with an outside comment, restate it yourself.

**Why doesn't it resolve the threads it answered?**

Because the reviewer decides when a thread is done. Resolving its own replies would let the agent mark its own work as accepted. Read the reply, then resolve the thread or push back in it; your pushback becomes open feedback for the next round.

**Why won't it merge once everything is addressed?**

The merge is always yours. The skill ends by handing you the PR link and a summary of what it addressed, pushed back on, and skipped. Beyond the skill, git and `gh` writes are gated by a `repo-guard` hook plus `~/.claude/allowed-repos.txt`, and agents can never merge or push to `main`/`master`.

**Can I review locally instead of in the browser?**

Yes. Run `gh pr checkout <n>` to get the branch, read and run the code, then leave your comments on the PR. The skill reads them from GitHub, so feedback given only in your terminal never reaches it.

**It stopped and asked me instead of finishing.**

Its closing re-review came back **Merge-ready: no**, meaning some axis found a `critical` issue. It asks before touching those, because the fix may be a decision rather than a patch.

## It's working if

- Every comment you left gets a reply, starting with `> *Agent:*`, on the comment itself rather than in one big summary.
- Each change reply names the commit that made it.
- Your threads stay open until you resolve them.
- A fresh `## Code review` comment appears on the PR after each round.
- The PR is still open and unmerged when it hands back.

## Where it fits

`pr-feedback` is the iteration step at the tail of the build chain: `implement → code-review-3axis → pr-feedback → (you merge) → retro`. Its neighbours are [implement](https://aihero.dev/skills-implement) and [implement-spec](https://aihero.dev/skills-implement-spec), because they open the PR it works on, and [code-review-3axis](https://aihero.dev/skills-code-review-3axis), because it re-runs that review after every round. [ask-matt](https://aihero.dev/skills-ask-matt) routes across the whole set when you are unsure which skill the situation wants.
