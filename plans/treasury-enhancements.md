---
status: Todo
created_at: 2026-03-09
updated_at: 2026-03-09
---

# Treasury Enhancements

## Background

Current Treasury functionality covers basic operations (create, fund, withdraw, grant-config, fee-config). There are opportunities to enhance usability with batch operations and improved query capabilities.

## Goal

1. Add batch operations for grant-config and fee-config
2. Enhance query capabilities with more on-chain data

## Approach

### Batch Operations

1. `treasury grant-config-batch` - Configure multiple grants in one transaction
2. `treasury fee-config-batch` - Configure fee allowances for multiple grantees

### Query Enhancements

1. `treasury list-grants <address>` - List all authz grants for a treasury
2. `treasury list-allowances <address>` - List all fee allowances for a treasury
3. `treasury history <address>` - Transaction history for a treasury

## Tasks

### Batch Operations
- [ ] Add `grant_config_batch` method to `TreasuryApiClient`
- [ ] Add `fee_config_batch` method to `TreasuryApiClient`
- [ ] Add `treasury grant-config-batch` CLI command
- [ ] Add `treasury fee-config-batch` CLI command

### Query Enhancements
- [ ] Add `list_grants` method using on-chain query
- [ ] Add `list_allowances` method using on-chain query
- [ ] Add `treasury list-grants` CLI command
- [ ] Add `treasury list-allowances` CLI command
- [ ] Consider `treasury history` (depends on indexer availability)

### Testing
- [ ] Add unit tests for batch operations
- [ ] Add unit tests for query methods
- [ ] Add E2E tests for new CLI commands

## Acceptance Criteria

- [ ] Batch operations work with single transaction
- [ ] Query commands return structured JSON output
- [ ] All tests pass

## Sign-off

> Only @qa-engineer or @project-manager may sign off completion.

| Date | Signer | Content | Status |
|------|--------|---------|--------|
