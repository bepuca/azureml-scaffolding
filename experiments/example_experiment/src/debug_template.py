"""
This file should serve as a template on how to debug a similar payload as the
one specified in the azure-ml-job.yaml. Users should copy it to have their own
`debug.py`, which is gitignored so it can be modified at will.
"""

from pathlib import Path

from example_experiment.main import main

if __name__ == "__main__":
    main(Path("an/example/path"), greeting="An example greeting")
