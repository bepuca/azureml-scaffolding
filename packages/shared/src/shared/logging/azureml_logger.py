import os
import sys

# "MLFLOW_TRACKING_URI" is set-up when running inside an Azure ML Job

if tracking_uri := os.getenv("MLFLOW_TRACKING_URI", None):
    import mlflow

    mlflow.set_tracking_uri(tracking_uri)

    def set_tags(tags: dict[str, str]) -> None:
        mlflow.set_tags(tags)

    def log_metrics(metrics: dict[str, int | float]) -> None:
        mlflow.log_metrics(metrics)

else:

    def set_tags(tags: dict[str, str]) -> None:
        for name, value in tags.items():
            print(f"tag:{name}={value}", file=sys.stderr)

    def log_metrics(metrics: dict[str, int | float]) -> None:
        for name, value in metrics.items():
            print(f"metric:{name}={value}", file=sys.stderr)
