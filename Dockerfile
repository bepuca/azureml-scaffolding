FROM mcr.microsoft.com/devcontainers/base:jammy AS base

ARG HOME="/home"
ARG PYTHON_VERSION=3.12

# Install pyenv to install python
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${HOME}/.local/bin:$PATH"
RUN curl https://pyenv.run | bash

# Install needed OS packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    libsqlite3-dev

# Install python through pyenv
RUN pyenv install ${PYTHON_VERSION} \
    && pyenv global ${PYTHON_VERSION}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

FROM base as devcontainer

# Install poetry for development
RUN curl -sSL https://install.python-poetry.org | python - \
    && poetry self add poetry-plugin-export

FROM base as job-runner

# non-root user, created on base image
USER vscode

# Expect requirements.txt in context for running AzureML jobs
COPY requirements.txt .
RUN pip install -r requirements.txt


