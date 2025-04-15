# package_template

This folder contains the code for the package `package_template`. A package
is a self-contained Python module with its own dependencies, entry point and
execution logic. A package is meant to be executed in AzureML for compute,
traceability or reproducibility purposes. It is executed either as a single job
or as a step of a pipeline job. here is simply a line of work with a certain
goal that might benefit from running in AzureML for compute, traceability or
reproducibility purposes. In the [AzureML Scaffolding] project, all packages
live inside the `./packages` folder and are managed within a [uv workspace] for
a good developer experience.

The minimum directory structure of an package is the following:

```text
package_template
├── README.md                   <- Documentation for the package.
└── src                         <- Source artifacts for the package.
    ├── .amlignore              <- Defines what not to upload to AzureML.
    ├── aml-job.yaml       <- Job spec for running package in AzureML.
    ├── tests                   <- Unit tests for the package.
    ├── environment             <- Environment context for package execution.
    │    ├── Dockerfile         <- Dockerfile to define environment.
    │    └── requirements.txt   <- Required dependencies (auto extracted).
    └── package_template        <- Executable code for the package.
        └── main.py             <- Entrypoint file for the package.
```
