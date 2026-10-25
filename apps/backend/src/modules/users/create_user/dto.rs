//! CreateUserDto – uj felhasznalo keres/valasz tipusok
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct CreateUserRequest {
    pub name: String,
    pub email: String,
    // TODO: tovabbi mezok
}

#[derive(Debug, Serialize)]
pub struct CreateUserResponse {
    pub id: String,
    pub name: String,
    pub email: String,
    pub created_at: String,
}
