# This script defines functions to be used in other scripts
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo >&2 "This script must be sourced, not executed."
    exit 1
fi

# Name a run and create its directory
prep_run() {
    bin/chkenv "RUNS_PATH"
    run_group=$1  # usually package or pipeline name

    run_name=$(bin/pkg/name)
    # add timestamp locally so runs are sorted chronologically
    local_run_name="$(date +%Y%m%d_%H%M%S)_$run_name"
    run_dir="$RUNS_PATH/$run_group/$local_run_name"
    echo "$run_name" "$run_dir"
}

# Execute a package in its isolated environment
run_local() {
    package=$1
    uv run \
        --with-requirements "../environment/requirements.txt" \
        --isolated \
        --no-project \
        -m "${package//-/_}"
}

# Submit a job to AzureML
run_aml() {
    bin/chkenv "AZUREML_WORKSPACE" "AZUREML_RESOURCE_GROUP"

    run_name=$1
    run_dir=$2
    file=$3
    xargs=$4

    echo "$xargs" | xargs az ml job create -f "$run_dir/$file" \
	--resource-group "$AZUREML_RESOURCE_GROUP" \
    --workspace-name "$AZUREML_WORKSPACE" \
    --set name="$run_name"
}