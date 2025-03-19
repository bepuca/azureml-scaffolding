from pathlib import Path


def fun(data_path: Path):
    data_path.mkdir(parents=True, exist_ok=True)
    file = data_path / "hello.txt"
    file.write_text("Houston we do not have a problem")


def main():
    import argparse
    import sys
    from pathlib import Path

    assume_debug = len(sys.argv) <= 1
    if assume_debug:
        print("WARNING: Using debug args because no args were passed")
        args_dict = {
            "data_path": Path("/workspaces/azure-mlops-scaffolding/data/outputs"),
        }
    else:
        parser = argparse.ArgumentParser(description="Driver script for Example Package")
        parser.add_argument("--data_path", type=Path, help="Path to data", required=True)

        args = parser.parse_args()
        args_dict = vars(args)

    fun(**args_dict)


if __name__ == "__main__":
    main()
