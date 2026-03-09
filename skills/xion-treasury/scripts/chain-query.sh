#!/bin/bash
#
# xion-treasury/chain-query.sh - On-chain query operations
#
# This script queries on-chain data for Treasury contracts (authz grants, fee allowances).
#
# Usage:
#   ./chain-query.sh <address> grants [--network NETWORK]
#   ./chain-query.sh <address> allowances [--network NETWORK]
#
# Arguments:
#   ADDRESS  - Treasury contract address (required)
#   QUERY    - Query type: grants, allowances (required)
#
# Options:
#   --network <NETWORK>  - Network: local, testnet, mainnet (default: testnet)
#
# Output:
#   JSON to stdout with query results
#
# Examples:
#   ./chain-query.sh xion1abc... grants
#   ./chain-query.sh xion1abc... allowances --network mainnet

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

show_usage() {
    cat << 'EOF' >&2
Usage: chain-query.sh <ADDRESS> <QUERY> [options]

Query Types:
  grants      List authz grants for a treasury
  allowances  List fee allowances for a treasury

Options:
  --network <NETWORK>  Network: local, testnet, mainnet (default: testnet)

Examples:
  # Query authz grants
  chain-query.sh xion1abc... grants

  # Query fee allowances
  chain-query.sh xion1abc... allowances

  # Specify network
  chain-query.sh xion1abc... grants --network mainnet

Output Examples:

Authz Grants:
  {
    "success": true,
    "treasury_address": "xion1abc...",
    "grants": [
      {
        "grantee": "xion1grantee...",
        "authorization": {
          "type": "cosmos.bank.v1beta1.SendAuthorization",
          "value": { "spend_limit": [{"denom": "uxion", "amount": "1000000"}] }
        },
        "expiration": "2025-01-01T00:00:00Z"
      }
    ],
    "count": 1
  }

Fee Allowances:
  {
    "success": true,
    "treasury_address": "xion1abc...",
    "allowances": [
      {
        "grantee": "xion1grantee...",
        "allowance": {
          "type": "cosmos.feegrant.v1beta1.BasicAllowance",
          "value": { "spend_limit": [{"denom": "uxion", "amount": "5000000"}] }
        }
      }
    ],
    "count": 1
  }
EOF
}

# ==============================================================================
# Argument Parsing
# ==============================================================================

ADDRESS=""
QUERY=""
NETWORK="testnet"

while [[ $# -gt 0 ]]; do
    case $1 in
        grants|allowances)
            QUERY="$1"
            shift
            ;;
        --network)
            NETWORK="$2"
            shift 2
            ;;
        --help|-h)
            show_usage
            exit 0
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
  "usage": "./chain-query.sh <ADDRESS> <QUERY> [options]"
}'
    exit 1
fi

if [[ -z "$QUERY" ]]; then
    output_json '{
  "success": false,
  "error": "Query type is required (grants, allowances)",
  "error_code": "MISSING_QUERY_TYPE",
  "usage": "./chain-query.sh <ADDRESS> <QUERY> [options]"
}'
    exit 1
fi

# ==============================================================================
# Check CLI
# ==============================================================================

if ! command -v xion-toolkit &> /dev/null; then
    CLI_CMD="cargo run --quiet --"
else
    CLI_CMD="xion-toolkit"
fi

# ==============================================================================
# Main Logic
# ==============================================================================

log_info "Querying '$QUERY' for treasury $ADDRESS on $NETWORK..."

# Execute query
RESULT=$($CLI_CMD treasury chain-query "$QUERY" "$ADDRESS" --network "$NETWORK" --output json 2>&1)
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    log_info "Query completed successfully"
    output_json "$RESULT"
else
    log_error "Query failed"
    if echo "$RESULT" | jq -e . > /dev/null 2>&1; then
        output_json "$RESULT"
    else
        output_json "{
  \"success\": false,
  \"error\": $(echo "$RESULT" | jq -Rs .),
  \"error_code\": \"QUERY_FAILED\"
}"
    fi
    exit 1
fi
