import sys
from pathlib import Path

from example.answer import get_the_ultimate_answer
from shared.logging import azureml_logger


def example(data_path: Path, greeting: str = "Hello", outputs_dir: Path = Path("../outputs")):
    """Example function with the main things needed to get started with AzureML

    :param data_path: Path where data is stored. Here to exemplify how to connect AzureML data
        (see `aml-job.yaml`).
    :param greeting: Word with which to greet the world.
    :param outputs_dir: Directory where to write outputs. Defaults to `../outputs` which is the
        default AzureML outputs directory. One level up because we need to `cd src` in the job
        for python to find the package.
    """

    # Tags are shown as properties of the job in the Azure ML dashboard. Run once.
    # Good practice to set input values as tags for reproducibility
    tags = {"greeting": greeting}
    azureml_logger.set_tags(tags)

    # Console logs in AzureML are captured from stdout and stderr
    print(f"{greeting} world!")
    print(f"'data_path' is pointing to '{data_path}'", file=sys.stderr)
    if isinstance(data_path, Path) and data_path.is_dir():
        for file in data_path.iterdir():
            print(f"  {file.relative_to(data_path)}", file=sys.stderr)

    # Metrics are numerical values
    metrics = {"answer": get_the_ultimate_answer()}
    azureml_logger.log_metrics(metrics)

    values = [1.0, 0.0, 1.0, 2.0, 3.0, 2.0, 4.0]
    for v in values:
        metrics = {"value": v}
        azureml_logger.log_metrics(metrics)

    outputs_dir.mkdir(exist_ok=True, parents=True)
    out_filepath = outputs_dir / "hello.txt"
    out_filepath.write_text("Hello darkness, my old friend!")


def main():
    import argparse
    import sys
    from pathlib import Path

    assume_debug = len(sys.argv) <= 1
    if assume_debug:
        print("WARNING: Using debug args because no args were passed")
        args_dict = {
            "data_path": Path("path/to/data"),
            "greeting": "Hello",
            # on isolated run reproduce remote outputs, on direct run keep at repo root
            "outputs_dir": Path("../outputs") if Path.cwd().name == "src" else Path("./outputs"),
        }
    else:
        parser = argparse.ArgumentParser(description="Driver script for Example Package")
        parser.add_argument("--data_path", type=Path, help="Path to data", required=True)
        parser.add_argument("--greeting", type=str, help="Greeting word", required=True)

        args = parser.parse_args()
        args_dict = vars(args)

    example(**args_dict)


if __name__ == "__main__":
    main()
