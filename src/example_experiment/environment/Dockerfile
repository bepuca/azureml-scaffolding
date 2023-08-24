# Dockerfile can be ignored for most cases by just changing the environment.yaml
# Stage 1, allows us to leverage base mamba image
FROM condaforge/mambaforge:latest AS compile-image

# Create a conda environment called `core` that will always be activated
COPY environment.yaml .
RUN mamba env create --name core --file environment.yaml && mamba clean -y --all -f

# Stage 2, allows us to pick base OS
FROM ubuntu:22.04 AS build-image
COPY --from=compile-image /opt/conda /opt/conda

# Ensure conda/mamba can be called and pip uses the core environment
ENV PATH /opt/conda/envs/core/bin:/opt/conda/bin:$PATH

# Make bash the default shell
RUN chsh -s /bin/bash
SHELL ["/bin/bash", "-c"]

# Ensure `core` env is always activated
RUN echo "source activate core" >> ~/.bashrc
