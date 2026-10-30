# Contributing / git conventions

## Commits
Format: `<type>(<scope>): <summary>` (imperative, <=72 chars, no trailing period), then a body explaining why.
- Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `data`
- Scopes: `schema`, `rules`, `gen`, `inject`, `validate`, `export`, `ui`, `docs`, `tooling`
- One logical step per commit, tests and lint passing (`pytest -q`, `ruff check .`, `ruff format --check .`).
- Never commit secrets, `.env*`, `.db` files, or `output/full/`. The repo is public.
- Claude-assisted commits end with the `Co-Authored-By` trailer.

Local setup (once per clone):
```
git config commit.template .gitmessage
git config core.hooksPath .githooks
```

## Branches and PRs
- `main` stays green (CI: ruff + pytest). Small steps may go straight to `main`.
- Larger or risky work (e.g. the UI) uses a branch `<type>/<short-name>`, e.g. `feat/ui`, merged by PR using the PR template.
- Squash-merge PRs so history stays one commit per step.

## Releases
Tag milestones `v0.<n>.0` (e.g. `v0.1.0` = dictionary + generator baseline passing validation).
