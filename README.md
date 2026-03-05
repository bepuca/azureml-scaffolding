# AzureML Scaffolding

A battle-tested structure for AI/ML projects on [Azure Machine Learning][aml]. Scaffold a new
project, organize experiments as proper Python packages, run them locally and on AzureML with the
same command, and scale from a single experiment to multi-step pipelines — all reproducible from day
one without compromising the path to production.

It ensures what runs on your laptop runs in the cloud with no surprises: same dependencies ([uv]
lockfile), same environment (one [Dockerfile] that serves as both [devcontainer] and cloud runner),
same entry point (`make run` → `make aml`). Code, specs, and orchestration are cleanly separated so
you can experiment fast without sacrificing the path to production.

This scaffolding is packaged as a **skill** — a body of knowledge an AI coding agent uses to set up
and evolve your project. You start with a barebones, working base and add patterns (pipelines, data
workflows, experiment tracking, linting) as you need them. The agent understands the principles and
tradeoffs, so it can also answer questions, debate design choices, or explain why things are the way
they are — without changing anything.

## Quickstart

Download the `azureml-scaffolding/` folder into your repo (wherever your agent reads skills from).
The agent will discover it automatically — no extra configuration needed.

```bash
curl -sL https://github.com/bepuca/azureml-scaffolding/archive/refs/heads/main.tar.gz \
  | tar xz --strip-components=1 -C /path/to/your/skills/ "azureml-scaffolding-main/azureml-scaffolding"
```

Then ask your agent:

> Adapt this project to the scaffolding structure

It picks up `SKILL.md` and takes it from there.

## Do I need this?

If you need fully traceable, reproducible experiments — and if you're building an AI product,
[you almost certainly do][hdd-for-ai] — this project is one way to get there, and the one thing the
whole structure is designed around.

Even if you don't train a model, you evaluate. If you evaluate, you try different things. If you try
things, you need to know exactly what you tried and what metrics you got. That's experimentation —
and [Azure Machine Learning][aml] is a great platform for it. This skill gives you a project
structure that makes that workflow seamless from day one.

Everything else — proper packaging, a Makefile as single entry point, a devcontainer that doubles as
cloud runner — exists to support that process. And when you go to production, nothing breaks: the
same experiment tracking that recorded your offline metrics can link to live deployments, so you can
correlate online performance with the experiments that produced each model.

## What's in here

```
azureml-scaffolding/
├── SKILL.md                 ← entry point for agents: principles, structure, decision tree
├── assets/                  ← reference files (Makefile, pyproject.toml, example package)
├── references/              ← extension patterns (pipelines, data, experimentation, linting)
└── scripts/                 ← helper scripts used by the skill
```

The `azureml-scaffolding/` folder is the skill — self-contained and designed to be dropped into any
project.

## What the agent will build

When given the skill, an agent will set up:

- A **[uv workspace][uv-workspace]** with proper Python packaging (units of work as packages,
  [`pyproject.toml`][pyproject-toml] per package, committed `uv.lock`)
- A **Makefile** as the single entry point (~60 lines, self-documenting via `make help`)
- A **[devcontainer]** that doubles as the AzureML cloud runner (one [Dockerfile], Python deps
  installed at runtime by uv)
- **[AzureML job specs][aml-job-yaml]** (YAML) colocated with the code they describe
- Extension patterns (pipelines, data, experiment tracking, linting) pulled in only when your
  project needs them

The structure is (hopefully) graspable in 5 minutes. `ls`, read the Makefile, and you understand the
whole system.

## The story

This project started as a [layered approach to MLOps][approach-post] (v1): a Makefile-driven
scaffold with Docker at its core. Simple and approachable, but the developer experience was
cumbersome — Docker in the inner loop, no real package management, shared code via symlinks. After
using it across many projects and with the arrival of uv, things got built into v2: proper Python
packaging, uv workspaces, a full script-based CLI, pipeline support, data management. Way more
thorough and solid — but a tough swallow if you hadn't lived the journey that motivated each piece.

With powerful coding agents and skills, the problem can be tackled differently. Instead of a
heavyweight template anticipating every team's needs, the scaffolding is now a skill: a barebones
working base in `assets/`, rich references for growth patterns, and an agent that understands the
principles well enough to adapt them to your project. Start simple, get comfortable, grow when you
need to. The previous versions are preserved in the `v1-legacy` and `v2-legacy` branches for anyone
curious about the evolution.

## License

[MIT](LICENSE)

[aml]: https://learn.microsoft.com/en-us/azure/machine-learning/
[aml-job-yaml]: https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-job-command
[approach-post]: https://medium.com/data-science-at-microsoft/a-layered-approach-to-mlops-d935beefca2e
[devcontainer]: https://containers.dev/
[dockerfile]: https://docs.docker.com/reference/dockerfile/
[hdd-for-ai]: https://bepuca.dev/posts/hdd-for-ai
[pyproject-toml]: https://packaging.python.org/en/latest/guides/writing-pyproject-toml/
[uv]: https://docs.astral.sh/uv/
[uv-workspace]: https://docs.astral.sh/uv/concepts/workspaces/
