# AzureML Scaffolding

The AzureML Scaffolding aims to be both a minimal template and a reference for
 implementing [Hypothesis Driven Development] in [Azure Machine Learning]. We
crystallize here the learnings of numerous Data Science and Machine Learning
projects and aim to offer what we believe is a solid stating set-up with a good
developer experience that just works. That way, you can focus on building and
shipping - which is what ultimately matters - and start doing so in a matter of
minutes.

[Hypothesis Driven Development]: https://www.bepuca.dev/posts/hdd-for-ai/
[Azure Machine Learning]:
    https://learn.microsoft.com/en-us/azure/machine-learning/

## Principles

- **Continuous Experimentation** - Multiple lines of experimentation and
  deployment can coexist without influencing each other.
- **Full Reproducibility** - All meaningful executions are self-contained,
  tracked and can be reproduced at any time.
- **Minimal Assumptions** - Users have full freedom on what to run.
- **Minimum Viable Compute** - Code runs the same everywhere, from laptops to
  beefy VMs to multi-node cluster. No surprising errors when you change machine.
- **Good Developer Experience** - Once the basics are grasped, it should be easy
  and pleasant to use.
- **Extensible** - No two projects are made equal. It should be easy to modify
  and extend the scaffolding to fit your needs.

## Features Overview

- Developing multiple experiments in parallel with clear boundaries.
- Running multiple experiments with independent AzureML configurations.
- Sharing (not duplicating) code between experiments.
- Local and remote execution - develop and quickly test code locally and execute
  full scale pipelines on [AzureML compute targets].
- Leveraging Docker containers to ensure compatibility of environments between
  local and remote execution.
- Clear separation between data science/ML and AzureML specific code.
- Standardized (optional) code linting and formatting.
- Extensible CLI composed of scripts to abstract complexity behind simple
  commands. Run `bin/help` for an overview. For instance, running a
  package-based experiment in AzureML can be done with `bin/pkg/aml --exp "My
  experiment" <package>`.

[AzureML compute targets]:
    https://docs.microsoft.com/en-us/azure/machine-learning/concept-compute-target

## Concepts

### Packages

A package is a self-contained unit of code that can be executed in isolation
from the rest of the codebase. In this project, packages are Python packages
defined in the `packages` folder. Their minimal structure is:

```text
<package-name>/
├── azure-ml-job.yaml
├── environment/
│   └── Dockerfile
├── pyproject.toml
├── README.md
├── src/
│   └── <package_name>
│       ├── __init__.py
│       └── __main__.py
└── tests/
```

It is worth explaining a few things here:

- **`__main__.py`** - This is the entrypoint of the package. When leveraging the
  `bin` scripts for local execution, this is the executed file.
- **`pyproject.toml`** - The dependencies of the package should be defined here.
  This is what is used to build an isolated environment for execution.
- **`environment/`** - This is the environment context. It should contain a
  `Dockerfile` that accepts a `requirements.txt` and builds an environment from
  it. The `requirements.txt` is generated from the dependencies defined in the
  `pyproject.toml` file at run time. We need a separated `environment/` folder
  because AzureML can cache the environment built from it if nothing changes.
  Having it at top level would mean a rebuild for every package change.
- **`azure-ml-job.yaml`** - This is the AzureML job specification for the
  package. It defines the compute target, the environment to use, the code to
  upload and the command to run. This is what is used to run the package in
  AzureML. This job can be of two types:
  - **[Command job]** - This is the simplest job type. It runs a command in a
    container. This is the most common type of job and the one we use for most
    of our experiments.
  - **[Pipeline job]** - This is a more complex job type that allows to chain
    multiple commands. The difference with a [Pipeline] as defined in this
    project, is that defining a pipeline job within a package means all steps
    will have all the same code and share the environment. This is usually an
    advanced pattern for people familiar with AzureML and the benefits of
    pipelines.

An example package is provided in [`.package-template`]. It
is useful as a reference and used by `bin/pkg/new` to create a new package.

[Command job]:
    https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-job-command?view=azureml-api-2
