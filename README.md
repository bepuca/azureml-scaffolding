# AzureML Scaffolding

AzureML Scaffolding provides a minimal yet comprehensive template for AI and
Machine Learning projects built on [Azure Machine Learning] (also referred to
as AzureML or AML). It implements [Hypothesis Driven Development] principles to
accelerate experimentation-driven progress. By distilling best practices from
numerous successful projects, we've created a developer-friendly foundation that
eliminates common setup hurdles. This scaffolding is designed to work seamlessly
with AzureML's experiment tracking and compute management, ensuring these
features are leveraged effectively from day one. Get started in minutes and
focus on what matters: building and shipping valuable ML solutions through
efficient experimentation and iteration.

[Hypothesis Driven Development]: https://www.bepuca.dev/posts/hdd-for-ai/
[Azure Machine Learning]:
    https://learn.microsoft.com/en-us/azure/machine-learning/

## Table of Contents

- [Why Azure Machine Learning?](#why-azure-machine-learning)
- [Core Design Principles](#core-design-principles)
- [Key Capabilities](#key-capabilities)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Data](#data)
    - [Registering data](#registering-data)
    - [Downloading data](#downloading-data)
  - [Packages](#packages)
    - [Shared package](#shared-package)
    - [Creating a new package](#creating-a-new-package)
    - [Adding dependencies to a package](#adding-dependencies-to-a-package)
    - [Executing a package](#executing-a-package)
  - [Pipelines](#pipelines)
    - [Creating a new pipeline](#creating-a-new-pipeline)
    - [Executing a pipeline](#executing-a-pipeline)
  - [Linting](#linting)
  - [Testing](#testing)

## Why Azure Machine Learning?

[Back to the Top](#table-of-contents)

Azure Machine Learning provides essential capabilities for enterprise ML
development that this scaffolding leverages:

- **Compute on Demand** - Use powerful machines only when needed and pay for
  actual usage. Scale from local development to multi-node clusters without code
  changes.
- **Experiment Tracking** - Every run is automatically tracked with metrics,
  parameters, and environment specs. Compare experiments, visualize progress,
  and identify winning approaches efficiently.
- **Complete Reproducibility** - All code, data references, and environment
  definitions are captured in self-contained snapshots. Any experiment can be
  reproduced exactly, even months later.
- **Enterprise-grade Data Management** - Leverage Data Assets for versioning,
  access control, and lineage tracking of datasets throughout your project
  lifecycle.
- **Collaboration** - Share experiments, results, and models with teammates
  without needing to share execution environments. Everyone with workspace
  access can view runs and inspect outcomes.

## Core Design Principles

[Back to the Top](#table-of-contents)

This scaffolding was built around four key principles that guide how ML projects
should operate:

- **Continuous Experimentation** - Conduct multiple parallel experiments without
  interference. Each experiment is isolated, allowing for fearless innovation
  with clear boundaries between variations.
- **Minimum Viable Compute** - Develop locally, test on small datasets, then
  scale to production workloads—all using the same code. Your laptop, a powerful
  VM, or a GPU cluster all run identical executions.
- **Developer Experience First** - Clear project structure, simple commands, and
  minimal boilerplate let you focus on ML code instead of infrastructure.
  Linting, testing, and best practices are built in.
- **Extensibility** - Customize and extend the scaffolding to fit your specific
  project needs. The structure accommodates different ML workflows while
  maintaining consistency.

## Key Capabilities

[Back to the Top](#table-of-contents)

AzureML Scaffolding enables you to:

- **Manage Parallel Experiments** - Develop and run multiple experiments with
  independent configurations and clear isolation boundaries.
- **Share Code Efficiently** - Use the `shared` package for code reuse across
  packages without duplication.
- **Run Anywhere** - Run the same code locally for fast iteration and remotely
  for full-scale execution. Docker containers ensure environment consistency.
- **Structure Your Project** - Maintain clean separation between ML code and
  infrastructure code with standardized package organization.
- **Leverage DevOps Practices** - Utilize built-in code linting, formatting, and
  testing capabilities to maintain quality.
- **Simplify Workflows** - Access all common tasks through an intuitive CLI with
  commands like `bin/pkg/aml` to run experiments in AzureML.
- **Build Pipelines** - Create multi-step ML workflows with proper dependency
  management between components.

## Prerequisites

- **Azure ML workspace** - For running and tracking experiments in AzureML, you
  need to have an Azure subscription with an Azure ML workspace. The workspace
  should have at least one compute cluster defined.
- **Docker** - This project leverages Docker-based environments to maximize
  reproducibility. Therefore, you need the [Docker engine] in your machine and
  potentially a license for it.
- **VSCode Dev Containers** - We use the [devcontainers] to capitalize on the
  Docker environments for an easy-to-set-up and portable development
  environment. This project is designed to be used within VSCode [Dev Containers
  extension] but it may be possible to tweak it for other editors.

[Docker engine]: https://docs.docker.com/engine/
[devcontainers]: https://containers.dev/
[Dev Containers extension]:
    https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

## Installation

[Back to the Top](#table-of-contents)

1. From your project folder, download all files in this repository. **The
   following command will overwrite any existing files matching the names of
   those in this repository.** It is recommended to run the following only on
   a git repository with all changes committed:

   ```bash
   curl -L https://github.com/bepuca/azureml-scaffolding/archive/v2.zip -o temp.zip \
   && unzip -o temp.zip \
   && cp -a azureml-scaffolding-2/. . \
   && rm -rf temp.zip azureml-scaffolding-2
   ```

2. Modify the [`pyproject.toml`](pyproject.toml) for your project.
   1. Get familiar with [uv] if it is your first time working with it.
   2. Modify the `name`, `version` and `description` to match your project's.
   3. By default, we use `python 3.12`. To change it for the environment and all
      tools used:
      1. Modify the `requires-python` key.
      2. Modify the `pythonVersion` in the `[tool.pyright]`.
      3. Modify the `target-version` in the `[tool.ruff]`.
      4. Modify the `ARG PYTHON_VERSION` in the
         [`Dockerfile`](.devcontainer/Dockerfile).
3. Modify the [`.env`](.env) file to match your Azure.
   1. Change the `AZUREML_WORKSPACE` value to the name of your workspace.
   2. Change the `AZUREML_RESOURCE_GROUP` value to the name of the resource
      group your workspace belongs to.
   3. Change the `AZUREML_TENANT_ID` value to the tenant ID of your Azure
      subscription.
4. Change the `name` key in the [`.devcontainer/devcontainer.json`] file to
   match your project name. This is the name of the container that will be
   created.
5. Run the action `Dev Containers: Rebuild and Reopen in Container` in VSCode
   using the [Command Palette]. This will build the Dev Container for the first
   time. After it finishes, you are all set.
6. Define the default compute in the templates yamls.
7. If it is the first time you use AzureML Scaffolding for a project of yours,
   make sure to get familiar with this document.
8. If you do not wish to persist any of the example packages provided with the
   template, you can remove them by running the following:

   ```bash
   bin/pkg/rm example
   bin/pkg/rm example-reader-step
   bin/pkg/rm example-writer-step
   ```

9. If you had existing code, move it to become one or more [packages]. You may
   need to [create a new package] and ensure the dependencies in its
   `pyproject.toml` match your existing requirements.

[uv]: https://docs.astral.sh/uv/
[Command Palette]:
    https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette
[packages]: #packages
[create a new package]: #creating-a-new-package

## Usage

[Back to the Top](#table-of-contents)

The main interface of this project is the script-based CLI in the `bin` folder.
These scripts abstract away the complexity in simple commands and ensure best
practices are followed. Each available command of the CLI is defined by the
filepath of the script. If you are interested in the details or wish to change
some behavior, refer first to the [`bin/README.md](bin/README.md). Otherwise,
that folder can be largely treated as a black box. The help should be enough to
leverage the CLI. You can display it by running:

```text
$ bin/help

  # Data

  bin/data/download   Download data from Azure Blob Storage
  bin/data/find       Find account, container and subdir for a named data asset
  bin/data/list       List data in a Blob Storage Container
  bin/data/register   Register a data asset in AzureML

  # Development

  bin/dev/sync        Ensure dev env is in sync with the repo
  bin/dev/test        Run pytest for the project with coverage

  # Environment

  bin/chkenv          Checks if the specified environment variables are set
  bin/env             Exports variables from an environment file

  # Linting

  bin/lint/md         Lints Markdown files and validate their links
  bin/lint/py         Format, line and type check all Python files in $PKGS_PATH
  bin/lint/shell      Checks shell scripts for potential issues

  # Package

  bin/pkg/aml         Execute a package in AzureML
  bin/pkg/local       Execute package locally as it would in AzureML
  bin/pkg/new         Initialize new package in the project
  bin/pkg/rm          Remove a package from the workspace

  # Pipeline

  bin/pipe/aml        Execute a pipeline in AzureML
  bin/pipe/local      Execute pipeline locally as it would in AzureML
  bin/pipe/new        Initialize new pipeline in the project
```

Most scripts have their own help, exposed through the `-h` or `--help` flags.
You can use these to get more information about the specific command you are
interested in. For example:

```text
$ bin/pkg/new -h
  Initialize new package in the project

  Usage: bin/pkg/new PACKAGE

  Options:
      -h, --help  Show this help message and exit

  Arguments:
    PACKAGE  Name of the new package.

  The script will create a new package directory in the "$PKGS_PATH" directory
  using the '.package_template' as a template. It will also add the new package
  to the uv workspace and install it to the local environment.
```

These scripts are created to provide a good developer experience. To that end,
they work in harmony with many other artifacts in the repo. You are encouraged
to modify them to suit your needs, but beware that most decisions have been
thought through and changing them may break some behavior:

- The .`devcontainer` folder implements the definition for a devcontainer. It
  uses a [multi-stage] [`Dockerfile`] that serves for both full repository
  devcontainer and for packages environment. The [`devcontainer.json`] also
  installs useful VSCode extensions and necessary [devcontainer features].
- The `.vscode` folder contains the configuration for VSCode. It includes some
  configuration to make sure VSCode leverages the tools correctly.

Finally, many of these scripts rely on the configuration through environment
variables. These are defined in the [`.env`](.env) file. In many cases, if you
are missing them, the script will fail with a clear error message. To make sure
these variables are set in your shell:

```bash
. bin/env
```

> **Tip**: The above command will set the environment variables from [`.env`].
> If you wish, that command also sets the variables in `.env.local` with higher
> precedence if it exists. This second file is ignored by git and useful if
> different developers need different values for the same variables. For more
> details, run `bin/env -h`.

[multi-stage]: https://docs.docker.com/build/building/multi-stage/
[`Dockerfile`]: .devcontainer/Dockerfile
[`devcontainer.json`]: .devcontainer/devcontainer.json
[devcontainer features]: https://containers.dev/features

### Data

[Back to the Top](#table-of-contents)

We recommend using [AzureML Data Assets] to manage data. This makes it easy to
share data across people and machines and ensures traceability and lineage.

[AzureML Data Assets]:
    https://learn.microsoft.com/en-us/azure/machine-learning/how-to-create-data-assets?view=azureml-api-2&tabs=cli

#### Registering data

[Back to the Top](#table-of-contents)

The first step is to register the data in AzureML. In general, this means
uploading the data and labeling it with a name and a version. The [AzureML Data
Assets] page gives a good overview. In this project, we can use the following
(which is a thin wrapper around the AzureML CLI) to register the data:

```bash
bin/data/register <specfile_path>
```

The `<specfile_path>` is the path to the YAML file that defines the data asset.
The minimal example is:

```yaml
$schema: https://azuremlschemas.azureedge.net/latest/data.schema.json

type: uri_folder
name: <NAME OF DATA ASSET>
version: <VERSION>
description: <DESCRIPTION>
path: ./relative/path/to/data
```

Once data is registered, it can be referenced in any AzureML YAML as
`azureml:<NAME OF DATA ASSET>:<VERSION>`. This is the recommended way to
reference data in AzureML. Data then is mounted or downloaded to the compute
target when the job is executed. This ensures clarity and traceability of the
data used in each job.

#### Downloading data

[Back to the Top](#table-of-contents)

Usually one person will register the data but many may wish to use it. Or even
the same person in a different machine. For this, it is convenient to be able to
download a data asset. This can be done using:

```bash
bin/data/find NAME VERSION | xargs bin/data/download
```

The data will be downloaded in the `data` folder, which is ignored by git and is
the recommended place for it. Downloading a data asset chains two commands
because `bin/data/download` may be leveraged alone to download any data in
Azure Blob Storage, registered or not.

### Packages

[Back to the Top](#table-of-contents)

A package is a self-contained unit of code that can be executed in isolation
from the rest of the codebase. In this project, packages are Python packages
defined in the `packages` folder. They are the base unit of execution. We
leverage the [uv workspaces] feature to provide both a good developer experience
through a master project environment and the ability to isolate runs to their
minimal dependencies. The minimal file structure for a package is:

```text
<package-name>/
├── aml-job.yaml
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

- The top package name has dashes. The inner package name, where the code lives,
  has underscores. This is standard practice in Python and what [uv] does too.
- **`__main__.py`** - This is the expected entrypoint of the package. When
  leveraging the `bin` scripts for local execution, this is the executed file.
- **`pyproject.toml`** - The dependencies of the package should be defined here.
  This is what is used to build an isolated environment for execution.
- **`environment/`** - This is the environment context. It should contain a
  `Dockerfile` that accepts a `requirements.txt` and builds an environment from
  it. The `requirements.txt` is generated from the dependencies defined in the
  `pyproject.toml` file at run time. We need a separate `environment/` folder
  because AzureML can cache the environment built from it if nothing changes.
  Having it at top level would mean a rebuild for every package change.
- **`aml-job.yaml`** - This is the AzureML job specification for the
  package. It defines the compute target, the environment to use, the code to
  upload and the command to run. This is what is used to run the package in
  AzureML. This job can be of two types:
  - **[Command job]** - This is the simplest job type. It runs a command in a
    container. This is the most common type of job and the one we use for most
    of our experiments.
  - **[Pipeline job]** - This is a more complex job type that allows chaining
    multiple commands. The difference with a [Pipeline] as defined in this
    project, is that defining a pipeline job within a package means all steps
    will have all the same code and share the environment. Thus, any change in
    the package will eliminate the cache. The main benefit of this pattern is to
    avoid defining multiple packages for steps that largely use the same code.
    For instance, a training and inference step.

An example package is provided in [`.package-template`]. It is useful as a
reference and used by `bin/pkg/new` to create a new package. Most files there
serve as live documentation. It includes examples on how to log metrics and
tags, how to define the YAML file, how to import and how to define the
environment.

[uv workspaces]: https://docs.astral.sh/uv/concepts/projects/workspaces/
[Command job]:
    https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-job-command?view=azureml-api-2
[Pipeline job]:
    https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-job-pipeline?view=azureml-api-2
[`.package-template`]: .package-template

#### Shared package

[Back to the Top](#table-of-contents)

This project supports a special package called `shared`. This package is meant
to contain code that needs to be shared across multiple packages. At execution
time, it is bundled with the package so it is available for execution. Points to
have in mind:

- The `pyproject.toml` of the `shared` package **should not contain
  dependencies**. It is the responsibility of the package to install what it
  needs.
- Due to the above point, not all files in `shared` can be imported from all
  packages without errors. This is okay as long as the structure and imports are
  well thought.

#### Creating a new package

[Back to the Top](#table-of-contents)

While you can create a package manually, we recommend using:

```bash
bin/pkg/new <package-name>
```

This creates the package from the `.package_template`, which ensures the package
is created with the correct structure and files. Additionally, the command
renames things in some files to match your package name and makes sure the
package is added to the `uv workspace` and, thus, the local environment. The
`Dockerfile` provided by the command works as it should, but feel free to change
it if you wish to do so.

#### Adding dependencies to a package

[Back to the Top](#table-of-contents)

To add dependencies needed for a package, you should add them to the
corresponding `pyproject.toml` file (and never to the master `pyproject.toml` of
the project). You can do that in different ways:

- **Manually** - You can add the dependencies manually to the `pyproject.toml`
  file in the `dependencies` key.
- **Using uv** - You can use the [uv] CLI to add dependencies. Run `uv add
  --help` for details. A short example is:

  ```bash
  uv add --package <your-package> <dependency>  # e.g. `ruff==0.5.0`
  ```

> **Tip**: We usually specify dependencies with fixed major and minor versions
> to avoid surprises. For example, `numpy==2.2.*` instead of `numpy>=2.2.0`.

#### Executing a package

[Back to the Top](#table-of-contents)

We are strong proponents of the **Minimum Viable Compute** and this project aims
to support it. We start developing in our laptops, move to bigger Virtual
Machines when the code we are developing requires it (e.g., to ensure GPUs are
used properly) and only after we have validated that the experiment runs in a
complete but lightweight setup (e.g., a training with a batch size of 2, 10
total samples for 1 epoch) we submit the experiment to run in Azure ML. This
helps us **shorten feedback loops and speed up development**.

Thus, the first step is usually to run the package locally. The easiest way to
execute any code locally is leveraging VSCode. The [Python extension] allows
users to easily run or debug any script. For this, it is easiest to have scripts
that do not require any arguments.

The problem with the previous approach is that it uses the project environment.
This environment contains the dependencies of all packages as well as some extra
dev dependencies. Thus, it is possible to miss dependency leaks. To run a
package in locally in isolation:

```bash
bin/pkg/local <package-name>
```

This command will:

1. Isolate the package in the `runs/<package-name>/<run-id>` folder. This will
   include `shared` package too. The `<run-id>` is a memorable name for the run
   prefixed with the date and time of the execution to make it easier to reason
   about the runs.
2. Export the package dependencies into a `requirements.txt`. This captures
   everything, but not more, that needs to be in the environment for the payload
   to run. These first two steps ensure we can always recover a result if we
   have the run directory.
3. Execute the `__main__.py` of the package. This file is expected to be the
   entrypoint of the package, following [Python's standard practice for exposing
   a package CLI].

> **Tip**: We have found that a good pattern to maximize dev experience is to
> have `__main__.py` to accept command line arguments but default to debug
> values if none passed. This way, we can quickly change things locally without
> having a potentially long command, which tends to be cumbersome. An example of
> this pattern can be found in the
> [`package-template`](.package-template/src/package_template/__main__.py). That
> script also show how to log tags and metrics to AzureML.

Once the isolated run succeeds locally, we are probably ready to submit the same
payload to AzureML. To do so:

```bash
bin/pkg/aml <package-name>
```

This command will:

1. Isolate the package in the exact same way as `bin/pkg/local`.
2. Submit the package for execution to AzureML. The specification of the job is
   defined in the `aml-job.yaml` file. This file is expected to be present
   in the package root folder. The command will use the isolated run folder as
   the context for the job submission. It is the responsibility of the user to
   point that file to `__main__.py` to make the payload equivalent to the one
   that runs locally.

Executing a run for a package in this manner, ensures the following:

- All files (but only the files) required for the execution are uploaded to
  AzureML and present in the job UI.
- The environment is built using only the `environment/` context, which, in
  turn, uses the `requirements.txt` generated. The environment definition is
  also bundled in the code, and thus it is always reproducible.
- Downloading the code snapshot in AzureML and submitting directly that folder
  to AzureML will produce the exact same results.
- Runs are present in AzureML. If linked to data, it is clear what data was used
  for the run. Additionally, everyone with access to the workspace can see and
  inspect the runs.
- If the package was created using `bin/pkg/new`, all runs for a package will be
  grouped together in AzureML under the experiment with the same name as the
  package (defined by the `experiment_name` key in the YAML).

> **Tip**: Getting the `aml-job.yaml` right the first time can be a bit
> fiddly. For that, we recommend using the one in the `.package-template` as a
> reference and starting point.

To bring the experimentation game to the next level, you can make any AzureML
execution an experiment by adding the `--exp` or `-e` flag to the command:

```bash
bin/pkg/aml --exp "Add cosine scheduler" <package-name>
```

This uses some `git` shenanigans to create a commit with all changes since main
in the `experiments` branch locally. Then, by triggering the AzureML job from
this `git` state, the commit linked in the AzureML UI contains all these
changes. If job submission succeeds, this commit is pushed to the remote
repository after ensuring that branch is updated with latest `main`. This has
the following benefits:

- The `experiments` branch will contain all experiments and will be persisted
  beyond the branches that were used to create them. This is useful to avoid
  having to keep all branches around forever. Otherwise, if AzureML links to a
  commit of a branch that is deleted, the link becomes broken.
- The commit message will contain the name of the experiment. This makes it
  easier to find experiments (provided that devs put effort in naming).
- The commit contains all changes made since main, no matter how many commits
  are in your branch at the moment. This allows for good atomic commits when
  developing but a single clear view of what is being tested in an experiment.
  Without this, AzureML links to the latest commit, which is usually a subset of
  the differences from main.

### Pipelines

[Back to the Top](#table-of-contents)

While most projects will start with one or a few isolated packages, many may
benefit from leveraging pipelines at later stages. A pipeline defines a sequence
of steps to execute. It is defined by a [Pipeline job] YAML
`<pipeline-name>.yaml` in the `pipelines` folder. If unfamiliar with AzureML
pipelines, reading the [pipeline documentation] is encouraged. As a primer, a
pipeline has the following properties (which would inform when you want to use
them):

- One step outputs can be connected to the inputs of another one.
- Steps connected will run sequentially, but the rest can run in parallel if
  sufficient compute is available.
- Steps are cached. If submitted with the same code and environment, they will
  not be re-executed. This is useful for long running steps that do not change
  often.
- Each step of the pipeline must reference a package. To do so, packages meant
  to be used in pipelines should implement a [Component] YAML defined.
- Component inputs are displayed in AzureML UI. This helps with traceability.
- The name of the job steps should match the name of the package referenced
  (with dashes changed to underscores due to AzureML expectation).

An example pipeline is provided in
[`.pipeline-template/pipeline-template.yaml`]. It is useful as a reference and
used by `bin/pipe/new` to create a new pipeline. The rest of the files in that
directory serve to create the example packages used by the pipeline. They also
contain an example [Component] YAML: [`aml-component.yaml`].

> **Tip**: A single package may implement multiple steps. This is useful when
> the steps are closely related and share a lot of code. For instance, a
> training and inference step. In this case, the package should implement one
> `aml-component.yaml` file per step. In these cases, `__main__.py` is usually
> relegated to local usage only and is the responsibility of the user to ensure
> the payload is equivalent to the multiple steps.

[pipeline documentation]:
    https://learn.microsoft.com/en-us/azure/machine-learning/how-to-create-component-pipelines-cli?view=azureml-api-2
[Component]:
    https://learn.microsoft.com/en-us/azure/machine-learning/reference-yaml-component-command?view=azureml-api-2
[`.pipeline-template/pipeline-template.yaml`]:
    .pipeline-template/pipeline-template.yaml
[`aml-component.yaml`]:
    .pipeline-template/example-reader-step/aml-component.yaml

#### Creating a new pipeline

[Back to the Top](#table-of-contents)

While you can create a pipeline manually, we recommend using:

```bash
bin/pipe/new <pipeline-name>
```

This creates a pipeline from the `.pipeline-template`. This creates the
`<pipeline-name>.yaml` file in the `pipelines` folder. By default, it will
create two packages in the `packages` folder: `example-reader-step` and
`example-writer-step`. These packages are used to demonstrate how to use the
pipeline. This is recommended for the first times. Once familiar, you may choose
to use the `--no-packages` flag to avoid adding them.

#### Executing a pipeline

[Back to the Top](#table-of-contents)

Similarly to packages, we can run a pipeline locally or in AzureML.

While we can use VSCode to run the pipeline locally, it may become cumbersome as
each step would need to be run separately. To make things a bit easier, we can
run:

```bash
bin/pipe/local <pipeline-name>
```

This command will:

1. Parse the pipeline YAML file to identify the packages used. This expects the
   `component` key to be of the form `./<package-name>/...`.
2. Isolate the packages in the `runs/<pipeline-name>/<run-id>` folder. In this
   case, at the top level of the folder there will only be the pipeline YAML.
   Each package is isolated in its own subfolder in the same way `bin/pkg`
   scripts do.
3. Execute each package `__main__.py` in the order they are defined in pipeline
   YAML. It is the responsibility of the user to ensure each of these files can
   be executed without arguments and that inputs and outputs are properly
   connected where needed.

Once this succeeds, once more we can execute the pipeline in AzureML in a similar
way:

```bash
bin/pipe/aml <pipeline-name>
```

This command will:

1. Isolate the packages in the exact same way as `bin/pipe/local`.
2. Submit the pipeline for execution to AzureML. The specification of the job is
   the `<pipeline-name>.yaml` file. It is the responsibility of the user to
   ensure it points to `aml-component.yaml` files for each step and that these
   files specify a payload equivalent to the one that runs locally.

This command also accepts the `--exp` or `-e` flag to create an experiment.

### Linting

[Back to the Top](#table-of-contents)

In this project, the main driver for linting is the [`pre-commit`] hooks, which
are installed by default and defined in [`.pre-commit-config.yaml`]. These block
commits unless the code passes all checks. By default, we have 3 hooks enabled
that execute the following commands (which may be called manually too):

- **[`bin/lint/py`]** - Checks all Python files in the `packages` folder. It
  runs the following tools:
  - **[ruff]** - This is a fast linter and formatter for Python. It is used to
    format the code and check for common issues. Configuration is found in the
    [`pyproject.toml`].
  - **[pyright]** - This is a type checker for Python. By default, it is set to
    `basic` mode. This means it will check for type errors if you define type
    hints but will not do anything if you do not. Some teams prefer to set it to
    `strict` mode, in which case all code must be type hinted. Configuration is
    found in the [`pyproject.toml`].

- **[`bin/lint/md`]** - Checks all Markdown files in the project. It runs the
  following tools:
  - **[markdownlint-cli2]** - This is a linter for Markdown files. It is used to
    check for common issues in Markdown files. Configuration is found in the
    [`.markdownlint-cli2.jsonc`].
  - **[markdown-link-check]** - This is a linter for Markdown links. It is used
    to check for broken links in Markdown files. Configuration is found in the
    [`.markdown-link.json`].

- **[`bin/lint/shell`]** - Checks shell files in the project. It runs the
  following tool:
  - **[shellcheck]** - This is a linter for shell scripts. It is used to check
  for common issues in shell scripts. This is a bit more complex and
  configuration is found in the caller script itself.

> **Tip**: In most cases, the user may ignore linting until the hooks run.
> However, sometimes it is useful to run some of it manually. VSCode will pick
> up `pyright` automatically and show errors in the editor. For `ruff`, the
> default devcontainer installs the extension and will show errors.
> Additionally, the `ruff` extension offers format imports and format code
> commands exposed in the command palette. For markdown, some errors are raised
> in the editor. We install the rewrap extension. The command "Rewrap Comment"
> in VSCode is useful to ensure the line length is respected. For `shellcheck`,
> the extension is installed and will also show errors in the editor.

[`pre-commit`]: https://pre-commit.com/
[ruff]: https://docs.astral.sh/ruff/
[pyright]: https://github.com/microsoft/pyright
[markdownlint-cli2]: https://github.com/DavidAnson/markdownlint-cli2
[markdown-link-check]: https://github.com/tcort/markdown-link-check
[shellcheck]: https://www.shellcheck.net/
[`bin/lint/py`]: bin/lint/py
[`bin/lint/md`]: bin/lint/md
[`bin/lint/shell`]: bin/lint/shell
[`pyproject.toml`]: pyproject.toml
[`.pre-commit-config.yaml`]: .pre-commit-config.yaml
[`.markdownlint-cli2.jsonc`]: .markdownlint-cli2.jsonc

### Testing

[Back to the Top](#table-of-contents)

We use and recommend [pytest] for testing. A little wrapper command
`bin/dev/test` is provided to run the tests with coverage.
