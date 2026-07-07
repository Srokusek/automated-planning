#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  ./solve-local.sh DOMAIN.pddl PROBLEM.pddl [planner-package] [output-file]

Examples:
  ./solve-local.sh 2.2/domain.pddl 2.2/problem.pddl
  ./solve-local.sh 2.1/domain.pddl 2.1/problem.pddl lama-first
  ./solve-local.sh 2.2/domain.pddl 2.2/problem.pddl enhsp 2.2/sas_plan

Environment:
  PDDL_SERVICE_URL   Base URL of the local planning service.
                     Default: http://localhost:5001
  PLANNER_PACKAGE    Planner package to use when no third argument is given.
                     Default: enhsp
  POLL_INTERVAL      Seconds between result checks.
                     Default: 1
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 2 || $# -gt 4 ]]; then
    usage >&2
    exit 2
fi

domain=$1
problem=$2
package=${3:-${PLANNER_PACKAGE:-enhsp}}
output_file=${4:-sas_plan}
service_url=${PDDL_SERVICE_URL:-http://localhost:5001}
poll_interval=${POLL_INTERVAL:-1}

if [[ ! -f "$domain" ]]; then
    echo "Domain file not found: $domain" >&2
    exit 1
fi

if [[ ! -f "$problem" ]]; then
    echo "Problem file not found: $problem" >&2
    exit 1
fi

endpoint="${service_url%/}/package/${package}/solve"

echo "POST $endpoint" >&2
echo "domain:  $domain" >&2
echo "problem: $problem" >&2
echo "output:  $output_file" >&2

response=$(
    python3 -c '
import json
import pathlib
import sys

domain = pathlib.Path(sys.argv[1]).read_text()
problem = pathlib.Path(sys.argv[2]).read_text()
print(json.dumps({"domain": domain, "problem": problem}))
' "$domain" "$problem" |
    curl -sS \
        -H "Content-Type: application/json" \
        -X POST \
        --data-binary @- \
        "$endpoint"
)

result_path=$(
    python3 -c '
import json
import sys

try:
    data = json.loads(sys.stdin.read())
except json.JSONDecodeError:
    sys.exit(2)

if "result" not in data:
    print(json.dumps(data), file=sys.stderr)
    sys.exit(3)

print(data["result"])
' <<< "$response"
)

if [[ "$result_path" == http://* || "$result_path" == https://* ]]; then
    result_url=$result_path
else
    result_url="${service_url%/}${result_path}"
fi

echo "result:  $result_url" >&2

while true; do
    result_response=$(
        curl -sS \
            "$result_url"
    )

    status=$(
        python3 -c '
import json
import sys

try:
    data = json.loads(sys.stdin.read())
except json.JSONDecodeError:
    print("__INVALID_JSON__")
    sys.exit(0)

print(data.get("status", ""))
' <<< "$result_response"
    )

    if [[ "$status" == "__INVALID_JSON__" ]]; then
        echo "The service returned a non-JSON response while polling:" >&2
        echo "$result_response" >&2
        exit 1
    fi

    if [[ "$status" != "PENDING" ]]; then
        break
    fi

    echo "status:  PENDING" >&2
    sleep "$poll_interval"
done

python3 -c '
import json
import pathlib
import sys

raw = sys.stdin.read()
try:
    data = json.loads(raw)
except json.JSONDecodeError:
    print("The final service response was not valid JSON:", file=sys.stderr)
    print(raw, file=sys.stderr)
    sys.exit(1)

output_path = pathlib.Path(sys.argv[1])
response_path = output_path.with_suffix(output_path.suffix + ".json") if output_path.suffix else pathlib.Path(str(output_path) + ".json")
response_path.write_text(json.dumps(data, indent=2))

result = data.get("result", {})
if not isinstance(result, dict):
    print("The service did not return a normal result object:", file=sys.stderr)
    print(json.dumps(data, indent=2), file=sys.stderr)
    sys.exit(1)

plan = result.get("output")

if isinstance(plan, dict):
    if plan:
        plan = "\n\n".join(str(value) for value in plan.values())
    else:
        plan = ""
elif plan is None:
    plan = result.get("stdout", "")

output_path.write_text(str(plan))

stderr = result.get("stderr")
if stderr:
    print(stderr, file=sys.stderr)

print(f"Saved plan to {output_path}", file=sys.stderr)
print(f"Saved full response to {response_path}", file=sys.stderr)
' "$output_file" <<< "$result_response"
