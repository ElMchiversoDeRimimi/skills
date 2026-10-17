# CI seed: GitHub Actions

A minimal workflow that runs the repo's own checks on every PR, so the reviewer sees a pass/fail on the PR that doesn't depend on what an agent reports. Write it to `.github/workflows/checks.yml`, filling the commands from the repo's real scripts (`package.json`, `Makefile`, `pyproject.toml`, `go.mod`, ...).

```yaml
name: checks

on:
  pull_request:
  push:
    branches: [main]

# Read-only token: the checks never write to the repo.
permissions:
  contents: read

jobs:
  checks:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      # Toolchain setup for this repo, e.g. actions/setup-node@v4 with node-version
      - run: <install command>
      - run: <typecheck or lint command>
      - run: <test command>
```

Rules:

- Trigger on `pull_request`, never `pull_request_target`: the latter runs untrusted PR code with write access and secrets.
- No secrets in this workflow. If a check genuinely needs one, stop and ask the user (it is a checkpoint).
- Keep `permissions: contents: read`.
- Use the repo's existing commands; don't invent a test runner. If the repo has no code yet, write no workflow: record "CI: none yet" and let `/to-tickets` make adding it the first ticket.
