#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PREFIX=${1:-"$SCRIPT_DIR/run"}

PARSER="${PANDA_PARSER:-$HOME/planners/panda/pandaPIparser/pandaPIparser}"
GROUNDER="${PANDA_GROUNDER:-$HOME/planners/panda/pandaPIgrounder/pandaPIgrounder/pandaPIgrounder}"
ENGINE="${PANDA_ENGINE:-$HOME/planners/panda/pandaPIengine/build/pandaPIengine}"

"$PARSER" "$SCRIPT_DIR/domain.hddl" "$SCRIPT_DIR/problem.hddl" "$PREFIX.htn"
"$GROUNDER" "$PREFIX.htn" "$PREFIX.sas"
"$ENGINE" "$PREFIX.sas" | tee "$PREFIX.plan.grounded"
"$PARSER" -c "$PREFIX.plan.grounded" "$PREFIX.plan.actual"

echo "Final HDDL-compliant plan: $PREFIX.plan.actual"
