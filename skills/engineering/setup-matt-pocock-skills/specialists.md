# Specialists

The area specialists of this project. Each is a project subagent (`.claude/agents/specialist-<area>.md`) that owns its area's knowledge in `docs/specialists/<area>/README.md`. They are created with `/new-specialist <area>`, never by an agent on its own.

| Area | Agent | Scope | Consult when |
| ---- | ----- | ----- | ------------ |

## How to use them

- **Before settling anything in a listed area**, consult its specialist: dispatch its agent with the question and context pointers (spec, ticket, PR), and pass its brief on. Its recommendation is input; direction decisions stay with the user.
- **When a decision in a listed area lands**, ask the specialist to record it in its doc, on the current branch, so it ships in the same PR.
- **An area keeps coming up and has no specialist?** Recommend `/new-specialist <area>` to the user (a checkpoint); don't create one.
