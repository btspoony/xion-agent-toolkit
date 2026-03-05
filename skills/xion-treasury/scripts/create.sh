#!/bin/bash
#
# xion-treasury/create.sh - Create a new Treasury contract (Coming Soon)
#
# This script will create a new Treasury contract.
# Currently not implemented - use Developer Portal instead.
#
# Usage:
#   ./create.sh [--network NETWORK] [--fee-grant CONFIG] [--grant-config CONFIG]
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

log_info "Treasury creation requested..."

# Return feature not available message
output_json '{
  "success": false,
  "error": "Treasury creation is not yet implemented in the CLI",
  "error_code": "FEATURE_NOT_AVAILABLE",
  "alternatives": [
    {
      "method": "Developer Portal",
      "url": "https://dev.testnet2.burnt.com",
      "description": "Create treasuries through the web interface"
    }
  ],
  "planned_features": [
    "Create Treasury with custom configuration",
    "Set initial Fee Grant allowance",
    "Configure Authz Grants",
    "Set admin address"
  ],
  "tracking": "See plans/treasury-automation.md for implementation timeline"
}'

exit 0
