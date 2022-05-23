# Azure MLOps Scaffolding

The goal of this project is to provide a minimal scaffolding to make it easier to work effectively
with Azure Machine Learning. The main focus is in the (often overlooked) Data Scientist inner loop.
That is, the work done in experimentation trying to improve the solutions to the model so that
developers can focus on the actual code by making the infrastructure "just work" as much as
possible.

This project contains what we feel is the absolute minimum we need to fulfill our goal and is
applicable to most (if not all) projects. At the same time, we intend to provide code with the
same philosophy for solving common situations in the form of extensions for this template. These
extensions can be found in the Azure MLOps Scaffolding Extensions repository.

An important note to make is that on this base template, we make no assumptions on when and
how you should register or deploy a model. These are usually heavily influenced by the use case so
there does not exist a one size fits all. Despite that, we do provide extensions for some common
scenarios.

## Project Structre

```
├── .flake8                     <- Configuration file for flake8, the linter.
├── .gitignore                  <- Gitignore with the usual python project defaults.
├── .pre-commit-config.yaml     <- pre-commit config file with formatting and linting.
├── config.env                  <- Configuration file consumed by Makefile.
│                                  This ensures that it works for your project.
├── pyproject.toml              <- Configuration file for the project.
├── requirements.txt            <- Requirements file for formatting and linting of the project.
├── LICENSE
├── README.md                   <- The top-level README for developers using this project.
├── Makefile                    <- Makefile with all the commands needed for the project.
├── experiment_template.zip     <- Compressed template to make it easier to add experiments.
├── data                        <- Data folder to copy datasets to local.
│                                  Everything inside is ignored by git.
├── docs                        <- Docs belong here.
│   └── makefile                <- Folder with files used by the `help` command of the Makefile.
├── notebooks                   <- Folder for saving the jupyter notebooks of the project.
└── src                         <- Source code of the project.
    ├── common                  <- All code to be shared among experiments.
    └── <experiment>            <- All code relevant to one experiment.
        │                          Each experiment has one and name the folder.
        ├── environment         <- Docker context for the experiment environment.
        │   │                      Everything Docker needs, needs to be inside.
        │   └── Dockerfile      <- Dockerfile to define the environment of the experiment.
        ├── tests               <- Tests belong here.
        ├── azure-ml-job.yaml   <- YAML file consumed by the Azure ML on 'make job'.
        ├── main.py             <- Driver of the experiment, called in azure-ml-job.yaml.
        └── local.py            <- Local entrypoint for fast local experimentation.
                                   Aside from example in template, they are gitignored.
                                   If missing, each developer should create own.
```
## Assumptions

While we aim to provide a template as non-assuming as possible, we did bake a few assumptions into
the project. These are the ones that have worked well for us in several projects and we believe
either improve the quality of the work, make it easier or both.

1. You are using (or intend to use) Azure Machine Learning for your machine learning project.
2. You tackle your machine learning problem through independent, reproducible experiments.
3. You use Docker for your environments to ensure reproducibility as much as possible and to
avoid surprises in production.
4. You format and lint your code as soon as possible to ensure legibility and catch small bugs early.
5. You use a UNIX-based machine (Linux, macOS, Windows with WSL). This is not completely requried,
but the main driver of this project is the `Makefile` and it is harder to work with them on Windows.
We recommend installing Windows Subsystem for Linux. You can also copy the commands manually. There
are tools for running `make` in Windows but we do not guarantee our file to work.


## Makefile

The `Makefile` is designed to be the main driver of this project and aims to abstract away the
complexity of the real commands behind short and easy to remember ones. At the same time, it intends
to offer customization of arguments where it is needed.

Commands are called as `make <command> argument=<argument>` from the command line placed at the
root folder of the project. Not all commands accept or require arguments. To get started, run
`make help` to display the available commands.

### Expectations

> DISCLAIMER: These are the expectations of the project, breaking them will result in some of the commands in the `Makefile` not working. We encourage you to honor them.

- All source code is located inside the folder defined as `CODE_PATH` in `config.env`. Default is `./src`.
- Common functionality across experiments is all centralized in `common` folder inside the code folder.
- Each experiment is located inside a folder named after the experiment inside the code folder.
- Inside each experiment, there are the following files: `az-ml-job.yaml`, `main.py` and `local.py`. Note that `local.py` is gitignored, so every developer might need to create their own.
- Inside each experiment folder there is an `environment` folder representing the docker context of the environment for that experiment.
- Inside each `environment` folder there is a `Dockerfile` defining the environment of the experiment.

## User guide

### New project

When starting a new blank project, the easiest is to create the new repository using this one as
template if the platform you use allows that.  If not, you can just initialize your project and then
copy all the files manually.

Once you have the files in your repository, there are a few steps you
need to follow before you are ready to work with it:

1. Modify `conf.env` with the variables of your project.
2. Create a new python environment with your favourite tool (conda, virtualenv, ...) for the
formatting toolds of the project.
3. Install the `requirements.txt`  in your formatting environment.
4. Install the precommits in your repository by running `pre-commit` install with the environment
activated. After this, all commits will be linted and formatted.
5. Run `make new-exp exp=<your_experiment_name>` to create the first of your experiments. Then
follow the instructions in the following section.
6. It is recommended to delete the `example_experiment` folder and keep only your own. The folder
aims to show examples of the most commonly needed things (like referencing a dataset or logging a
metric).
7. Remove the existing functionality in `./src/common`. The provided code is just an example.

### New experiment

When creating a new experiment, there are a few things you need to set-up before you can run it:

1. Modify your `Dockerfile` (and `environment` context if needed) to represent the environment you need.
2. Modify the `experiment_name` property in the `azure-ml-job.yaml` to match your experiment.
3. Modify the `compute` property in the `azure-ml-job.yaml` to point to one of the clusters in your
Azure Machine Learning workspace.
4. Run `make build-exp exp=<your_experiment_name>` to build the Docker image so you can run the
local commands.
5. If you want to use the example command in `azure-ml-job.yaml` to try things work, modify the
`inputs.data_path.path` to point to one of your datasets in the workspace so the job does not
crash.

After that, you are ready to start modifying your `main.py` (and the `command` and `inputs` in the
`azure-ml-job.yaml` to match it) and you will be set to start experimenting. You can also modify
the `local.py` for faster local experimentation. You can just import the functionality of `main.py`
to run a local experiment or you may want to run smaller pieces of the code while you develop or to
debug them.
