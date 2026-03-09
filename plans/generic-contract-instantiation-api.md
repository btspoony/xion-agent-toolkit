---
status: Todo
created_at: 2026-03-09
updated_at: 2026-03-09
---

# Generic Contract Instantiation Public API

## Background

The `broadcast_instantiate_contract` and `broadcast_instantiate_contract2` methods are currently private. Users cannot instantiate arbitrary CosmWasm contracts - they can only create Treasury contracts.

## Goal

1. Expose generic contract instantiation as public API in `TreasuryManager`
2. Add CLI commands for `xion-toolkit contract instantiate` and `xion-toolkit contract instantiate2`
3. Allow users to instantiate any CosmWasm contract, not just Treasury

## Approach

1. Add public methods to `TreasuryManager`:
   - `instantiate_contract<T: Serialize>()` - generic v1 instantiation
   - `instantiate_contract2<T: Serialize>()` - generic v2 instantiation with predictable address

2. Add CLI commands:
   - `xion-toolkit contract instantiate --code-id <ID> --msg <JSON> --label <LABEL>`
   - `xion-toolkit contract instantiate2 --code-id <ID> --msg <JSON> --label <LABEL> --salt <HEX>`

3. Support both raw JSON and file input for `--msg`

## Tasks

- [ ] Add `instantiate_contract` method to `TreasuryManager`
- [ ] Add `instantiate_contract2` method to `TreasuryManager`
- [ ] Add `contract` CLI subcommand group
- [ ] Add `contract instantiate` CLI command
- [ ] Add `contract instantiate2` CLI command
- [ ] Add unit tests for new methods
- [ ] Add integration tests for CLI commands
- [ ] Update documentation

## Acceptance Criteria

- [ ] Users can instantiate any CosmWasm contract via CLI
- [ ] Both v1 (dynamic address) and v2 (predictable address) supported
- [ ] Contract address returned in JSON output
- [ ] All tests pass

## Sign-off

> Only @qa-engineer or @project-manager may sign off completion.

| Date | Signer | Content | Status |
|------|--------|---------|--------|
