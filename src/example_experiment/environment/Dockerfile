FROM python:latest

# mlflow packages required for logging into Azure ML
# pytest package required for testing to work
RUN pip install 'azureml-mlflow' \
                'mlflow-skinny' \
                'pytest'

# Should match your DOCKER_WORKDIR in `config.env`
WORKDIR /mnt