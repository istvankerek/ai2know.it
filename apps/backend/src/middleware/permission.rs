//! require_permission! makro es permission middleware

// TODO: require_permission! makro definicio
// TODO: Permission format: {module}:{action}
// TODO: User role -> permissions lekerdezes
// TODO: 403 Forbidden ha nincs jogosultsag

/// Permission ellenorzo makro
/// Hasznalat: require_permission!(ctx, "users:create")
macro_rules! require_permission {
    ($ctx:expr, $perm:expr) => {
        // TODO: implementacio
    };
}
pub(crate) use require_permission;
