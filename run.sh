#!/bin/bash

# Black Box Challenge - Example implementation with logging
# Usage: ./run.sh <trip_duration_days> <miles_traveled> <total_receipts_amount>

# Ensure exactly three parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <trip_duration_days> <miles_traveled> <total_receipts_amount>" >&2
    exit 1
fi

trip_duration="$1"
miles_traveled="$2"
receipts_amount="$3"

# <assumption>Placeholder reimbursement logic; replace with real model.</assumption>
result=$(echo "scale=2; $trip_duration * 100 + $miles_traveled * 0.5 + $receipts_amount" | bc)

# <assumption>Log each invocation for per-agent history.</assumption>
agent="${AGENT_NAME:-default_agent}"
log_dir="history/${agent}"
mkdir -p "$log_dir"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
printf "%s,%s,%s,%s,%s\n" "$timestamp" "$trip_duration" "$miles_traveled" "$receipts_amount" "$result" >> "$log_dir/run_history.csv"

# Output the reimbursement amount
printf "%s\n" "$result"
