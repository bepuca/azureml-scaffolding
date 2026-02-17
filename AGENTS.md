# AGENTS.md

This repo is a **skill** — a knowledge package AI coding agents consume to
scaffold AI/ML projects on Azure Machine Learning. It is not an ML project
itself.

## Where to find things

- `azureml-scaffolding/SKILL.md` — **start here.** Principles, project
  structure, and all the detail an agent needs.
- `azureml-scaffolding/assets/` — canonical project files (Makefile,
  pyproject.toml, `mypkg` template package). Copied verbatim by agents, so edit
  carefully.
- `azureml-scaffolding/references/` — extension patterns (linting,
  experimentation, pipelines, data). Added only when needed.
- `azureml-scaffolding/scripts/` — helper scripts used by the skill.
- `CONTRIBUTING.md` — how to test skill changes end-to-end.

## How to validate changes

There is no automated test suite. Test by scaffolding into `tmp/` (gitignored)
and verifying. See `CONTRIBUTING.md` for full steps; the minimum is:

```bash
cd tmp && make sync && make run pkg=<name> && make test
```

Always update files under `azureml-scaffolding/`, never `tmp/`.
