#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF
Create an experiment commit representing full diff-from-main, optionally run a command, then restore previous git ref state.

Usage:
  $0 "EXPERIMENT_MESSAGE" [-- command args...]

Environment:
  BASE_REF   Base reference parent for experiment commit (default: main)
  EXP_REF    Temporary branch/ref name to hold commit (default: experiments)
  KEEP_REF   If 1, keep EXP_REF pointing to new commit after command (default: 0)

Examples:
  $0 "test new featurizer"
  $0 "test new featurizer" -- az ml job create ... --set tags.experiment_commit=
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

message=${1:-}
if [[ -z "$message" ]]; then
    echo "Missing experiment message." >&2
    usage
    exit 1
fi
shift

base_ref=${BASE_REF:-main}
exp_ref=${EXP_REF:-experiments}
keep_ref=${KEEP_REF:-0}

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not inside a git repository." >&2
    exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Working directory must be clean before creating an experiment commit." >&2
    exit 1
fi

base_commit=$(git rev-parse "$base_ref")
tree_id=$(git rev-parse HEAD^{tree})
new_commit=$(git commit-tree "$tree_id" -p "$base_commit" -m "$message")

exp_ref_full="refs/heads/$exp_ref"
had_old_ref=0
old_ref=""
if git show-ref --verify --quiet "$exp_ref_full"; then
    had_old_ref=1
    old_ref=$(git rev-parse "$exp_ref_full")
fi

git update-ref "$exp_ref_full" "$new_commit"

restore_ref() {
    if [[ "$keep_ref" == "1" ]]; then
        return
    fi

    if [[ "$had_old_ref" == "1" ]]; then
        git update-ref "$exp_ref_full" "$old_ref" "$new_commit"
    else
        git update-ref -d "$exp_ref_full" "$new_commit" || true
    fi
}

if [[ "${1:-}" == "--" ]]; then
    shift
    if [[ $# -eq 0 ]]; then
        echo "Missing command after --" >&2
        restore_ref
        exit 1
    fi

    set +e
    EXPERIMENT_COMMIT="$new_commit" "$@"
    cmd_status=$?
    set -e

    restore_ref
    echo "$new_commit"
    exit "$cmd_status"
fi

echo "$new_commit"
restore_ref
