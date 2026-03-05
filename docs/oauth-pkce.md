# OAuth2 PKCE Module

## Overview

This module implements the PKCE (Proof Key for Code Exchange) extension for OAuth2, providing secure authorization code flow protection.

## Usage

### Generate PKCE Challenge

```rust
use xion_agent_toolkit::oauth::PKCEChallenge;

// Generate a new PKCE challenge
let pkce = PKCEChallenge::generate()?;

println!("Verifier: {}", pkce.verifier);
println!("Challenge: {}", pkce.challenge);
println!("State: {}", pkce.state);
```

### Verify State Parameter

```rust
// After OAuth callback, verify the state
let callback_state = "received_state_from_callback";

match pkce.verify_state(callback_state) {
    Ok(()) => println!("State verified successfully"),
    Err(PKCEError::StateMismatch) => eprintln!("State mismatch - possible CSRF attack"),
    _ => eprintln!("Other error"),
}
```

### Helper Functions

```rust
use xion_agent_toolkit::oauth::{generate_pkce_verifier, generate_pkce_challenge, generate_state};

// Generate individual components
let verifier = generate_pkce_verifier()?;
let challenge = generate_pkce_challenge(&verifier)?;
let state = generate_state()?;
```

## Implementation Details

### PKCE Challenge
- **Verifier**: 43 cryptographically random characters from [A-Z] [a-z] [0-9] - . _ ~
- **Challenge**: SHA-256 hash of verifier, Base64URL encoded without padding
- **State**: 32 random bytes, hex encoded (64 characters)

### Security Considerations

1. **Cryptographically Secure Random**: Uses `rand::thread_rng()` for all random generation
2. **PKCE Compliance**: Follows RFC 7636 specification
3. **State Parameter**: Prevents CSRF attacks in OAuth flow

## Test Results

All 12 unit tests pass:
- ✅ Verifier length and character validation
- ✅ Challenge determinism and uniqueness
- ✅ State length, encoding, and uniqueness
- ✅ PKCEChallenge generation and verification
- ✅ Base64URL encoding compliance

## Next Steps

1. Integrate with OAuth2 client module
2. Add token management
3. Implement callback server