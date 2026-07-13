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
PROBLEM_FILE="$SCRIPT_DIR/problem.pddl"
if $USE_SCRIPT_PROBLEM; then
    PROBLEM_FILE="$SCRIPT_DIR/script_problem.pddl"
fi

if [[ "$OUTPUT_ARG" == /* ]]; then
    OUTPUT_FILE=$OUTPUT_ARG
else
    OUTPUT_FILE="$SCRIPT_DIR/$OUTPUT_ARG"
fi

LOG_FILE="$OUTPUT_FILE.log"
STDERR_FILE="$OUTPUT_FILE.stderr"
PLAN_FILE="$SCRIPT_DIR/sas_plan"

if [[ ! -f "$PROBLEM_FILE" ]]; then
    echo "Problem file does not exist: $PROBLEM_FILE" >&2
    exit 1
fi

if ! command -v planutils >/dev/null 2>&1; then
    echo "planutils was not found in PATH. Install it and run: planutils install -y lama-first" >&2
    exit 1
fi

rm -f "$PLAN_FILE"

(
    cd "$SCRIPT_DIR"
    planutils run lama-first -- domain.pddl "$(basename -- "$PROBLEM_FILE")" > "$LOG_FILE" 2> "$STDERR_FILE"
)

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "Planner finished, but no plan file was produced at $PLAN_FILE" >&2
    echo "Planner log: $LOG_FILE" >&2
    echo "Planner stderr: $STDERR_FILE" >&2
    exit 1
fi

if [[ "$PLAN_FILE" != "$OUTPUT_FILE" ]]; then
    cp "$PLAN_FILE" "$OUTPUT_FILE"
fi

echo "Saved plan to $OUTPUT_FILE"
echo "Saved planner log to $LOG_FILE"
echo "Saved planner stderr to $STDERR_FILE"
