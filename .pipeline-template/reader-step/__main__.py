from pathlib import Path


def read(data_path: Path):
    """Read "file.txt" in `data_path` and print its contents."""
    file = data_path / "file.txt"
    print(file.read_text())


def main():
    import argparse
    import os
    import sys

    assume_debug = len(sys.argv) <= 1
    if assume_debug:
        print("WARNING: Using debug args because no args were passed")
        args_dict = {
            "data_path": Path(os.environ["REPO_ROOT"]) / "data/outputs",
        }
    else:
        parser = argparse.ArgumentParser(description="Driver script for Example Package")
        parser.add_argument("--data_path", type=Path, help="Path to data", required=True)

        args = parser.parse_args()
        args_dict = vars(args)

    read(**args_dict)


if __name__ == "__main__":
    main()