[Pipeline job]:
    https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-job-pipeline?view=azureml-api-2
[`.package-template`]: .package-template

#### Shared package

This project supports a special package called `shared`. This package is meant
to contain code that needs to be shared across multiple packages. At execution
time, it is bundled with the package so it is available for execution. Points to
have in mind:

- The `pyproject.toml` of the `shared` package **should not contain
  dependencies**. It is the responsibility of the package to install what it
  needs.
- Due to the above point, not all files can be imported from all packages. This
  is okay as long as the structure and imports are well thought.

### Pipelines

A pipeline defines a sequence of steps to execute. It is defined by a [Pipeline
job] YAML `<pipeline-name>.yaml` in the `pipelines` folder. If unfamiliar with
AzureML pipelines, reading the [pipeline documentation] is encouraged. As a
primer, a pipeline has the following properties:

- One step outputs can be connected to the inputs of another one.
- Steps connected will run sequentially, but the rest can run in parallel if
  sufficient compute is available.
- Steps are cached. If submitted with the same code and environement, they will
  not be re-executed. This is useful for long running steps that do not change
  often.
- Each step of the pipeline must reference a package. To do so, packages meant
  to be used in pipelines should implement a [Component job] YAML defined.
- Component inputs are displayed in AzureML UI. This helps with traceability.

An example pipeline is provided in
[`.pipeline-template/pipeline-template.yaml`]. It is useful as a reference and
used by `bin/pipe/new` to create a new pipeline. The rest of the files in that
directory serve to create the example packages used by the pipeline. They
contain example [`aml-component.yaml`].

[pipeline documentation]:
    https://learn.microsoft.com/en-us/azure/machine-learning/how-to-create-component-pipelines-cli?view=azureml-api-2
[Component job]:
    https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-component-command?view=azureml-api-2
[`.pipeline-template/pipeline-template.yaml`]:
    .pipeline-template/pipeline-template.yaml
[`aml-component.yaml`]:
    .pipeline-template/example-reader-step/aml-component.yaml

## User Guide

### Prerequisites

