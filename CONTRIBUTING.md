# Contributing

This guide explains how to develop and test the skill itself — i.e. how to verify that an agent
using `azureml-scaffolding/SKILL.md` produces a working project, end to end, from the core scaffold
through every extension.

The workflow is: **use an agent to apply the skill to a throwaway project inside this repo, verify
each step, then throw the project away.** A human in the loop provides Azure credentials and
confirms anything that touches cloud resources.

## Prerequisites

- [uv](https://docs.astral.sh/uv/) installed
- [Docker](https://www.docker.com/) installed (for devcontainer testing)
- An AI coding agent with access to the workspace (e.g. Copilot in VS Code)
- For cloud steps: an Azure subscription with an AzureML workspace, a compute cluster, and Azure CLI
  with the `ml` extension
- For the data extension: a Blob Storage account with some data to download

## Overview

The test surface is a temporary project (`tmp/`) at the repo root (already gitignored). The agent
reads the skill, scaffolds the project there, and you verify each phase before moving on. Extensions
are layered in one at a time so failures are easy to isolate.

```
Phase 0  →  Core scaffold + devcontainer
Phase 1  →  Cloud execution (AzureML)
Phase 2  →  Extensions, one by one
```

______________________________________________________________________

## Phase 0 — Core scaffold + devcontainer

Give the agent a prompt like:

> Read `azureml-scaffolding/SKILL.md` and use it to scaffold a new project in `tmp/`. The project
> name is `testing-scaffolding` and the first package should be `hello`. Keep the starter logic from
> the skill's `mypkg` template as-is so we can validate the output.

### Verify locally

```bash
cd tmp

# deps lock and install
make sync

# local run (should print greeting + write outputs/hello.txt)
make run pkg=hello

# tests pass
make test
```

All three must succeed before moving on.

### Verify inside devcontainer

Open the `tmp/` folder in VS Code and reopen in the devcontainer. This validates the Dockerfile +
devcontainer.json work together. Inside the container, repeat:

```bash
make sync
make run pkg=hello
make test
```

Results must match what you got outside the container.

> **Note — devcontainer is optional but recommended.** You can develop without it. However, if you
> work on multiple projects, OS-level dependencies (system libraries, CLI tools, Python builds) can
> conflict in ways that uv alone cannot isolate. The devcontainer gives you a clean, reproducible OS
> layer per project. It also guarantees that what runs on your machine will run on AzureML, since
> the same Dockerfile is used for both.

______________________________________________________________________

## Phase 1 — Cloud execution (AzureML)

This phase requires a **human in the loop** for credentials and Azure resource names. Run these
steps inside the devcontainer (Azure CLI + `ml` extension are installed there via devcontainer
features).

### 1. Provide Azure config

Create `tmp/.env.local` (gitignored) with real values:

```dotenv
TENANT_ID=<your-tenant-id>
AZUREML_WORKSPACE=<your-workspace>
AZUREML_RESOURCE_GROUP=<your-resource-group>
```

### 2. Log in to Azure

```bash
az login --tenant <your-tenant-id>
```

### 3. Fill in job YAML placeholders

`mypkg` references should already be replaced with `hello` from scaffolding. Open
`tmp/src/hello/aml-job.yaml` and replace the remaining cloud-specific placeholders:

- `<azure-ml-cluster-name>` → your compute cluster name
- `<azure-ml-dataset-name>` and `<azure-ml-dataset-version>` → a real dataset, or remove the
  `data_path` input if you don't have one and adjust the command accordingly

You can ask the agent to do this for you — just provide the values.

### 4. Submit

```bash
make aml pkg=hello
```

### Verify

- The AzureML job appears in the workspace dashboard.
- Job completes successfully.
- Tags (`greeting`), metrics (`answer`, `value`), and `outputs/hello.txt` are visible in the job UI.

______________________________________________________________________

## Phase 2 — Extensions

Add extensions one at a time. After each one, verify that the core still works (`make run`,
`make test`) and that the extension's specific functionality works.

### 2a. Linting & hooks

Start here — linting is the lightest extension and validates that dev tooling installs and runs
correctly.

Prompt the agent:

> Add the linting extension from the skill to the project in `tmp/`.

Verify:

```bash
make lint                   # should run ruff, ty, mdformat without errors
make run pkg=hello          # core still works
make test
```

### 2b. Experimentation & traceability

Prompt the agent:

> Add the experimentation extension from the skill to the project in `tmp/`.

Verify:

```bash
# local run now writes to runs/<pkg>/<timestamp>/outputs/
make run pkg=hello
ls runs/hello/              # should contain a timestamped folder
ls runs/hello/*/outputs/    # outputs inside run folder
make test

# experiment commit (requires clean git state in tmp/)
cd tmp && git init && git add -A && git commit -m "init"
make aml pkg=hello exp="test experiment commit"
# should print experiment commit SHA and submit job;
#   AzureML auto-detects the experiments branch and commit SHA
```

### 2c. Pipelines

Prompt the agent:

> Add the pipelines extension from the skill to the project in `tmp/`. Create a toy two-step
> pipeline that reuses the `hello` package in both steps.

Verify:

```bash
make run pipe=<pipeline_name>   # runs locally, both steps execute
make run pkg=hello              # individual packages still work
make test
make aml pipe=<pipeline_name>   # submits pipeline job to AzureML
```

### 2d. Datasets

This extension requires **Azure access**. For registered Data Assets you need an AzureML workspace
with the `ml` CLI extension. For raw blob downloads you need a storage account, container, and a
regex pattern matching the files to download. A human must provide the relevant values. Skip this
step if you don't have either.

Prompt the agent:

> Add the datasets extension from the skill to the project in `tmp/`.

Verify (inside the devcontainer, logged into Azure):

```bash
# Registered Data Asset
make get-dataset name=<asset> version=<v>

# Raw blob storage
make get-data account=<acct> container=<ctr> regex='<pattern>'

ls data/                    # downloaded files present
make run pkg=hello && make test   # core still works
```

______________________________________________________________________

## Cleanup

When done, remove the throwaway project:

```bash
rm -rf tmp/
```

The `tmp/` directory is gitignored, so nothing from it should ever be committed.

______________________________________________________________________

## Tips for contributors

- **Validate up to the layer you touch.** The skill has three layers: code, specification (job
  YAML), and orchestration (Makefile/CI). If your change only affects code or project structure,
  Phase 0 is enough. If it touches job YAML or environment, you need Phase 1 (cloud submission).
  Match your testing depth to the layer your change reaches.
- **One extension at a time.** Layering makes failures easy to bisect.
- **Re-run core after each extension.** `make run pkg=hello && make test` should never break.
- **Keep the agent honest.** If the agent produces something that doesn't match the skill's
  principles (explicit deps, colocation, three layers), flag it — that's a skill bug worth fixing.
- **Cloud steps are opt-in.** You can contribute to the skill without Azure access. Phase 0 and the
  non-cloud parts of Phase 2 cover most of the surface.
- **Update the skill, not the test project.** If you find a better pattern while testing, update the
  files under `azureml-scaffolding/`, not the throwaway `tmp/` project.
