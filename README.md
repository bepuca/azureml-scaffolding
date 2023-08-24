# AzureML Scaffolding

The goal of this project is to provide a minimal scaffolding to make it easier to work effectively with [Azure Machine Learning service](https://docs.microsoft.com/en-us/azure/machine-learning/). Our main focus is on the (often overlooked) Data Scientist's inner loop - that is, the work done during investigation/experimentation phase until model is "ready" for deployment. The common problem we noticed while working on multiple projects with different teams and organizations is that whenever we introduce any MLOps concepts and start operationalizing the project - it's usually a one-way ticket which changes the DS inner loop and makes it hard to continue experimenting and improving the solution. The main idea is to lower the friction of using AzureML and enable what we call `Continuous Experimentation`. This means that the data scientists are always enabled to keep experimenting and productionalizing or deploying models is not a blocker for that.

This project contains what we feel is the absolute minimum we need to fulfill our goal and is supposed to be flexible enough to be applicable to most (if not all) projects. At the same time, we intend to provide code with the same philosophy for solving common situations in the form of extensions for this template. These extensions can be found in the [AzureML Scaffolding Extensions repository](https://github.com/bepuca/azureml-scaffolding-extensions).

An important note to make is that on this base template, we make no assumptions on when and how you should register or deploy a model. These are usually heavily influenced by the use case so there does not exist a one size fits all. Despite that, we do provide extensions for some common scenarios.

## Cloning this repository

As described in more detail in [Common dependencies](#common-dependencies), we make use of symlinks to handle common dependencies.
To ensure that this behaviour is enabled, when cloning, use the following command:

```
git clone -c core.symlinks=true <Repo URL>
```

## Navigation
1. [Features overview](#features-overview)
2. [Getting started](#getting-started)
   1. [Requirements](#requirements)
   2. [Setting up new project](#setting-up-new-project)
   3. [Creating experiments](#creating-experiments)
3. [Concepts](#concepts)
   1. [Assumptions](#assumptions)
   2. [Expectations](#expectations)
   3. [Project structure](#project-structure)
   4. [Makefile](#makefile)
   5. [Common dependencies](#common-dependencies)


## Features overview
[[back to the top]](#navigation)

- Leverages the new [AzureML CLIv2](https://docs.microsoft.com/en-us/azure/machine-learning/concept-v2)
- Supports running multiple experiments with independent AzureML configurations
- Allows for sharing (not duplicating) code between experiments
- Local and remote execution - develop and quickly test code locally and execute full scale pipelines on [AzureML compute targets](https://docs.microsoft.com/en-us/azure/machine-learning/concept-compute-target)
- Using docker containers to ensure compatibility of environments between local and remote execution
- Clear separation between data science/ML and AzureML specific code
- Code linting and formatting
- Using `makefile` to offer a set of commands to abstract the complexity, eg.: `make new-exp exp=<your_experiment_name>` or `make job exp=<experiment_name>`.
   More details in [Makefile section](#makefile).

## Getting started

### Requirements
[[back to the top]](#navigation)

Some requirements could be flexible to other workflows and are mentioned as potential alternatives. Nevertheless, they would require some extra effort and will not work with the `Makefile` as it is. We may provide examples on how that would look like in the future.

- **Azure ML workspace** - For anything to work, you need to have an Azure ML workspace configured and, of course, and Azure account with access to that workspace. By configured, we basically mean created and at least one compute cluster defined to be able to run things there. It is likely you also need to have a registered dataset available. General documentation can be found here: https://docs.microsoft.com/en-us/azure/machine-learning/.

- **Azure ML CLI v2** - We recommend to interface with Azure ML through the CLI (rather than the python SDK) because it makes the separation between ML code and platform specific infrastructure much clearer (CLI uses YAMLs and not python code). Potential alternative: Python SDK.

    1. Follow the instructions in https://docs.microsoft.com/en-us/cli/azure/install-azure-cli to install the generic Azure CLI.
    2. Run the command `az extension add --name ml` in your command line to install the ML v2 extension.
    3. Run `az login` to make sure you are logged in your Azure account.
    4. Run `az account set --name <subscription_name>` to make your CLI point to the subscription that owns the Azure ML workspace. If you go to the Azure ML studio at https://ml.azure.com and navigate to the workspace, the name of the subscription appears at the top right of the screen.
    5. You are set to go!

- **Docker** - We strongly recommend using Docker based environments to maximize reproducibility. Therefore, all runs in your working machine will need the Docker engine installed there (if you follow the suggested workflow) and potentially a license for it. To install it, follow the instructions here: https://docs.docker.com/engine/install/


### Setting up new project
[[back to the top]](#navigation)

When starting a new blank project, the easiest is to create the new repository using this one as template if the platform you use allows that. If not, you can just initialize your project and then copy all the files manually.

Once you have the files in your repository, there are a few steps you need to follow before you are ready to work with it:

1. Modify `conf.env` with the variables of your project.
2. Modify the `name` field in `environment.yaml` at the root of your project to match the name of your project.
3. Create a new python (conda) environment from `environment.yaml` at root by running `conda env create -f environment.yaml`. Note that with not much work you could change to using other environment systems (e.g., virtualenv).
4. Activate your newly created environment by running `conda activate -n <name_step_2>`.
5. Install the precommits in your repository by running `pre-commit install` with the environment activated. After this, all commits will be linted and formatted.
6. Run `make new-exp exp=<your_experiment_name>` to create the first of your experiments. Then follow the instructions in [Creating experiments](#creating-experiments).
7. It is recommended to delete the `example_experiment` folder and keep only your own. The folder
aims to show examples of the most commonly needed things (like referencing a dataset or logging a
metric). The exact same code is present in the `.experiment_template`.
8. Remove the existing functionality in `./src/common`. Remove also the contents of the folder
`./src/<your_experiment_name>/common`. The provided code is just an example.

### Creating experiments
[[back to the top]](#navigation)

When creating a new experiment, there are a few things you need to set-up before you can run it:

1. Modify your `environment/environment.yaml` (and `Dockerfile` context if needed) to represent the environment you need.
2. Modify the `experiment_name` property in the `azure-ml-job.yaml` to match your experiment.
3. Modify the `compute` property in the `azure-ml-job.yaml` to point to one of the clusters in your Azure Machine Learning workspace.
4. Run `make build-exp exp=<your_experiment_name>` to build the Docker image so you can run the local commands. If you do not do this manually, any local command will trigger this first.
5. If you want to use the example command in `azure-ml-job.yaml` to try things work, modify the `inputs.data_path.path` to point to one of your datasets in the workspace so the job does not crash.

After that, you are ready to start modifying your `main.py` (and the `command` and `inputs` in the `azure-ml-job.yaml` to match it) and you will be set to start experimenting. You can also modify the `local.py` for faster local experimentation. You can just import the functionality of `main.py` to run a local experiment or you may want to run smaller pieces of the code while you develop or to debug them.

## Concepts

### Assumptions
[[back to the top]](#navigation)

While we aim to provide a template as non-assuming as possible, we did bake a few assumptions into the project. These are the ones that have worked well for us in several projects and we believe either improve the quality of the work, make it easier or both.

1. You are using (or intend to use) Azure Machine Learning for your machine learning project.
2. You tackle your machine learning problem through independent, reproducible experiments.
3. You use Docker for your environments to ensure reproducibility as much as possible and to avoid surprises in production or differences across machines.
4. You format and lint your code as soon as possible to ensure legibility and catch small bugs early.
5. You use a UNIX-based machine (Linux, macOS, Windows with WSL or [AzureML Compute Instance](https://docs.microsoft.com/en-us/azure/machine-learning/concept-compute-instance)). This is not completely requried, but the main driver of this project is `Makefile` and it is hard to work with it on Windows. For Windows users we recommend setting up Azure ML Compute instance as a dev environment and use this scaffolding from there. There are tools for running `make` in Windows but we do not guarantee our file to work. We may offer an extension to add full compatibility with Windows in the future if there is demand for it.

### Expectations
[[back to the top]](#navigation)

> DISCLAIMER: These are the expectations of the project, breaking them will result in some of the commands in the `Makefile` not working. We encourage you to honor them.

- All source code is located inside the folder defined as `CODE_PATH` in `config.env`. Default is `./src`.
- Common functionality across experiments is all centralized in `common` folder inside the code folder.
- Each experiment is located inside a folder named after the experiment inside the code folder.
- Inside each experiment, there are the following files: `azure-ml-job.yaml`, `main.py` and `local.py`. Note that `local.py` is gitignored, so every developer might need to create their own.
- Inside each experiment folder there is an `environment` folder representing the docker context of the environment for that experiment.
- Inside each `environment` folder there is a `Dockerfile` defining the environment based on the accompanying `environment.yaml` of the experiment.


### Project structure
[[back to the top]](#navigation)

Note this structure only reflects the base template. Adding extensions to your project might add new files or folders not documented here. For the sanity of your developers, we recommend you also update this structure when you do so or remove it from the `README `altogether.

```
├── .experiment_template         <- Base template to make it easier to add experiments.
├── .flake8                      <- Configuration file for flake8, the linter.
├── .gitignore                   <- Gitignore with the usual python project defaults.
├── .pre-commit-config.yaml      <- pre-commit config file with formatting and linting.
├── config.env                   <- Configuration file consumed by Makefile.
│                                   This ensures that it works for your project.
├── pyproject.toml               <- Configuration file for the project.
├── environment.yaml             <- Conda environment definition for project ops
│                                   (linting, formatting, etc).
├── LICENSE
├── README.md                    <- The top-level README for developers using this project.
├── Makefile                     <- Makefile with all the commands needed for the project.
├── data                         <- Data folder to copy datasets to the working machine.
│                                   Everything inside is ignored by git.
├── docs                         <- Docs belong here.
│   └── makefile                 <- Folder with files used by the `help` command of the Makefile.
├── models                       <- Folder to save trained models in your working machine.
│                                   Everything inside is ignored by git.
├── notebooks                    <- Folder for saving the jupyter notebooks of the project.
└── src                          <- Source code of the project.
    ├── common                   <- All code to be shared among experiments.
    └── <experiment>             <- All code relevant to one experiment.
        │                           Each experiment has one and name the folder.
        ├── environment          <- Docker context for the experiment environment.
        │   │                       Everything Docker needs, needs to be inside.
        │   ├── environment.yaml <- Conda specs used by the Dockerfile to define environment.
        │   └── Dockerfile       <- Dockerfile to define the environment of the experiment.
        ├── tests                <- Tests belong here.
        ├── azure-ml-job.yaml    <- YAML file consumed by the Azure ML on 'make job'.
        ├── main.py              <- Driver of the experiment, called in azure-ml-job.yaml.
        └── local.py             <- Local entrypoint for fast local experimentation.
                                    Aside from example in template, they are gitignored.
                                    If missing, each developer should create own.
```

### Makefile
[[back to the top]](#navigation)

The `Makefile` is designed to be the main driver of this project and aims to abstract away the complexity of the real commands behind short and easy to remember ones. At the same time, it intends to offer customization of arguments where it is needed.

Commands are called as `make <command> argument=<argument>` from the command line placed at the root folder of the project. Not all commands accept or require arguments.

While the `Makefile` in itself is quite transparent, it can be overwhelming to new users to Azure ML, docker, or both. We tried to make help as useful as possible so you can skip opening the file altogether and work successfully. Therefore, we suggest you start by running in your command line:

```make help```

This will display the available commands with a short description of them. For more details of each command and a description of the required and/or accepted arguments, run:

```make help cmd=<command_name>```

*Check [makefile docs](./docs/makefile) for list of supported commands.*

### Common dependencies
[[back to the top]](#navigation)

Most projects end up needing to reuse some code across experiments. While the usual way of doing it is through registering packages somewhere, we believe it introduces a signficant overhead, specially in the initial stages of a project where things change very quickly. Therefore, the solution we propose is to have a special folder at the experiment level called `common` where you should put all the code that is meant to be used by more than one experiment.

After that, you can make that dependency available to the relevant experiments by using the command `make dependency` (you may run `make help cmd=dependency` for details). Behind the scenes, this will create a symlink inside a folder also called `common` inside your experiment to the original file or folder. For you, it means that after running that command you can import the dependency from any file in the experiment simply by:

```from common import <your_dependency>```

If a dependency created on another machine does not work when you `git pull` (because instead of a symlink you get a text file inside the `common` folder of a given experiment), please check the git `symlinks` option by running:

```git config --get core.symlinks```

This option should never be `false` for the symlink dependencies to work. If it is, change it to true or unset it, delete the branch from your computer and pull again.
