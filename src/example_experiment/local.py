"""
The purpose of local.py is to make it easier to execute scripts when running on a local environment.

For example:
- hardcoding certain arguments
- running a sequence of scripts sequentially
- setting environment variables prior to script execution
"""
from pathlib import Path

from main import run_script

if __name__ == "__main__":
    run_script(greeting="Hello, there!",
               data_path=Path('../../data'),
               logging_enabled=False)
