#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PARAMS_FILE="$SCRIPT_DIR/src/artifacts_plansys2/custom-params.yaml"

if [[ ! -f "$PARAMS_FILE" ]]; then
  echo "Missing required file: $PARAMS_FILE" >&2
  exit 1
fi

set +u
source /opt/ros/jazzy/setup.bash
if [[ -f install/setup.bash ]]; then
  source install/setup.bash
fi
set -u

ros2 run plansys2_terminal plansys2_terminal --ros-args --params-file "$PARAMS_FILE"
