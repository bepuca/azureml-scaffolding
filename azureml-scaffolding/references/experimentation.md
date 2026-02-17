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

Main benefit: each AzureML run is linked to one commit that contains the full
diff from `main`, so it is immediately clear what is being tried.

Script location in this skill:

- `skill/scripts/prepare-experiment-commit.sh`

When applying this pattern to a user project, copy the script into the
project's `scripts/` folder and call it from `make aml`.

The script is intentionally a small wrapper around advanced git patterns.
If users want internals, ask an agent to explain it.

By default it restores the previous ref state after execution.

AML target pattern:

```makefile
aml: ## Submit pkg job to AzureML (CLI v2)
  @test -n "$(pkg)" || { echo "usage: make aml pkg=<name> [exp='<message>'] [AML_ARGS='...']"; exit 1; }
  @extra_args=""; \
  if [ -n "$(exp)" ]; then \
    exp_sha=$$(scripts/prepare-experiment-commit.sh "$(exp)"); \
    extra_args="--set tags.experiment_commit=$$exp_sha"; \
  fi; \
  az ml job create ... $$extra_args $(AML_ARGS)
```

## Agent guidance

- Offer this extension only after core local run flow is stable.
- Default to local outputs-by-run (`OUTPUTS_DIR` + timestamped run folder).
- Use one `run` target and override `OUTPUTS_DIR` in AML YAML.
- Keep AML output handling separate (AzureML `./outputs` default).
- Offer git-linked experiment commits only when users ask for strong
  diff-from-main lineage.