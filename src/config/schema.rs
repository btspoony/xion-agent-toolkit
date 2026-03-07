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

/// Default refresh token lifetime in seconds (30 days)
pub const DEFAULT_REFRESH_TOKEN_LIFETIME_SECS: i64 = 30 * 24 * 60 * 60; // 30 days

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserCredentials {
    /// User's access token
    pub access_token: String,

    /// User's refresh token
    pub refresh_token: String,

    /// Access token expiration time (ISO 8601 format)
    pub expires_at: String,

    /// Refresh token expiration time (ISO 8601 format)
    /// Defaults to 30 days from creation if not provided by the OAuth2 server
    #[serde(default)]
    pub refresh_token_expires_at: Option<String>,

    /// Optional: User's Xion address
    pub xion_address: Option<String>,
}
