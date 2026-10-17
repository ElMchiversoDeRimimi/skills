## What it does

`wizard` generates an interactive bash script that walks a human, step by step, through a manual procedure: wiring up third-party services, running a one-off migration, moving a project from state A to state B. It opens each URL, says what to click and copy, captures what comes back, and writes it into `.env` files and GitHub Actions secrets.

The [agent](https://www.aihero.dev/ai-coding-dictionary/agent) writes the script; it never runs it. You do, on your own machine. A wizard is a program, not a list of instructions. The script runs each step in order and keeps the values you enter. Your part is to click, paste, and press Enter.

## When to reach for it

You invoke this by typing `/wizard`, and the agent won't reach for it on its own. It handles secrets, so in this fork a human decides when one gets written. When you hit a step only you can take (a key the agent can't mint, a dashboard it can't click), ask for a wizard instead of letting the instructions land in the chat, where they scroll away.

Reach for it when the next thing blocking you is a trip through a dashboard:

| Situation | What the wizard does |
| --- | --- |
| A new dev needs six services configured before the app boots | Opens each dashboard in order, captures the keys, writes them to `.env` and CI |
| A one-off migration needs switches flipped in a specific order | Sequences the irreversible steps behind confirmation gates |
| A project has to move from state A to state B once | Walks the transition and reports what it could not do |
| You are about to write those steps into a README | Writes an executable version instead, which fails visibly when a step goes stale |

Don't reach for it to *decide* what to build; for that, [grill-with-docs](https://aihero.dev/skills-grill-with-docs) and [to-spec](https://aihero.dev/skills-to-spec) are the tools.

## Prerequisites

None to generate one. The wizard it writes runs on bash, and uses `gh` when a stage sets a GitHub secret or variable. If `gh` is missing or not authenticated, the run does not fail. That stage shows a warning, and the closing summary tells you what to set by hand.

The env file it writes must be gitignored. The skill checks with `git check-ignore` before any `.env` write and stops to tell you if it isn't, so captured secrets can't be committed by accident.

## Stages

A **stage** is one focused task on one screen. The script clears the terminal between stages, so a stage that overflows the screen loses the part that scrolled away. You author stages in dependency order and set `TOTAL_STAGES`, which drives the progress display.

The [skill](https://www.aihero.dev/ai-coding-dictionary/skill) scopes the procedure before it writes any script. It reads the repo instead of asking cold: `.env*`, `docker-compose*`, framework config, and every `secrets.*` / `vars.*` reference in `.github/workflows/`. Each of those references is a value the wizard has to produce. It then shows you the ordered stage list to confirm. Only after you confirm does it map each stage to the exact path a human follows ("Dashboard → Developers → API keys → Reveal test key → copy"). Where it doesn't know the current UI, it asks you or checks the docs rather than inventing clicks.

For each captured value, scoping decides where it goes:

| Destination | When |
| --- | --- |
| `.env` only | Local dev needs it, CI doesn't |
| GitHub secret | CI reads it, and it's sensitive |
| GitHub variable | CI reads it, and it's public |
| Both `.env` and a secret | Local dev and CI both need it |
| Nowhere | The stage is a pure action: a switch flipped, a plan upgraded |

## The template already solves the UX

The [template](https://github.com/mattpocock/skills/blob/main/skills/engineering/wizard/template.sh) ships the whole experience: progress with time remaining, confirmation gates, cross-platform URL opening including WSL, hidden entry for secrets, idempotent `.env` upserts, `gh secret` / `gh variable` writes, and a closing summary of everything it had to skip. Everything above the `STAGES` marker is a fixed library, identical in every wizard and never hand-edited. Because the library never changes, every wizard behaves the same way. The only work per wizard is to scope the procedure and author its stages.

The agent that writes a wizard never runs it end to end, because the script opens browsers and waits for human input. The agent checks it statically instead: `bash -n`, `shellcheck` where available, and a trace that every value lands where scoping said it would, with every `set_secret` name matching a real `secrets.*` reference in CI. So the first run is yours, and that run is the test.

Before the first GitHub secret or variable is set, the wizard adds a confirmation stage that shows the target repo (`owner/name`), so you see where the secrets land before they go there.

## Ephemeral by default

| What you have | What to do with the script |
| --- | --- |
| A one-off migration, a personal setup, a transition you'll never repeat | Save it to a scratch or `scripts/` path, run it, delete it |
| A setup path the next person on the repo will also need | Commit it and link it from the README, so they run the script instead of re-asking an agent |

## Common questions

**Do my API keys end up in the model's context?**

No. The agent writes a script; it doesn't run it. You run the script yourself, and it captures the key with hidden terminal entry and writes it straight to `.env` or `gh secret`. The wizard is a CLI, and the model is not connected to it. This holds only for values the wizard captures at runtime. If you paste a key into the chat while scoping the procedure, it's in the [context](https://www.aihero.dev/ai-coding-dictionary/context) like any other pasted text.

**Can I go back and fix a value I mistyped?**

Not mid-run. There is no back button. The stages run forward, and a wrong answer on stage 3 means Ctrl-C and re-run. Re-running is cheap, because any value already written to `.env` is offered back as a default, so you press Enter through the stages you got right and retype only the wrong one. Users asked for this in launch week, and it is still open: "loved it! One thing though, is there a way to go back and correct what you've entered?"

**Does it know what I've already set up?**

Partly, and less than the launch reactions assumed. It reads the repo before it asks (your `.env` files, `docker-compose`, framework config, the `secrets.*` references in CI), so it scopes to values that are missing rather than starting from zero the way a README does. What it doesn't do is check the third-party service. If a key exists in your `.env` the wizard offers it back and Enter keeps it; if you already created the Stripe account but never saved the key, the wizard still sends you to the dashboard for it.

**Where does it sit in the workflow, after grilling and the spec?**

Nowhere in particular. It's a standalone, not a chain step. The common guess is `/grill-with-docs → /to-spec → /wizard`, and that sequence is fine, but the trigger is a manual procedure showing up, which can happen at any point: before you start, mid-build, or long after ship. It also works as a discovery tool. Scoping finds the hidden prerequisites of a task, like the three API keys you hadn't thought about, before you commit to the work.

**Does it work outside Claude Code?**

The script does. It's plain bash, and it runs the same whatever [harness](https://www.aihero.dev/ai-coding-dictionary/harness) generated it. Type `/wizard` in Claude Code or `$wizard` in Codex. Because the skill is user-invoked, it is exposed to [#693](https://github.com/mattpocock/skills/issues/693), where Claude's desktop and web apps drop *user-invoked* skills from the [model](https://www.aihero.dev/ai-coding-dictionary/model)'s listing and report them as not installed; use the CLI if you hit that.

**Why won't the agent reach for it on its own any more?**

Upstream it is model-invoked, so an agent that hits a credentials wall writes a wizard unprompted. This fork makes it user-invoked, because a wizard writes `.env` files and sets GitHub secrets, and that should happen only when a human asks. The cost is the old failure mode: an agent that hits the wall may dump numbered steps into the chat. When it does, type `/wizard`. Separately, git and `gh` writes are gated outside the skill by a `repo-guard` hook plus `~/.claude/allowed-repos.txt`, and agents can never merge or push to `main`/`master`.

**It used to be in `in-progress/`. Where is it now?**

`engineering/`, as of v1.2. It graduated out of the beta bucket and now ships in the plugin, so it arrives with the rest of the promoted set rather than needing an individual install. Its behaviour didn't change on graduation.

## It's working if

- You're shown an ordered list of stages, and the values each one produces, and asked to confirm, before any script exists.
- Every URL is opened before the value from that page is asked for. You're never asked to paste something you haven't been sent to fetch.
- Secrets are typed blind. Nothing sensitive echoes into your scrollback.
- Before any secret is set, a stage names the target repo and asks you to confirm it.
- Each stage fits one screen. Nothing you still need has scrolled away.
- Ctrl-C and re-run picks up where you left off, offering the values already saved as defaults.
- The final screen lists what it wrote, and separately lists what it couldn't do and you have to finish by hand.

## Where it fits

`wizard` is a reach-for-it-anytime standalone, sitting at the line where automation stops and a human has to click. Its nearest neighbour is [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills), because both exist to get a repo into a working state. That one configures this skill set, and `wizard` generates a setup path for everything else. It also pairs with [implement](https://aihero.dev/skills-implement): when a build lands a feature that needs credentials or a manual cutover, a wizard covers the steps only a human can do. When you're unsure which skill fits the moment, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
