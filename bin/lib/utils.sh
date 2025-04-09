# Library file for general utility functions

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo >&2 "This script must be sourced, not executed."
    exit 1
fi


utils::invalid_usage() {
    echo >&2 "$1"
    usage >&2   # Must be defined in script that sources this one
    exit 1
}