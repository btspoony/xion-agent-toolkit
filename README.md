# Xion Agent Toolkit

A CLI-driven, Agent-oriented toolkit for developing on the Xion blockchain.

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Test Coverage](https://img.shields.io/badge/tests-330%20passing-green)]()
[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)

## Overview

Xion Agent Toolkit provides a command-line interface for interacting with Xion's MetaAccount system, enabling gasless transactions and automated Treasury management through OAuth2 authentication.

## Current Status

### ✅ Implemented Features

#### Authentication (Phase 2 - Complete)
- ✅ **OAuth2 Login Flow** - Browser-based authentication with PKCE security
- ✅ **Token Management** - Auto-refresh, encrypted file storage
- ✅ **Multi-Network Support** - Local, testnet, and mainnet
- ✅ **Session Persistence** - Per-network credential storage

#### Treasury Management (Phase 3 - Complete)
- ✅ **List Treasuries** - View all Treasury contracts for authenticated user
- ✅ **Query Treasury** - Get detailed Treasury information (balance, grants, configs)
- ✅ **Fund Treasury** - Deposit funds into a Treasury contract
- ✅ **Withdraw Treasury** - Withdraw funds from a Treasury contract
- ✅ **Grant Configuration** - Configure Fee Grants and Authz Grants
- ✅ **Fee Configuration** - Basic, Periodic, and AllowedMsg allowances
- ✅ **Protobuf Encoding** - Full support for Fee and Authz protobuf encoding
- ✅ **JSON Output** - Agent-friendly structured output

#### Agent Skills (Phase 4 - Complete)
- ✅ **xion-oauth2** - OAuth2 authentication skill
- ✅ **xion-treasury** - Treasury management skill

#### Infrastructure (Phase 1 - Complete)
- ✅ **CLI Framework** - Built with clap for powerful command-line interface
- ✅ **Configuration System** - Layered config (compile-time + user + credentials)
- ✅ **Error Handling** - Structured errors with helpful suggestions
- ✅ **Network Management** - Easy switching between environments

### 🚧 Blocked Features

- ⏳ **Treasury Creation** - CLI implementation complete, waiting for OAuth2 API support for `MsgInstantiateContract2`

## Installation

### From Source

```bash
git clone https://github.com/burnt-labs/xion-agent-toolkit
cd xion-agent-toolkit
cargo install --path .
```

### Prerequisites

- Rust 1.75 or higher
- OpenSSL development libraries

## Quick Start

### 1. Check Status

```bash
xion-toolkit status
```

Output:
```json
{
  "authenticated": false,
  "callback_port": 54321,
  "chain_id": "xion-testnet-2",
  "network": "testnet",
  "oauth_api_url": "https://oauth2.testnet.burnt.com"
}
```

### 2. Configure OAuth Client IDs

Create `.env` file in the project root:

```bash
cp .env.example .env
# Edit .env and add your OAuth Client IDs
```

Required variables:
- `XION_LOCAL_OAUTH_CLIENT_ID`
- `XION_TESTNET_OAUTH_CLIENT_ID`
- `XION_MAINNET_OAUTH_CLIENT_ID`

### 3. Login

```bash
xion-toolkit auth login
```

This will:
- Generate a PKCE challenge for security
- Start a localhost callback server (port 54321)
- Open your browser for OAuth2 authorization
- Save tokens securely in encrypted files
- Return JSON with authentication details

Output:
```json
{
  "success": true,
  "network": "testnet",
  "xion_address": "xion1...",
  "expires_at": "2024-01-01T01:00:00Z"
}
```

### 4. List Treasuries

```bash
xion-toolkit treasury list
```

Output:
```json
{
  "success": true,
  "treasuries": [
    {
      "address": "xion1abc123...",
      "admin": "xion1admin...",
      "params": {
        "display_url": "https://myapp.com",
        "redirect_url": "https://myapp.com/callback",
        "icon_url": "https://myapp.com/icon.png"
      }
    }
  ],
  "count": 1
}
```

### 5. Query Treasury Details

```bash
xion-toolkit treasury query xion1abc123...
```

Output:
```json
{
  "success": true,
  "treasury": {
    "address": "xion1abc123...",
    "admin": "xion1admin...",
    "balance": "1000000",
    "params": {
      "display_url": "https://myapp.com",
      "redirect_url": "https://myapp.com/callback",
      "icon_url": "https://myapp.com/icon.png"
    },
    "fee_config": { ... },
    "grant_configs": [ ... ]
  }
}
```

### 6. Fund a Treasury

```bash
xion-toolkit treasury fund xion1abc123... --amount 1000000
```

Output:
```json
{
  "success": true,
  "treasury_address": "xion1abc123...",
  "amount": "1000000uxion",
  "tx_hash": "ABC123...",
  "new_balance": "2000000"
}
```

### 7. Withdraw from a Treasury

```bash
xion-toolkit treasury withdraw xion1abc123... --amount 500000 --to xion1recipient...
```

Output:
```json
{
  "success": true,
  "treasury_address": "xion1abc123...",
  "amount": "500000uxion",
  "recipient": "xion1recipient...",
  "tx_hash": "DEF456...",
  "remaining_balance": "1500000"
}
```

### 8. Configure Grants for a Treasury

```bash
xion-toolkit treasury grant-config xion1abc123... \
  --grant-type-url "/cosmos.bank.v1beta1.MsgSend" \
  --grant-auth-type send \
  --grant-spend-limit "1000000uxion" \
  --grant-description "Allow sending funds"
```

Output:
```json
{
  "success": true,
  "treasury_address": "xion1abc123...",
  "grant_config": {
    "type_url": "/cosmos.bank.v1beta1.MsgSend",
    "description": "Allow sending funds",
    "authorization": { ... }
  },
  "tx_hash": "GHI789..."
}
```

### 9. Configure Fee Grant for a Treasury

```bash
xion-toolkit treasury fee-config xion1abc123... \
  --fee-allowance-type basic \
  --fee-spend-limit "5000000uxion" \
  --fee-description "Basic fee allowance"
```

Output:
```json
{
  "success": true,
  "treasury_address": "xion1abc123...",
  "fee_config": {
    "description": "Basic fee allowance",
    "allowance_type": "basic",
    "spend_limit": "5000000uxion"
  },
  "tx_hash": "JKL012..."
}
```

### 10. Check Authentication Status

```bash
xion-toolkit auth status
```

Output (authenticated):
```json
{
  "authenticated": true,
  "chain_id": "xion-testnet-2",
  "network": "testnet",
  "oauth_api_url": "https://oauth2.testnet.burnt.com",
  "xion_address": "xion1...",
  "expires_at": "2024-01-01T01:00:00Z"
}
```

### 11. Logout

```bash
xion-toolkit auth logout
```

Output:
```json
{
  "success": true,
  "message": "Logged out successfully",
  "network": "testnet"
}
```

## CLI Commands

### Authentication Commands

```bash
xion-toolkit auth login [--port <PORT>]   # OAuth2 login (default port: 54321)
xion-toolkit auth logout                  # Clear credentials
xion-toolkit auth status                  # Check authentication status
xion-toolkit auth refresh                 # Refresh access token
```

### Treasury Commands

```bash
xion-toolkit treasury list                       # List all treasuries
xion-toolkit treasury query <address>            # Query treasury details
xion-toolkit treasury fund <address> --amount N  # Fund treasury
xion-toolkit treasury withdraw <address> --amount N --to <addr>  # Withdraw from treasury
xion-toolkit treasury grant-config <address> [options]  # Configure authz grants
xion-toolkit treasury fee-config <address> [options]    # Configure fee grants

# Treasury creation (CLI ready, waiting for API support)
xion-toolkit treasury create [options]           # Create new treasury
```

### Configuration Commands

```bash
xion-toolkit config show                  # Show current config
xion-toolkit config set-network <network> # Switch network (local/testnet/mainnet)
xion-toolkit config get <key>             # Get config value
xion-toolkit config reset                 # Reset to defaults
```

### Utility Commands

```bash
xion-toolkit status                       # Show current network and auth status
xion-toolkit --help                       # Show help
xion-toolkit --version                    # Show version
```

## Network Configuration

### Supported Networks

| Network | OAuth API | RPC | Chain ID | Status |
|---------|-----------|-----|----------|--------|
| local | http://localhost:8787 | http://localhost:26657 | xion-local | ✅ Active |
| testnet | https://oauth2.testnet.burnt.com | https://rpc.xion-testnet-2.burnt.com:443 | xion-testnet-2 | ✅ Active |
| mainnet | https://oauth2.burnt.com | https://rpc.xion-mainnet-1.burnt.com:443 | xion-mainnet-1 | ✅ Active |

### Switch Networks

```bash
# Switch to local development
xion-toolkit config set-network local

# Switch to testnet (default)
xion-toolkit config set-network testnet

# Switch to mainnet
xion-toolkit config set-network mainnet

# Or use global flag
xion-toolkit --network local status
xion-toolkit --network testnet auth login
xion-toolkit --network mainnet treasury list
```

## Configuration Architecture

### Layered Configuration System

```
┌─────────────────────────────────────────┐
│  1. Network Config (Compile-time)       │
│  - OAuth Client IDs                     │
│  - Treasury Code IDs                    │
│  - API endpoints                        │
│  - Generated by build.rs                │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│  2. User Config (~/.xion-toolkit/)      │
│  - config.json (active network)         │
│  - Per-user settings                    │
└─────────────────────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│  3. Credentials (Encrypted)             │
│  - AES-256-GCM encrypted files          │
│  - Per-network storage                  │
│  - credentials/{network}.enc            │
└─────────────────────────────────────────┘
```

### Configuration Files

**User Config** (`~/.xion-toolkit/config.json`):
```json
{
  "version": "1.0",
  "network": "testnet"
}
```

**Credentials** (`~/.xion-toolkit/credentials/{network}.enc`):
- AES-256-GCM encrypted JSON files
- Per-network storage
- Key derived from machine ID or `XION_TOOLKIT_KEY` env var

## Security Features

### Authentication Security
- ✅ **PKCE (RFC 7636)** - Prevents authorization code interception
- ✅ **State Parameter** - CSRF protection
- ✅ **Localhost Only** - Callback server only accepts localhost connections
- ✅ **Encrypted Storage** - Tokens encrypted with AES-256-GCM
- ✅ **Auto Token Refresh** - Seamless session management

### Treasury Security
- ✅ **Bearer Token Auth** - All Treasury API calls authenticated
- ✅ **Per-Network Credentials** - Isolated credentials per network
- ✅ **Smart Caching** - Reduces API calls with TTL expiration

### Communication Security
- ✅ **HTTPS Only** - All external communications over HTTPS
- ✅ **Certificate Validation** - Server certificates validated
- ✅ **Request Timeout** - Prevents hanging requests
- ✅ **No Sensitive Logging** - Tokens and secrets never logged

## Project Architecture

```
xion-agent-toolkit/
├── src/
│   ├── main.rs              # CLI entry point
│   ├── lib.rs               # Library exports
│   ├── cli/                 # CLI command handlers
│   │   ├── auth.rs          # Authentication commands
│   │   ├── treasury.rs      # Treasury commands
│   │   └── config.rs        # Configuration commands
│   ├── oauth/               # OAuth2 implementation
│   │   ├── pkce.rs          # PKCE implementation
│   │   ├── client.rs        # OAuth2 client
│   │   ├── callback_server.rs  # Localhost callback
│   │   └── token_manager.rs   # Token lifecycle
│   ├── api/                 # API clients
│   │   ├── oauth2_api.rs    # OAuth2 API client
│   │   └── treasury.rs      # Treasury API client
│   ├── treasury/            # Treasury management
│   │   ├── types.rs         # Data structures
│   │   ├── manager.rs       # High-level manager
│   │   ├── encoding.rs      # Protobuf encoding
│   │   └── cache.rs         # Caching system
│   ├── config/              # Configuration
│   │   ├── constants.rs     # Network config (auto-generated)
│   │   ├── credentials.rs   # Credential management
│   │   └── manager.rs       # Config manager
│   └── utils/               # Utilities
│       ├── error.rs         # Error definitions
│       └── output.rs        # Output formatting
├── skills/                  # Agent Skills
│   ├── xion-oauth2/         # OAuth2 authentication skill
│   │   ├── SKILL.md
│   │   └── scripts/
│   └── xion-treasury/       # Treasury management skill
│       ├── SKILL.md
│       └── scripts/
├── plans/                   # Development plans
│   ├── treasury-automation.md
│   ├── oauth2-client-architecture.md
│   ├── treasury-api-architecture.md
│   ├── treasury-create-enhancement.md
│   └── treasury-grant-fee-config.md
├── .env.example             # Environment variables template
├── build.rs                 # Compile-time config generation
└── Cargo.toml               # Rust dependencies
```

## Development

### Building

```bash
cargo build
```

### Testing

```bash
cargo test
```

Current test status: ✅ **330 tests passing**

### CI/CD Testing

In CI environments, set the `XION_CI_ENCRYPTION_KEY` environment variable for credential encryption:

```bash
export XION_CI_ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
cargo test
```

**Note**: Local development does NOT require this variable - it automatically uses machine ID for key derivation.

### Running in Development

```bash
cargo run -- [commands]
```

### Code Quality

```bash
cargo clippy        # Linting
cargo fmt           # Formatting
cargo test          # Run tests
```

## Dependencies

### Core Dependencies
- `clap` - CLI framework
- `tokio` - Async runtime
- `reqwest` - HTTP client
- `serde` / `serde_json` - Serialization
- `thiserror` / `anyhow` - Error handling

### Security Dependencies
- `aes-gcm` - AES-256-GCM encryption for credential storage
- `machine-uid` - Machine ID for key derivation
- `sha2` / `base64` / `rand` - PKCE and encryption utilities
- `hex` - Hex encoding

### Web Dependencies
- `axum` / `tower` - Callback server
- `open` - Browser launching
- `urlencoding` - URL encoding

### Utilities
- `chrono` - Date/time handling
- `tracing` - Structured logging
- `directories` - Cross-platform directories

## Roadmap

### ✅ Phase 1: Foundation (Complete)
- Project structure
- CLI framework
- Configuration system
- Error handling

### ✅ Phase 2: OAuth2 Authentication (Complete)
- PKCE implementation
- OAuth2 client
- Token management
- Callback server
- CLI integration

### ✅ Phase 3: Treasury Management (Complete)
- Treasury API client
- Treasury manager
- List and query commands
- Fund and withdraw operations
- Grant configuration management
- Fee configuration management
- Caching system

### ✅ Phase 4: Agent Skills (Complete)
- xion-oauth2 skill
- xion-treasury skill
- Documentation and examples

### 🚧 Phase 5: Treasury Creation (Blocked)
- Treasury create command (CLI ready)
- Waiting for OAuth2 API support for `MsgInstantiateContract2`

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `cargo test`
5. Format code: `cargo fmt`
6. Submit a pull request

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Resources

- [Xion Documentation](https://docs.burnt.com/xion)
- [OAuth2 API Service](https://github.com/burnt-labs/xion/tree/main/oauth2-api-service)
- [Developer Portal](https://dev.testnet2.burnt.com)
- [Agent Skills Format](https://agentskills.io/)

## Support

- GitHub Issues: [Project Issues Page](https://github.com/burnt-labs/xion-agent-toolkit/issues)
- Documentation: See `plans/` directory for detailed architecture and implementation docs
