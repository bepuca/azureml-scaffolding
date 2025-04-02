from pathlib import Path


def write(content: str, data_path: Path):
    """Write `content` to "file.txt" in `data_path`"""
    data_path.mkdir(parents=True, exist_ok=True)
    file = data_path / "file.txt"
    file.write_text(content)


def main():
    import argparse
    import os
    import sys

    assume_debug = len(sys.argv) <= 1
    if assume_debug:
        print("WARNING: Using debug args because no args were passed")
        args_dict = {
            "content": "Houston we do not have a problem!",
            "data_path": Path(os.environ["REPO_ROOT"]) / "data/outputs",
        }
    else:
        parser = argparse.ArgumentParser(description="Driver script for Example Package")
        parser.add_argument("--content", type=str, help="Content to write", required=True)
        parser.add_argument("--data_path", type=Path, help="Path to data", required=True)

        args = parser.parse_args()
        args_dict = vars(args)

    write(**args_dict)


if __name__ == "__main__":
    main()
