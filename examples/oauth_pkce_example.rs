// OAuth2 PKCE Usage Example
//
// This example demonstrates how to use the PKCE module for OAuth2 authorization

use xion_agent_cli::oauth::{
    generate_pkce_challenge, generate_pkce_verifier, generate_state, PKCEChallenge,
};

fn main() {
    println!("=== OAuth2 PKCE Example ===\n");

    // Example 1: Generate complete PKCE challenge
    println!("1. Generate complete PKCE challenge:");
    match PKCEChallenge::generate() {
        Ok(pkce) => {
            println!("   Verifier:  {}", pkce.verifier);
            println!("   Challenge: {}", pkce.challenge);
            println!("   State:     {}", pkce.state);
            println!();

            // Example 3: Verify state
            println!("3. Verify state parameter:");
            let test_state = &pkce.state;
            match pkce.verify_state(test_state) {
                Ok(()) => println!("   ✓ State verified successfully"),
                Err(e) => println!("   ✗ Verification failed: {}", e),
            }

            // Try with invalid state
            match pkce.verify_state("invalid_state") {
                Ok(()) => println!("   ✗ Should have failed"),
                Err(e) => println!("   ✓ Correctly rejected invalid state: {}", e),
            }
        }
        Err(e) => eprintln!("Error generating PKCE challenge: {}", e),
    }

    println!();

    // Example 2: Generate individual components
    println!("2. Generate individual components:");
    match generate_pkce_verifier() {
        Ok(verifier) => {
            println!("   Verifier: {}", verifier);
            match generate_pkce_challenge(&verifier) {
                Ok(challenge) => println!("   Challenge: {}", challenge),
                Err(e) => eprintln!("   Error generating challenge: {}", e),
            }
        }
        Err(e) => eprintln!("   Error generating verifier: {}", e),
    }

    match generate_state() {
        Ok(state) => println!("   State: {}", state),
        Err(e) => eprintln!("   Error generating state: {}", e),
    }

    println!();

    // Example 4: OAuth2 authorization URL construction
    println!("4. OAuth2 authorization URL example:");
    match PKCEChallenge::generate() {
        Ok(pkce) => {
            let auth_url = format!(
                "https://oauth.example.com/authorize?\
                 response_type=code&\
                 client_id=your_client_id&\
                 redirect_uri=http://localhost:8080/callback&\
                 code_challenge={}&\
                 code_challenge_method=S256&\
                 state={}",
                pkce.challenge, pkce.state
            );
            println!("   Authorization URL:");
            println!("   {}", auth_url);
            println!();
            println!("   Store these for token exchange:");
            println!("   - code_verifier: {}", pkce.verifier);
            println!("   - state: {}", pkce.state);
        }
        Err(e) => eprintln!("   Error: {}", e),
    }
}