- **Azure ML workspace** - For running and tracking experiments in AzureML, you
  need to have an Azure ML workspace configured and, of course, and Azure
  account with access to that workspace. By configured, we basically mean
  created and at least one compute cluster defined to be able to run things
  there. It is likely you also need to have a registered dataset available.
  General documentation can for [Azure Machine
  Learning](https://docs.microsoft.com/en-us/azure/machine-learning/).

- **Docker** - This project leverages Docker based environments to maximize
  reproducibility. Therefore, you need the Docker engine in your machine and
  potentially a license for it. To install it, follow the
  [instructions](https://docs.docker.com/engine/install/).

- **VSCode Dev Containers** - We use the
  [devcontainers](https://containers.dev/) to capitalize on the Docker
  environments for an easy to set-up and portable development environment. Our
  usual IDE is VSCode with the [Dev Containers
  extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers),
  but is not the only editor that can work with devcontainers.

### Setting up a new project

1. Create a repository based on this template or copy all the files if the
   project exists.
2. Modify the [`pyproject.toml`](pyproject.toml) for your project.
   1. Get familiar with [Poetry](https://python-poetry.org/docs/) if it is your
      first time working with it.
   2. Modify the `name` and `description` fields in the `[tool.poetry]` section
      to match your project's.
   3. By default, we use `python 3.12`. To change it for the environment and all
      tools used:
      1. Modify the `python` dependency in the `[tool.poetry.dependencies]`
         section.
      2. Modify the `pythonVersion` in the `[tool.pyright]`.
      3. Modify the `target-version` in the `[tool.ruff]`.
      4. Modify the `ARG PYTHON_VERSION` in the [`Dockerfile`](Dockerfile).
3. Modify the [`container.env`](container.env) file to point to make sure the
   scripts point to your AzureML workspace.
   1. Change the `AZURE_ML_WORKSPACE` value to the name of your workspace.
   2. Change the `RESOURCE_GROUP` value to the name of the resource group your
      workspace belongs to.
4. Run the action `Dev Containers: Rebuild and Reopen in Container` in VSCode
   using the [Command
   Palette](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette).
   This will build the Dev Container for the first time.

After following these steps, the project is ready to be worked on. Now we need
to create our first experiment.

### Creating an experiment

We define an experiment as an executable unit of software aiming to solve a
specific goal. Processing data from format A to format B, training a ResNet
model or evaluating the predictions from an arbitrary object detection model are
examples of experiments we have developed at some point. The level of
granularity at which you define an experiment is up to you and usually depends
on what makes sense in each project.

In this scaffolding, experiments are represented as folders inside
[`experiments`](experiments) and the
[example_experiment](experiments/example_experiment) is provided as a
minimalistic but complete example. We recommend having a look through the files
there, as they contain examples of most of the things you will need down the
line (e.g., how to log metrics, mount data assets, ...). At the very least, an
experiment is constituted of the following:

- [**`main.py`**](experiments/example_experiment/src/example_experiment/main.py)
  - The entrypoint of the experiment. This file should be a script executable
  from the command line and it usually accepts command line arguments.

- **Environment** - As mentioned, we use Docker containers for reproducible
  environments. By default, the environment used in AzureML is built dynamically
  when submitting an experiment run through the provided scripts. At a high
  level, the environment is built like this:

   1. Export the minimum Python dependencies needed to run the experiment into a
      `requirements.txt` thanks to the [Poetry dependency
      groups](https://python-poetry.org/docs/managing-dependencies/#dependency-groups)
      in [`pyproject.toml`](pyproject.toml). The groups used are the
      `[tool.poetry.dependencies]`, `[tool.poetry.group.azureml.dependencies]`
      and the `[tool.poetry.<experiment_name>.dependencies]`.
   2. Use the `job-runner` stage of the multi-stage [`Dockerfile`](Dockerfile)
      to build the Docker image that will constitute the environment where the
      experiment is executed.

- [**`azure-ml-job.yaml`**](experiments/example_experiment/src/azure-ml-job.yaml)
  - The [AzureML job
  specification](https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-job-command?view=azureml-api-2)
  for the experiment. It calls the `main.py` mentioned above, specifies the
  inputs that are passed to it (if any), the compute to use, the environment to
  use and the code to upload. Using the example provided here, only the
  experiment code and `common` (which is a special folder for code meant to be
  shared and reused across experiments) is uploaded. Thus, the snapshot created
  is self-contained and the experiment can always be rerun no matter what
  happens to the repository.

While these are the minimum necessary artifacts to run an experiment, the
following are often useful:

- [**`debug.py`**](experiments/example_experiment/src/debug_template.py) -
  Usually used to import the main function from `main.py` and call it with
  hardcoded arguments (instead of expecting them through the command line). That
  way, we can quickly try things locally and easily run it with a debugger
  without further setup. An alternative are `Run configurations` in the
  `launch.json` from VSCode, but that spreads further the places where things
  for an experiment are defined.

- [**`.amlignore`**](experiments/example_experiment/src/.amlignore) - A special
  file for AzureML with the same syntax as `.gitignore` files. The files
  referenced here are not uploaded in the snapshot of runs in AzureML. This
  helps ensure only what is meaningful is registered for posterity.

### Running an experiment

Once an experiment is defined, it is time to run it. We usually like to work in
the **Cheapest Viable Compute** and we designed this project to support it. We
start developing in our laptops, move to bigger Virtual Machines when the code
we are developing requires it (e.g., to ensure GPUs are used properly) and only
after we have validated that the experiment runs in a complete but lightweight
setup (e.g., a training with a batch size of 2, 10 total samples for 1 epoch) we
submit the experiment to run in Azure ML. This helps us shorten feedback loops
and speed up development.

#### Running an experiment locally

To run an experiment locally is simply executing `main.py` (or `local.py`, or a
shell script calling your `main.py`) from the machine where you are developing
the code.

This workflow can be done from your laptop or from a Virtual Machine you are
connected to. We usually recommend using [Azure Machine Learning Compute
Instances](https://learn.microsoft.com/en-us/azure/machine-learning/concept-compute-instance?view=azureml-api-2)
for this, as they are easy to provision, pay only when running and have most
things we usually need already installed. Each developer has their own machine/s
and with [VSCode Remote Development
Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
is truly easy to switch to different ones. Connect over SSH to allow you to work
with Devcontainers in the remote machine.

#### Running an experiment in Azure Machine Learning

To run an experiment in Azure Machine Learning is submitting a job to run based
on your `azure-ml-job.yaml` (which should be executing the `main.py`). The
example is a command job, which is the simplest one.

Before running the experiment, ensure the `azure-ml-job.yaml` of your experiment
is properly defined (the
[example_experiment](experiments/example_experiment/src/azure-ml-job.yaml) one
is a good reference):

1. `experiment_name` key matches the name of your experiment. This matters
   because that way all your runs for an experiment will be grouped in the UI.
2. `compute` points to a valid [Compute
   Cluster](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-create-attach-compute-cluster?view=azureml-api-2&tabs=python#what-is-a-compute-cluster)
   in your Azure Machine Learning workspace. For running jobs in AzureML we
   strongly favor Compute Clusters over Compute Instance. They scale up and down
   when there is payload to run. We use Compute Instances for active development
   only.
3. `command` points to your `main.py`.
4. `inputs` are defined and used in the `command` rather than hardcoded. Makes
   it easier to inspect.

You can do run the experiment using [`bin/pkg/aml`](bin/pkg/aml) script. Execute
`bin/pkg/run -h` for details. The script does the following:

1. Packaged the experiment (by using [bin/pkg/_iso](bin/pkg/_iso), an you can
   run `bin/pkg/_iso -h` for details). All artifacts necessary for the
   experiment are copied and bundled together. The substeps are the following:
   1. Create an isolated run folder in `runs` with a unique name.
   2. Copy the files of your experiment folder.
   3. Copy the `shared` folder.
   4. Create an `environment` folder. This will constitute the Docker context
      for the environment.
   5. Copy the [`Dockerfile`](Dockerfile) inside the `environment` folder.
   6. Extract a `requirements.txt` from the Poetry environment with only the
      dependencies necessary to run the experiment. These dependencies are
      derived from the dependency groups in the
      [`pyproject.toml`](pyproject.toml). The main, `azureml` and `<experiment>`
      group dependencies are used. These are the dependencies that will be
      installed in the environment.
2. Submit the experiment run from this isolated folder. The `code` and
   `environment` keys in the example experiment
   [`azure-ml-job.yaml`](experiments/example_experiment/src/azure-ml-job.yaml)
   show how you should define them to make sure the experiment works.

This will submit the job and run your experiment in the cloud. The main benefits
of using Azure Machine Learning (which is built on top of
[mlflow](https://mlflow.org/)) for this are:

- **Compute on demand** - Use the machines you need and pay only for the time
  they are running your experiment. Scale to big compute without hassle.
- **Traceability and reproducibility** - By using the script provided, the
  experiment will be fully reproducible as the artifacts needed to build the
  environment and run the experiment are uploaded as a self-contained snapshot.
  We strongly recommend using tags to log any input that is not hard-coded but
  affects behavior (as we do in the
  [`example_experiment`](experiments/example_experiment/src/example_experiment/main.py)).
  Otherwise these values would be lost.
- **Progress tracking** - If you use metrics (and we believe you should), you
  will track some sort of performance or quality of your experiments (as we do
  in the
  [`example_experiment`](experiments/example_experiment/src/example_experiment/main.py)).
  Over time, you may try to improve these numbers. By having all your runs
  together in AzureML, it is easy to display them and observe progress.
- **Shareability** - Everyone with read access to the workspace will be able to
  see the runs and inspect results. This is usually helpful when not working
  alone in a project.
- **Data Ops** - AzureML offers things like [Data Assets] and good interactions
  with Blob Storage. This makes it easy to version data and use it in jobs
  making it clear what data is used where.
