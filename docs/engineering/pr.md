## What it does

`pr` defines the shape of a pull request body: a **Summary** that shows the change, **Evidence** that it works, and a **Merge Danger** call on how risky it is to land. It is a format reference, not a workflow. It does not push a branch, open the PR, or decide what goes into it. It tells the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) what the body should look like when it writes one.

The summary is a visual, not a paragraph. A default PR body describes the diff in prose. This one picks the **smallest view** that makes the key point clear (pseudocode, a call tree, a component tree, a file tree, a Mermaid diagram, or a shaped diff) and keeps the words around it brief. The reviewer already has the diff open, so the body shows them its shape before they read it.

## When to reach for it

You invoke this by typing `/pr`, and the agent won't reach for it on its own. In this fork it is user-invoked: type it when you want a PR body shaped, including the one `implement` wrote.

| Your situation | Reach for |
| --- | --- |
| A branch is ready and needs a body a reviewer can scan | `pr` |
| The code is written but nobody has reviewed it yet | [code-review-3axis](https://aihero.dev/skills-code-review-3axis) first, then `pr` |
| The PR is open and review comments are coming back | [pr-feedback](https://aihero.dev/skills-pr-feedback); `pr` only writes the body |

## The template

Three sections, in this order:

- **Summary**: one or more small visuals, each placed next to the short text it supports. Use one, sometimes several, rarely all of them. Keep only the calls, files, props, and boundaries the reviewer needs.
- **Evidence**: a before and after. A screenshot is the strongest evidence when the change is visual and the [environment](https://www.aihero.dev/ai-coding-dictionary/environment) can take one. Otherwise, use the exact test that failed and now passes, written as pseudocode, or the console output that changed.
- **Merge Danger**: whether the change is a **one-way door** or a **two-way door**, and its **blast radius**. A two-way door is cheap to reverse; a one-way door (a destructive migration, a public API removal, a hard-to-reverse decision) is not. Blast radius names what could break if the change is wrong: layout shift, consumers of an API, mobile responsiveness.

The door call is the leading idea. It changes "is this safe to merge?" from a gut feeling into a stated claim the reviewer can disagree with. It also tells them where to spend their [human review](https://www.aihero.dev/ai-coding-dictionary/human-review). Skim a two-way door with a small blast radius, and read a one-way door slowly.

## Common questions

**Can I trust the agent's own door call?**

Not blindly, and that is the point of stating it. The agent that wrote the change is the one grading it, so be most suspicious when it says "two-way, small blast radius". The diff also often hides whether a change can be reversed. As one user put it, "rolling back a commit won't unsend a batch of emails", and a flagged rollout stays two-way only until the first write lands in the new format. The skill gives the agent a definition (destructive actions and hard-to-reverse decisions are one-way), not a checklist, so check the Merge Danger line most carefully. Two things help: make sure the agent has the [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) or [spec](https://www.aihero.dev/ai-coding-dictionary/spec) in front of it, not just the diff, and write down the changes your repo always treats as one-way (schema migrations, anything that ships outward or deletes) where the agent will read them before it makes the call.

**Does it open the PR for me?**

No. `pr` covers only the body. Opening the PR is [implement](https://aihero.dev/skills-implement)'s job, and [implement-spec](https://aihero.dev/skills-implement-spec)'s: both push a branch and open a PR (what changed, how it was verified, `Closes #<n>`), and neither ever merges. Because `pr` is user-invoked, those bodies don't take this shape unless you type `/pr` to reshape one. Merging stays with you regardless: git and `gh` writes are gated outside the skills by a `repo-guard` hook plus `~/.claude/allowed-repos.txt`, and agents can never merge or push to `main`/`master`.

**Won't it just produce another wall of text and diagrams?**

The skill is designed to prevent that, but it can still happen. Users' complaint about agent PR bodies is consistent: "a long summary but all I need to know is what changed, how it was verified, what could break, and whether it's safe to merge." The skill tells the agent to skip preambles, keep prose brief, and pick the smallest view, usually one visual and rarely all of them. If you still get a stack of diagrams, the agent has ignored that. If the body is huge because the diff is huge, the problem is the size of the PR, and `pr` will not split it for you.

**My repo already has a PR template. Which one wins?**

Neither, by default. `pr` has its own template and does not look for `.github/pull_request_template.md` or anything like it. Several users asked for the skill to use the repo's template. If you do nothing, the agent has two competing instructions for the same document. Settle it in your repo's agent docs, for example by filling the repo template and putting Summary, Evidence and Merge Danger under it.

**Is the output HTML? Why doesn't the Mermaid diagram render?**

The output is a markdown PR body, not an HTML page. GitHub and GitLab render Mermaid blocks in a PR description, but a terminal does not, so the diagram looks like raw text while the agent is still showing it to you locally. Users on CLI harnesses have worked around that with an ASCII Mermaid renderer or by having the agent attach an HTML version to the PR. Mermaid is one of six views. A call tree, file tree or shaped diff reads the same everywhere.

**Can it sort through the review comments that come back?**

No. It writes the body and stops. [pr-feedback](https://aihero.dev/skills-pr-feedback) is the skill for that: it reads your comments on the PR, addresses them on the branch, and replies to each. It acts only on comments from the repo's owners, members, and collaborators, so it is not a triage tool for comments from outside contributors or review bots.

**Does it keep the body up to date as the PR changes?**

No. It writes the body at one point in time, and a PR that changes under review leaves that body stale. Type `/pr` again after a large change to rewrite it in the same shape.

**My change has no UI. What goes in Evidence?**

Everything except the screenshot. The screenshot is the strongest evidence only when the change is visual. For a migration, a background job or a refactor, the evidence is the exact test that failed before and passes now, or the console output that changed. "Tests are green" on its own is a claim, not a before and after.

**Can it mark the body as written by an LLM?**

Not by itself. One user's approach is a standing instruction in the repo's agent docs that every issue, comment, and PR the agent writes ends with a disclosure line. That rule belongs in the repo, where it covers everything the agent posts, rather than in a template for one kind of document.

## It's working if

- You can tell what the PR changes from the Summary visual alone, before opening the diff.
- The body has no preamble: it starts at the Summary heading.
- The Evidence section shows a before and an after, not a claim that tests pass.
- Every PR states a door and a blast radius, and the one-way doors are the ones you slow down on.

## Where it fits

`pr` comes between review and retro when the build ships as a pull request: `to-spec → to-tickets → implement → code-review-3axis → pr → retro`. It is user-invoked, so it runs only when you type it, inside that chain or outside it.

- [code-review-3axis](https://aihero.dev/skills-code-review-3axis) runs before it, because a PR body should describe a diff that has already been reviewed.
- [implement](https://aihero.dev/skills-implement) opens the PR and produces the commits the body describes.
- [pr-feedback](https://aihero.dev/skills-pr-feedback) takes over once review comments arrive.

[ask-matt](https://aihero.dev/skills-ask-matt) routes across the whole set when you are unsure which skill the situation wants.
