if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo >&2 "This script must be sourced, not executed."
    exit 1
fi

# Execute package in current directory in its isolated environment
local::run() {
    if [ $# -eq 0 ]; then
        echo>&2 "PACKAGE not provided."
        echo>&2 "Usage: ${FUNCNAME[0]} PACKAGE"
        exit 1
    fi

    local package=$1
    uv run \
        --with-requirements "../environment/requirements.txt" \
        --isolated \
        --no-project \
        -m "${package//-/_}"
}
