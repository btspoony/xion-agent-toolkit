---
status: Todo
created_at: 2026-03-09
updated_at: 2026-03-09
---

# Contract Instantiate Refactor

## Background

The `instantiate` and `instantiate2` commands are currently under `treasury` subcommand, but they are generic contract instantiation commands that should be at the `contract` level. This is a structural issue that needs to be fixed.

**Current (wrong)**:
```bash
xion-toolkit treasury instantiate ...
xion-toolkit treasury instantiate2 ...
```

**Expected (correct)**:
```bash
xion-toolkit contract instantiate ...
xion-toolkit contract instantiate2 ...
```

## Goal

1. Create new `contract` subcommand module
2. Move `instantiate` and `instantiate2` from `treasury` to `contract`
3. Update documentation to reflect the change
4. Deprecate old commands with warning (optional, for backward compatibility)

## Approach

### 1. Create Contract CLI Module

Create `src/cli/contract.rs`:
```rust
// Contract subcommand
pub enum ContractCommands {
    /// Instantiate a new contract
    Instantiate { ... },
    /// Instantiate a contract with predictable address (instantiate2)
    Instantiate2 { ... },
}
```

### 2. Update CLI Module

Modify `src/cli/mod.rs`:
```rust
pub mod contract;  // Add new module

pub enum Commands {
    Auth(...),
    Treasury(...),
    Config(...),
    Contract(contract::ContractCommands),  // Add new subcommand
    Status,
}
```

### 3. Move Handlers

- Move `handle_instantiate` and `handle_instantiate2` from `treasury.rs` to `contract.rs`
- Update imports and dependencies

### 4. Update Documentation

- README.md: Change `treasury instantiate` → `contract instantiate`
- docs/cli-reference.md: Add new Contract section, update Treasury section
- skills/xion-treasury/SKILL.md: Remove instantiate references (or note they're in contract skill)

## Tasks

### Code Changes
- [ ] Create `src/cli/contract.rs` module
- [ ] Define `ContractCommands` enum with Instantiate and Instantiate2
- [ ] Move handler functions from treasury to contract
- [ ] Update `src/cli/mod.rs` to include contract module
- [ ] Update `src/main.rs` to handle contract commands

### Documentation Updates
- [ ] Update README.md CLI examples
- [ ] Update docs/cli-reference.md
- [ ] Update skills/xion-treasury/SKILL.md

### Testing
- [ ] Verify `contract instantiate` works
- [ ] Verify `contract instantiate2` works
- [ ] Run all existing tests
- [ ] Verify clippy passes

## Acceptance Criteria

- [ ] `xion-toolkit contract instantiate` works
- [ ] `xion-toolkit contract instantiate2` works
- [ ] Old `treasury instantiate` returns error or deprecation warning
- [ ] Documentation updated
- [ ] All tests pass

## Sign-off

> Only @qa-engineer or @project-manager may sign off completion.

| Date | Signer | Content | Status |
|------|--------|---------|--------|
