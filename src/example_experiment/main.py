from func_to_script import script

from common.logging.azureml_logger import AzureMLLogger


def get_the_ultimate_answer() -> int:
    """Dummy function to exemplify unit tests"""
    return 42


@script
def main(data_path: str, greeting: str = "Hello"):
    """Example function with the main things needed to get started with AzureML

    :param data_path: Path where data is stored. Here to exemplify how to connect AzureML data
        (see `azure-ml-job.yaml`).
    :param greeting: Word with which to greet the world.
    """
    logger = AzureMLLogger()

    # Tags are shown as properties of the job in the Azure ML dashboard. Run once.
    tags = {"tag": "example"}
    logger.set_tags(tags)

    # Console logs in AzureML are just prints
    print(f"{greeting} world!")
    print(f"'data_path' is pointing to '{data_path}'")

    # Metrics are numerical values
    metrics = {"answer": get_the_ultimate_answer()}
    logger.log_metrics(metrics)

    values = [1, 0, 1, 2, 3, 2, 4]
    for v in values:
        metrics = {"value": v}
        logger.log_metrics(metrics)


if __name__ == "__main__":
    # No arguments passed because we leverage the @script decorator
    main()
