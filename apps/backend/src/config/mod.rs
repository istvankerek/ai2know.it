//! Alkalmazas konfiguracio
//! Kornyezeti valtozokbol olvas (environments/.env.*)

use std::env;

/// Alkalmazas konfiguracio
pub struct AppConfig {
    pub app_name: String,
    pub app_env: String,
    pub app_port: u16,
    pub database_url: String,
    pub redis_url: String,
    pub nats_url: String,
    pub minio_endpoint: String,
    /// SkillPass.ID OIDC issuer (az okoszisztema egyetlen IdP-je)
    pub skillpass_issuer: String,
}

impl AppConfig {
    /// Kornyezeti valtozokbol olvas
    pub fn from_env() -> Self {
        Self {
            app_name: env::var("APP_NAME").unwrap_or_else(|_| "everengine".into()),
            app_env: env::var("APP_ENV").unwrap_or_else(|_| "local".into()),
            app_port: env::var("APP_PORT")
                .unwrap_or_else(|_| "8080".into())
                .parse()
                .unwrap_or(8080),
            database_url: env::var("DATABASE_URL")
                .expect("DATABASE_URL kornyezeti valtozo szukseges"),
            redis_url: env::var("REDIS_URL")
                .unwrap_or_else(|_| "redis://localhost:6379".into()),
            nats_url: env::var("NATS_URL")
                .unwrap_or_else(|_| "nats://localhost:4222".into()),
            minio_endpoint: env::var("MINIO_ENDPOINT")
                .unwrap_or_else(|_| "localhost:9000".into()),
            skillpass_issuer: env::var("SKILLPASS_ISSUER")
                .unwrap_or_else(|_| "https://skillpass.id".into()),
        }
    }

    /// Produkcio kornyezet-e
    pub fn is_production(&self) -> bool {
        self.app_env == "prod"
    }
}
