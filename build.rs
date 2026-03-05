use std::env;
use std::fs;
use std::path::Path;

fn main() {
    // Load .env file if it exists
    dotenvy::dotenv().ok();

    // Read OAuth2 client IDs from environment variables
    let local_client_id = env::var("XION_LOCAL_OAUTH_CLIENT_ID")
        .unwrap_or_else(|_| "PLACEHOLDER_LOCAL_CLIENT_ID".to_string());

    let testnet_client_id = env::var("XION_TESTNET_OAUTH_CLIENT_ID")
        .unwrap_or_else(|_| "PLACEHOLDER_TESTNET_CLIENT_ID".to_string());

    let mainnet_client_id = env::var("XION_MAINNET_OAUTH_CLIENT_ID")
        .unwrap_or_else(|_| "PLACEHOLDER_MAINNET_CLIENT_ID".to_string());

    // Generate network_config.rs
    let out_dir = env::var("OUT_DIR").unwrap();
    let dest_path = Path::new(&out_dir).join("network_config.rs");

    let config_content = format!(
        r#"// Auto-generated network configuration
// This file is generated at compile time from environment variables

use serde::{{Deserialize, Serialize}};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NetworkConfig {{
    pub oauth_api_url: String,
    pub rpc_url: String,
    pub chain_id: String,
    pub oauth_client_id: String,
    pub treasury_code_id: Option<u64>,
    pub treasury_config: Option<String>,
    pub callback_port: u16,
}}

pub fn get_local_config() -> NetworkConfig {{
    NetworkConfig {{
        oauth_api_url: "http://localhost:8787".to_string(),
        rpc_url: "http://localhost:26657".to_string(),
        chain_id: "xion-local".to_string(),
        oauth_client_id: "{}".to_string(),
        treasury_code_id: None,
        treasury_config: None,
        callback_port: 54321,
    }}
}}

pub fn get_testnet_config() -> NetworkConfig {{
    NetworkConfig {{
        oauth_api_url: "https://oauth2.testnet.burnt.com".to_string(),
        rpc_url: "https://rpc.xion-testnet-2.burnt.com:443".to_string(),
        chain_id: "xion-testnet-2".to_string(),
        oauth_client_id: "{}".to_string(),
        treasury_code_id: Some(1260),
        treasury_config: Some("xion175qd54keur7gkuwtctfupgtucvlvkrxhv0pgq753sfh5xueputvsms6nll".to_string()),
        callback_port: 54321,
    }}
}}

pub fn get_mainnet_config() -> NetworkConfig {{
    NetworkConfig {{
        oauth_api_url: "https://oauth2.burnt.com".to_string(),
        rpc_url: "https://rpc.xion-mainnet-1.burnt.com:443".to_string(),
        chain_id: "xion-mainnet-1".to_string(),
        oauth_client_id: "{}".to_string(),
        treasury_code_id: Some(63),
        treasury_config: Some("xion1dlsvvgey26ernlj0sq2afjluh3qd4ap0k9eerekfkw5algqrwqkshmn3uq".to_string()),
        callback_port: 54321,
    }}
}}
"#,
        local_client_id, testnet_client_id, mainnet_client_id
    );

    fs::write(&dest_path, config_content).unwrap();

    println!("cargo:rerun-if-env-changed=XION_LOCAL_OAUTH_CLIENT_ID");
    println!("cargo:rerun-if-env-changed=XION_TESTNET_OAUTH_CLIENT_ID");
    println!("cargo:rerun-if-env-changed=XION_MAINNET_OAUTH_CLIENT_ID");
    println!("cargo:rerun-if-changed=.env");
    println!("cargo:rerun-if-changed=build.rs");
}
