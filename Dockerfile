FROM mcr.microsoft.com/devcontainers/base:jammy AS base

ARG HOME="/home"
ARG PYTHON_VERSION=3.12

# Install pyenv to install python
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${HOME}/.local/bin:$PATH"
RUN curl https://pyenv.run | bash

# Install needed OS packages for a complete Python installation
#   libssl-dev: Provides the development libraries and header files for SSL and TLS, necessary for secure connections.
#   libbz2-dev: Needed for bzip2 compression support.
#   libreadline-dev: Supports interactive command line interfaces, essential for Python's interactive shell.
#   libsqlite3-dev: Enables SQLite database support in Python.
#   libgdbm-dev: Needed for the GNU database manager, which is used by some Python modules.
#   liblzma-dev: Provides support for LZMA compression.
#   libffi-dev: Foreign Function Interface library, required for various Python modules that interface with C libraries.
#   zlib1g-dev: Provides the development files for the zlib compression library, necessary for handling compressed data.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    liblzma-dev \
    libffi-dev \
    zlib1g-dev


# Install python through pyenv
RUN pyenv install ${PYTHON_VERSION} \
    && pyenv global ${PYTHON_VERSION}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>


FROM base AS devcontainer

# Install poetry for development
RUN curl -sSL https://install.python-poetry.org | python -


FROM base AS job-runner

# non-root user, created on base image
USER vscode

# Create a virtual environment
RUN python -m venv /home/vscode/venv

# Ensure all commands use the virtual environment
ENV VIRTUAL_ENV=/home/vscode/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Expect requirements.txt in context for running AzureML jobs
COPY requirements.txt .
RUN pip install -r requirements.txt


