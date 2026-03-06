#!/bin/bash
#
# xion-treasury/grant-config.sh - Configure Authz Grants for Treasury
#
# This script configures Authz Grants for a Treasury.
#

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
TYPE_URL=""
CONFIG_FILE=""
NETWORK="testnet"
ACTION=""

while [[ $# -gt 0 ]]; do
    case "$1"
        ADDRESS="$2"
        shift 2
        ;;
    --type-url)
        TYPE_URL="$2"
        shift 2
        ;;
    --config)
        CONFIG_FILE="$2"
        shift 2
        ;;
    --network)
        NETWORK="$2"
        shift 2
        ;;
    *)
        shift
        ;;
    --action)
        ACTION="$2"
        shift 2
        ;;
    *)
        log_error "Missing required arguments"
        output_json '{
            "success": false,
            "error": "Missing required arguments: --address, --type-url, --config, and --action",
            "error_code": "INVALID_ARGS"
        }'
        exit 1
        ;;
    esac
done

# ==============================================================================
# Main Logic
# ==============================================================================

case "$ACTION" in
    add | remove | list)
        ;;
    *)
        ;;
esac

log_info "Processing grant config: action=$ACTION for treasury $ADDRESS"

# Build the command
CMD="xion --network $NETWORK"

case "$ACTION" in
    add)
        CMD="$CMD treasury grant-config add --address $ADDRESS --config $CONFIG_FILE"
        ;;
    remove)
        CMD="$CMD treasury grant-config remove --address $ADDRESS --type-url $TYPE_URL"
        ;;
    list)
        CMD="$CMD treasury grant-config list --address $ADDRESS"
        ;;
esac

# Execute command and capture output
OUTPUT=$($CMD 2>&1)

# Check if successful
if [ $? -eq 0 ]; then
    output_json "$OUTPUT"
else
    log_error "Command failed with exit code $?"
    output_json "{
        \"success\": false,
        \"error": "Command failed with exit code $?",
        \"error_code": "COMMAND_FAILED"
    }'
    exit 1
fi
