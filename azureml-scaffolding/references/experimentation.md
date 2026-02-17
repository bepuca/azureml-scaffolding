# Experimentation & Traceability (Optional)

Use this pattern when a team asks: “Which exact run produced this output?”

Keep two concerns separate:

1. **Local outputs by run** (fast inspection and reproducibility)
2. **Git-linked experiment commits** (exact diff-from-main lineage for AML runs)

## 1) Local outputs by run

To keep entrypoints simple while enabling per-run output isolation:

- Treat output location as an infrastructure concern.
- Use an env var (recommended: `OUTPUTS_DIR`) to inject run-specific output paths.
- In each package entrypoint, read `OUTPUTS_DIR` with a safe fallback (for
  direct IDE/CLI runs).

### Entrypoint snippet

```python
import os
from pathlib import Path

def resolve_outputs_dir() -> Path:
    return Path(os.getenv("OUTPUTS_DIR", "./outputs"))
```

Use this resolved path as the default outputs destination in the package's main execution path.

Use a single `run` target. By default it writes to timestamped local run
folders, and AML can override `OUTPUTS_DIR=./outputs`.

```makefile
RUNS_DIR ?= runs
RUN_TS ?= $(shell date +"%Y%m%d_%H%M%S")
OUT_DIR ?= $(RUNS_DIR)/$(pkg)/$(RUN_TS)

run: ## Isolated local run for pkg
  @test -n "$(pkg)" || { echo "usage: make run pkg=<name> [ARGS='...']"; exit 1; }
  @out_dir="$${OUTPUTS_DIR:-$(OUT_DIR)/outputs}"; \
  OUTPUTS_DIR="$$out_dir" uv run --isolated --package $(pkg) -m $(pkg) $(ARGS)
```

This keeps local runs easy (`make run pkg=<name>`) while ensuring outputs are
grouped by run timestamp.

AML jobs should call the same `run` target and set `OUTPUTS_DIR=./outputs`.

Update package job YAML accordingly:

```yaml
command: >-
  make run pkg=<pkg_name> OUTPUTS_DIR=./outputs
  ARGS='
    --data_path "${{inputs.data_path}}"
    --greeting "${{inputs.greeting}}"
  '
```

Remote-to-local output download can be added as a separate target later.

## 2) Git-linked experiment commits (AML-only)

### Why

AzureML auto-detects the currently checked-out branch and commit when you
submit a job, and links to it in the Studio UI. By default that points to
your working branch (e.g. `feature/xyz`), which keeps changing. If you later
want to know *exactly* what code produced a given run, the link is stale.

### How it works

A dedicated `experiments` branch acts as a log of submitted runs. Each
submission adds one commit whose tree is the exact state of the code at
submission time. Because the commit is on a well-known branch that gets
pushed to the remote, the link AzureML records always resolves.

The flow has two parts:

**Script** (`scripts/prepare-experiment-commit.sh`) — prep only, no side
effects on the working directory:

1. Guard: working directory must be clean (no uncommitted changes).
2. Fetch remote, verify current branch has merged upstream `main`.
3. Skip if the same tree was already pushed to `experiments`.
4. Sync: if `experiments` diverged from `main`, add a "restore main" commit
   so the branch stays rooted in the latest `main` tree.
5. Create the experiment commit on top (current tree, parent = synced
   `experiments` head) and output its SHA.

**Makefile** — orchestrates checkout, submission, push, and restore:

1. Call the script to get the experiment commit SHA.
2. `git checkout experiments` — safe because the experiment commit has the
   same tree as HEAD, so no files change on disk.
3. Submit the job (`az ml job create`). AzureML now records `experiments`
   as the branch and the experiment commit as the SHA.
4. On success, push the commit to remote `experiments` so the link resolves.
5. Restore the original branch.

### Setup

Copy `scripts/prepare-experiment-commit.sh` from this skill into the
project's `scripts/` folder. The Makefile `aml` target handles the rest.

### Makefile pattern

```makefile
aml: ## Submit pkg job to AzureML (CLI v2)
  @test -n "$(pkg)" || { echo "usage: make aml pkg=<name> [exp='<message>'] [AML_ARGS='...']"; exit 1; }
  @if [ -n "$(exp)" ]; then \
    commit_id=$$(scripts/prepare-experiment-commit.sh "$(exp)"); \
    curr_branch=$$(git rev-parse --abbrev-ref HEAD); \
    git checkout experiments; \
    if az ml job create ...; then \
      git push origin "$$commit_id:experiments"; \
    fi; \
    git checkout "$$curr_branch"; \
  else \
    az ml job create ...; \
  fi
```

Without `exp=`, `make aml` submits normally (no experiment tracking). With
`exp='describe the experiment'`, it runs the full flow above.

## Agent guidance

- Offer this extension only after core local run flow is stable.
- Default to local outputs-by-run (`OUTPUTS_DIR` + timestamped run folder).
- Use one `run` target and override `OUTPUTS_DIR` in AML YAML.
- Keep AML output handling separate (AzureML `./outputs` default).
- Offer git-linked experiment commits only when users ask for strong
  diff-from-main lineage.