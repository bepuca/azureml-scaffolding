FROM mcr.microsoft.com/devcontainers/base:jammy AS base

ARG PYTHON_VERSION=3.12

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

ENV UV_LINK_MODE="copy"
ENV UV_PYTHON=${PYTHON_VERSION}
COPY --from=ghcr.io/astral-sh/uv:0.4.29 /uv /uvx /bin/
RUN uv python install ${PYTHON_VERSION}


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


