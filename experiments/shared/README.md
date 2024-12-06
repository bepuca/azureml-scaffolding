# Shared

This is a special package that contains code that may be shared across two
or more experiments. The functionality in `bin` ensures it is used properly
in AzureML. For local development, it is simply installed in the environment
as an editable package.

The package should not have any dependencies on its own. The dependencies
should be decided by each experiment. That way, we can allow experiments to
not have all dependencies that are used in `shared` if some of them are not
necessary.
