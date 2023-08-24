import os

import mlflow


class AzureMLLogger:
    """Class able to log into AzureML and also work on local runs"""

    def __init__(self):
        self.mlflow_run = False
        # "MLFLOW_TRACKING_URI" is set-up when running inside an Azure ML Job
        tracking_uri = os.getenv("MLFLOW_TRACKING_URI", None)
        if tracking_uri is not None:
            self.mlflow_run = True
            # This command only needs to run once
            mlflow.set_tracking_uri(tracking_uri)

    def set_tags(self, tags: dict[str, str]):
        if self.mlflow_run:
            mlflow.set_tags(tags)
        else:
            print(tags)

    def log_metrics(self, metrics: dict[str, int | float]):
        if self.mlflow_run:
            mlflow.log_metrics(metrics)
        else:
            print(metrics)
