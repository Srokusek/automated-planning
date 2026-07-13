#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
USE_SCRIPT_PROBLEM=false
FILTERED_ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "-script" ]]; then
        USE_SCRIPT_PROBLEM=true
    else
        FILTERED_ARGS+=("$arg")
    fi
done
set -- "${FILTERED_ARGS[@]}"

OUTPUT_ARG=${1:-sas_plan}

if [[ $# -gt 0 ]]; then
    shift
fi

PROBLEM_FILE="$SCRIPT_DIR/problem.pddl"
if $USE_SCRIPT_PROBLEM; then
    PROBLEM_FILE="$SCRIPT_DIR/script_problem.pddl"
fi

if [[ "$OUTPUT_ARG" == /* ]]; then
    OUTPUT_FILE=$OUTPUT_ARG
else
    OUTPUT_FILE="$SCRIPT_DIR/$OUTPUT_ARG"
fi

STDERR_FILE="$OUTPUT_FILE.stderr"

if [[ ! -f "$PROBLEM_FILE" ]]; then
    echo "Problem file does not exist: $PROBLEM_FILE" >&2
    exit 1
fi

if ! command -v planutils >/dev/null 2>&1; then
    echo "planutils was not found in PATH. Install it and run: planutils install -y optic" >&2
    exit 1
fi

(
    cd "$SCRIPT_DIR"
    planutils run optic -- "$@" domain.pddl "$(basename -- "$PROBLEM_FILE")" > "$OUTPUT_FILE" 2> "$STDERR_FILE"
)

if [[ "$SCRIPT_DIR/sas-plan" != "$OUTPUT_FILE" ]]; then
    rm -f "$SCRIPT_DIR/sas-plan"
fi

if [[ "$SCRIPT_DIR/sas-plan.stderr" != "$STDERR_FILE" ]]; then
    rm -f "$SCRIPT_DIR/sas-plan.stderr"
fi

echo "Saved OPTIC output to $OUTPUT_FILE"
echo "Saved planner stderr to $STDERR_FILE"
