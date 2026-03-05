# OAuth2 客户端架构设计

## 系统概述

Xion Agent Toolkit 的 OAuth2 客户端实现了基于 OAuth2 Authorization Code Flow + PKCE 的认证流程，支持浏览器登录、本地回调服务器、Token 管理和多网络环境。

## 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      CLI Layer (auth.rs)                     │
│  - Handle login/logout/status/refresh commands              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   OAuth Client (client.rs)                   │
│  - Orchestrate OAuth2 flow                                  │
│  - Coordinate PKCE, callback server, token manager          │
└────────┬─────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────┐   ┌──────────────────┐   ┌─────────────────┐
│   PKCE       │   │ Callback Server  │   │ Token Manager   │
│  (pkce.rs)   │   │(callback_server) │   │(token_manager)  │
│              │   │                  │   │                 │
│- Verifier    │   │- Axum server     │   │- Refresh token  │
│- Challenge   │   │- Code receiver   │   │- Expiry check   │
│- State       │   │- State validate  │   │- Auto-refresh   │
└──────────────┘   └──────────────────┘   └─────────────────┘
         │                    │                    │
         └────────────────────┴────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │   OAuth2 API Client           │
              │   (api/oauth2_api.rs)         │
              │                               │
              │   - Exchange code for tokens  │
              │   - Refresh token             │
              │   - Get user info             │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  Credentials Manager          │
              │  (config/credentials.rs)      │
              │                               │
              │  - Keyring storage            │
              │  - File metadata              │
              └───────────────────────────────┘
```

## 模块划分

### 1. OAuth2 核心模块 (`src/oauth/`)

#### 1.1 `mod.rs`
**职责**: 模块导出和公共 API

```rust
pub mod pkce;
pub mod client;
pub mod callback_server;
pub mod token_manager;

pub use client::OAuthClient;
pub use pkce::PKCEChallenge;
pub use token_manager::TokenManager;
```

#### 1.2 `pkce.rs`
**职责**: PKCE 实现（RFC 7636）

**关键 Struct**:
```rust
pub struct PKCEChallenge {
    pub verifier: String,
    pub challenge: String,
    pub state: String,
}

impl PKCEChallenge {
    /// Generate a new PKCE challenge
    /// - Verifier: 43 characters, cryptographically random
    /// - Challenge: SHA-256(verifier), Base64URL encoded
    /// - State: 32 bytes random, hex encoded
    pub fn generate() -> Result<Self>;
    
    /// Verify if a state matches
    pub fn verify_state(&self, state: &str) -> bool;
}
```

#### 1.3 `client.rs`
**职责**: OAuth2 客户端主逻辑，编排整个登录流程

**关键 Struct**:
```rust
pub struct OAuthClient {
    config: NetworkConfig,
    http_client: reqwest::Client,
    credentials_manager: CredentialsManager,
}

impl OAuthClient {
    pub fn new(config: NetworkConfig) -> Result<Self>;
    
    /// Execute full OAuth2 login flow
    pub async fn login(&self, port: u16) -> Result<UserCredentials>;
    
    /// Refresh access token
    pub async fn refresh_token(&self) -> Result<UserCredentials>;
    
    /// Logout (clear credentials)
    pub fn logout(&self) -> Result<()>;
    
    /// Check if authenticated
    pub fn is_authenticated(&self) -> Result<bool>;
}
```

#### 1.4 `callback_server.rs`
**职责**: 本地回调服务器，接收 OAuth2 redirect

**关键 Struct**:
```rust
pub struct CallbackServer {
    port: u16,
}

impl CallbackServer {
    pub fn new(port: u16) -> Self;
    
    /// Start server and wait for OAuth2 callback
    pub async fn wait_for_code(self, expected_state: &str) -> Result<String>;
}
```

#### 1.5 `token_manager.rs`
**职责**: Token 生命周期管理（刷新、过期检查）

**关键 Struct**:
```rust
pub struct TokenManager {
    credentials_manager: CredentialsManager,
    http_client: reqwest::Client,
    oauth_api_url: String,
}

impl TokenManager {
    pub fn new(credentials_manager: CredentialsManager, oauth_api_url: String) -> Self;
    
    /// Get valid access token (refresh if needed)
    pub async fn get_valid_token(&self) -> Result<String>;
    
    /// Refresh access token
    pub async fn refresh_access_token(&self) -> Result<UserCredentials>;
}
```

### 2. OAuth2 API 客户端模块 (`src/api/oauth2_api.rs`)

**职责**: 与 OAuth2 API Service 通信

**关键 Struct**:
```rust
pub struct OAuth2ApiClient {
    base_url: String,
    http_client: reqwest::Client,
}

impl OAuth2ApiClient {
    pub fn new(base_url: String) -> Self;
    
    /// Exchange authorization code for tokens
    pub async fn exchange_code(
        &self,
        code: &str,
        code_verifier: &str,
        redirect_uri: &str,
        client_id: &str,
    ) -> Result<TokenResponse>;
    
    /// Refresh access token
    pub async fn refresh_token(
        &self,
        refresh_token: &str,
        client_id: &str,
    ) -> Result<TokenResponse>;
}
```

## 文件创建清单

需要创建的新文件：

1. `src/oauth/mod.rs` - 模块导出
2. `src/oauth/pkce.rs` - PKCE 实现
3. `src/oauth/client.rs` - OAuth2 客户端主逻辑
4. `src/oauth/callback_server.rs` - Axum 回调服务器
5. `src/oauth/token_manager.rs` - Token 管理器
6. `src/api/mod.rs` - API 模块导出
7. `src/api/oauth2_api.rs` - OAuth2 API 客户端

需要修改的文件：

1. `src/main.rs` - 添加 oauth 和 api 模块
2. `src/cli/auth.rs` - 实现 handle_login, handle_refresh
3. `src/utils/error.rs` - 扩展错误类型

## 开发计划

### Phase 2.1: 基础设施（优先级：P0）
- [ ] 创建模块结构（oauth, api）
- [ ] 实现 PKCE（pkce.rs）
- [ ] 实现 OAuth2 API 客户端（oauth2_api.rs）
- [ ] 扩展错误处理（error.rs）

### Phase 2.2: 核心流程（优先级：P0）
- [ ] 实现回调服务器（callback_server.rs）
- [ ] 实现 OAuth2 客户端编排（client.rs）
- [ ] 实现 Token 管理器（token_manager.rs）

### Phase 2.3: 集成（优先级：P0）
- [ ] CLI 命令集成（auth.rs）
- [ ] 测试和验证

---
*Created by: @architect*
*Date: 2025-03-05*
