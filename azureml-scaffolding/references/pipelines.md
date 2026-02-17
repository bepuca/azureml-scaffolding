# Pipelines (Optional)

Use this pattern when one package is no longer enough and work must be composed
as multiple steps.

## What this adds

- Step packages/components with clear input/output contracts.
- A pipeline spec that wires steps and data flow explicitly.
- Ability to run steps independently while keeping orchestration declarative.

## Practical structure

- Keep each step as an independent package/component with colocated code,
  environment, and spec.
- Keep `aml-job.yaml` in packages that are runnable standalone.
- You may add `aml-component.yaml` ([docs][component-docs],
  [schema][component-schema]) to packages that participate in more than one
  pipeline to reuse step definition.
- Create a pipeline folder per flow under `pipelines/`:

```text
pipelines/
└── <pipeline_name>/
    ├── aml-pipeline.yaml      # AzureML pipeline spec
    └── main.py                # local sequential runner
```

The `aml-pipeline.yaml` file follows the AzureML pipeline job spec
([docs][pipeline-docs], [schema][pipeline-schema]).

This keeps one place for orchestration and allows local execution to mirror the
same step sequence defined for cloud execution.

## Makefile extension (local only)

Add a local-only pipeline target:

```makefile
pipe: ## Run pipeline locally (sequential)
	@test -n "$(pipe)" || { echo "usage: make pipe pipe=<name> [ARGS='...']"; exit 1; }
	uv run -m pipelines.$(pipe).main $(ARGS)
```

`make pipe` is for local orchestration only. Cloud submission stays the same
AzureML CLI flow (`make aml`),
so there is no need for legacy script machinery.

## Runner expectations

- `pipelines/<name>/main.py` should run step packages in order and pass explicit
  paths/arguments between them.
- It is up to developers to ensure local and remote pipeline definition are
  equivalent.
- Keep runner logic thin: orchestration only, no step business logic.

## Agent guidance

- Do not add pipeline machinery by default.
- Offer pipelines only when users request multi-step orchestration, reusable
  components, or explicit step-level lineage.
- Keep pipeline docs and templates separate from the minimal core path.

[pipeline-docs]: https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-job-pipeline?view=azureml-api-2
[pipeline-schema]: https://azuremlschemas.azureedge.net/latest/pipelineJob.schema.json
[component-docs]: https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-component-command?view=azureml-api-2
[component-schema]: https://azuremlschemas.azureedge.net/latest/commandComponent.schema.json
