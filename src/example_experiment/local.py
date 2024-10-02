"""
The purpose of local.py is to make it easier to execute scripts when running on a local environment.

For example:
- hardcoding certain arguments
- running a sequence of scripts sequentially
- setting environment variables prior to script execution
"""
from pathlib import Path

from example_experiment.main import main

if __name__ == "__main__":
    main(greeting="Hello, there!", data_path=Path("../../data"))
