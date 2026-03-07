use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    /// Current active network (testnet, mainnet)
    pub network: String,

    /// Version of the config schema
    pub version: String,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            network: "testnet".to_string(),
            version: "1.0".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserCredentials {
    /// User's access token
    pub access_token: String,

    /// User's refresh token
    pub refresh_token: String,

    /// Token expiration time (ISO 8601 format)
    pub expires_at: String,

    /// Optional: User's Xion address
    pub xion_address: Option<String>,
}
