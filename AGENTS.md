# AGENTS.md

This repo is a **skill** — a knowledge package AI coding agents consume to scaffold AI/ML projects
on Azure Machine Learning. It is not an ML project itself.

## Maxims

1. **Simplicity and readability first.** Prefer straightforward, obvious solutions. Clever code
   confuses both humans and agents.
1. **The Makefile is the front door.** Users and agents read it first to understand what the project
   can do, so keep target bodies inline and transparent. Extract to a script only when the logic is
   bounded and self-contained but would turn the Makefile into a wall of noise.
1. **High information density.** Skill markdown files land directly in LLM context windows — be
   thorough but crisp and concise. Every sentence should earn its place; trim filler to minimize
   context rot.

## Where to find things

- `azureml-scaffolding/SKILL.md` — **start here.** Principles, project structure, and all the detail
  an agent needs.
- `azureml-scaffolding/assets/` — canonical project files (Makefile, pyproject.toml, `mypkg`
  template package). Copied verbatim by agents, so edit carefully.
- `azureml-scaffolding/references/` — extension patterns (linting, experimentation, pipelines,
  datasets). Added only when needed.
- `azureml-scaffolding/scripts/` — helper scripts used by the skill.
- `CONTRIBUTING.md` — how to test skill changes end-to-end.

## How to validate changes

There is no automated test suite. Test by scaffolding into `tmp/` (gitignored) and verifying. See
`CONTRIBUTING.md` for full steps; the minimum is:

```bash
cd tmp && make sync && make run pkg=<name> && make test
```

Always update files under `azureml-scaffolding/`, never `tmp/`.
