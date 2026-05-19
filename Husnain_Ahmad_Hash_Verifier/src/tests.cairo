use super::{hash_age, verify_age_constraint, verify_hash_with_constraint};

#[test]
fn test_hash_deterministic() {
    let age = 25_u64;
    let hash1 = hash_age(age);
    let hash2 = hash_age(age);

    assert!(hash1 == hash2, "Same age must produce same hash");
}

#[test]
fn test_hash_uniqueness() {
    let hash_20 = hash_age(20_u64);
    let hash_21 = hash_age(21_u64);

    assert!(hash_20 != hash_21, "Different ages must produce different hashes");
}

#[test]
fn test_age_constraint() {
    assert!(verify_age_constraint(18_u64), "Age 18 should pass");
    assert!(!verify_age_constraint(17_u64), "Age 17 should fail");
}

#[test]
fn test_verify_success() {
    let age = 30_u64;
    let stored_hash = hash_age(age);

    assert!(verify_hash_with_constraint(stored_hash, age), "Valid hash should verify");
}

#[test]
fn test_verify_wrong_age_fails() {
    let stored_hash = hash_age(25_u64);

    assert!(
        !verify_hash_with_constraint(stored_hash, 26_u64),
        "Wrong age should fail verification",
    );
}

#[test]
fn test_verify_underage_fails() {
    let age = 16_u64;
    let stored_hash = hash_age(age);

    assert!(
        !verify_hash_with_constraint(stored_hash, age),
        "Underage should fail verification",
    );
}

#[test]
fn test_verify_missing_hash_fails() {
    let age = 25_u64;

    assert!(
        !verify_hash_with_constraint(0, age),
        "Missing hash should fail verification",
    );
}
