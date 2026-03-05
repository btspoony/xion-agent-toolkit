#!/bin/bash
#
# xion-treasury/grant-config.sh - Configure Authz Grants (Coming Soon)
#
# This script will configure Authz Grants for a Treasury.
# Currently not implemented.
#
# Usage:
#   ./grant-config.sh <ADDRESS> --config <CONFIG_FILE> [--network NETWORK]
#
# Output:
#   JSON to stdout with feature status

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

# ==============================================================================
# Main Logic
# ==============================================================================

log_info "Grant configuration requested..."

# Return feature not available message with example config
output_json '{
  "success": false,
  "error": "Grant configuration is not yet implemented in the CLI",
  "error_code": "FEATURE_NOT_AVAILABLE",
  "alternatives": [
    {
      "method": "Developer Portal",
      "url": "https://dev.testnet2.burnt.com",
      "description": "Configure grants through the web interface"
    }
  ],
  "example_config": {
    "type_url": "/cosmwasm.wasm.v1.MsgExecuteContract",
    "authorization": {
      "type": "ContractExecutionAuthorization",
      "contract": "xion1...",
      "limits": {
        "max_calls": 100,
        "max_funds": [
          {
            "denom": "uxion",
            "amount": "10000000"
          }
        ]
      }
    }
  },
  "planned_features": [
    "Configure Authz Grants for specific message types",
    "Set execution limits (max calls, max funds)",
    "Grant contract execution permissions",
    "Revoke existing grants"
  ]
}'

exit 0
