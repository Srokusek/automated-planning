#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DOMAIN_FILE="$SCRIPT_DIR/src/artifacts_plansys2/pddl/domain.pddl"
PROBLEM_FILE="$SCRIPT_DIR/src/artifacts_plansys2/pddl/problem.pddl"
PARAMS_FILE="$SCRIPT_DIR/src/artifacts_plansys2/custom-params.yaml"

for required_file in "$DOMAIN_FILE" "$PROBLEM_FILE" "$PARAMS_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing required file: $required_file" >&2
    exit 1
  fi
done

set +u
source /opt/ros/jazzy/setup.bash
set -u

colcon build --symlink-install

set +u
source install/setup.bash
set -u

FAKE_ACTIONS_PID=""

cleanup() {
  if [[ -n "$FAKE_ACTIONS_PID" ]]; then
    kill -INT "$FAKE_ACTIONS_PID" 2>/dev/null || true
    wait "$FAKE_ACTIONS_PID" 2>/dev/null || true
    FAKE_ACTIONS_PID=""
  fi
}

trap cleanup EXIT INT TERM

ros2 launch artifacts_plansys2 fake_actions_launch.py &
FAKE_ACTIONS_PID=$!

ros2 launch plansys2_bringup plansys2_bringup_launch_distributed.py \
  model_file:="$DOMAIN_FILE" \
  problem_file:="$PROBLEM_FILE" \
  params_file:="$PARAMS_FILE" \
#  bt_builder_plugin:=STNBTBuilder
