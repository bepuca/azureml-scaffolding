# experiment_template

This folder contains the code for the experiment `experiment_template`. An
experiment is simply a line of work with a certain goal that might benefit
from running in AzureML for compute, traceability or reproducibility purposes.
In the [AzureML Scaffolding] project, an experiment is represented as a
[uv workspace] inside the `./experiments` folder.

The minimum directory structure of an experiment is the following:

```text
experiment_template
├── README.md                   <- Documentation for the experiment.
└── src                         <- Source artifacts for the experiment.
    ├── .amlignore              <- Defines what not to upload to AzureML.
    ├── azure-ml-job.yaml       <- Job spec for running experiment in AzureML.
    ├── debug_template.py       <- Template for local debugging.
    ├── debug.py                <- File for local debugging. Gitignored.
    ├── environment             <- Environment context for experiment.
    │    ├── Dockerfile         <- Dockerfile to define environment.
    │    └── requirements.txt   <- Required dependencies (auto extracted).
    └── experiment_template     <- Executable code for the experiment.
        ├── main.py             <- Entrypoint file for the experiment.
        └── tests               <- Unit tests for the experiment.
```