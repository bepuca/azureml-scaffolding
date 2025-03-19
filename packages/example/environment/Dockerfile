FROM mcr.microsoft.com/devcontainers/base:jammy AS base

ARG PYTHON_VERSION=3.12

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

ENV UV_LINK_MODE="copy"
ENV UV_PYTHON=${PYTHON_VERSION}
COPY --from=ghcr.io/astral-sh/uv:0.6.7 /uv /uvx /bin/
RUN uv python install ${PYTHON_VERSION}


# Stage only used for development
FROM base AS devcontainer

# Install the Microsoft Linux Repository
RUN curl -sSL -O https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    sudo apt-get update

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    shellcheck \
    azcopy


# Stage used in AML. AzureML always builds last stage.
FROM base AS job-runner

# non-root user, created on base image
USER vscode
ARG VENV_PATH=/home/vscode/venv

# disable caching as we build once
ENV UV_NO_CACHE=1

# Create a virtual environment
RUN uv venv ${VENV_PATH}
# Use the virtual environment automatically
ENV VIRTUAL_ENV="${VENV_PATH}"
# Ensure all commands use the virtual environment
ENV PATH="${VENV_PATH}/bin:$PATH"

# Expect requirements.txt in context for running AzureML jobs
COPY requirements.txt .
RUN uv pip install -r requirements.txt
