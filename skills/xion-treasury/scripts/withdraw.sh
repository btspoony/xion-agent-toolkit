#!/bin/bash
#
# xion-treasury/withdraw.sh - Withdraw from Treasury
#
# This script withdraws funds from a Treasury contract to the admin account.
#
# Usage:
#   ./withdraw.sh <ADDRESS> <AMOUNT> [--network NETWORK]
#
# Arguments:
#   ADDRESS  - Treasury contract address (required)
#   AMOUNT   - Amount to withdraw with denomination (required, e.g., "1000000uxion")
#
# Options:
#   --network NETWORK - Network to use: local, testnet, mainnet (default: testnet)
#
# Output:
#   JSON to stdout with success status and transaction details
#
# Examples:
#   ./withdraw.sh xion1abc... 1000000uxion
#   ./withdraw.sh xion1abc... 5000000uxion --network testnet

set -e

# ==============================================================================
# Helper Functions
# ==============================================================================

output_json() {
    echo "$1"
}

log_info() {
    echo "[INFO] $1" >&2
}

log_error() {
    echo "[ERROR] $1" >&2
}

# ==============================================================================
# Argument Parsing
# ==============================================================================

ADDRESS=""
AMOUNT=""
NETWORK="testnet"

while [[ $# -gt 0 ]]; do
    case $1 in
        --network)
            NETWORK="$2"
            shift 2
            ;;
        -*)
            output_json "{
  \"success\": false,
  \"error\": \"Unknown option: $1\",
  \"error_code\": \"INVALID_ARGUMENT\"
}"
            exit 1
            ;;
        *)
            if [[ -z "$ADDRESS" ]]; then
                ADDRESS="$1"
            elif [[ -z "$AMOUNT" ]]; then
                AMOUNT="$1"
            else
                output_json "{
  \"success\": false,
  \"error\": \"Too many arguments\",
  \"error_code\": \"INVALID_ARGUMENT\"
}"
                exit 1
            fi
            shift
            ;;
    esac
done

# ==============================================================================
# Validation
# ==============================================================================

if [[ -z "$ADDRESS" ]]; then
    output_json '{
  "success": false,
  "error": "Treasury address is required",
  "error_code": "MISSING_ADDRESS",
  "usage": "./withdraw.sh <ADDRESS> <AMOUNT> [--network NETWORK]"
}'
    exit 1
fi

if [[ -z "$AMOUNT" ]]; then
    output_json '{
  "success": false,
  "error": "Amount is required",
  "error_code": "MISSING_AMOUNT",
  "usage": "./withdraw.sh <ADDRESS> <AMOUNT> [--network NETWORK]",
  "example": "1000000uxion"
}'
    exit 1
fi

# ==============================================================================
# Main Logic
# ==============================================================================

log_info "Withdrawing $AMOUNT from treasury $ADDRESS on $NETWORK..."

# Check if xion CLI is available
if ! command -v xion &> /dev/null; then
    # Try to use cargo run instead
    CLI_CMD="cargo run --quiet --"
else
    CLI_CMD="xion"
fi

# Execute the withdraw command
RESULT=$($CLI_CMD treasury withdraw "$ADDRESS" --amount "$AMOUNT" --network "$NETWORK" --output json 2>&1)
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    log_info "Withdrawal successful"
    output_json "$RESULT"
else
    log_error "Failed to withdraw from treasury"
    # Parse error if possible, otherwise return raw output
    if echo "$RESULT" | jq -e . > /dev/null 2>&1; then
        output_json "$RESULT"
    else
        output_json "{
  \"success\": false,
  \"error\": $(echo "$RESULT" | jq -Rs .),
  \"error_code\": \"WITHDRAW_FAILED\"
}"
    fi
    exit 1
fi
