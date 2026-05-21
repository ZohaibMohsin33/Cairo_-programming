// ============================================================
// Pedersen Hash Example in Cairo
// Student: Muhammad Abdullah Zahid
// Topic:   Pedersen Hash Example
// ============================================================
//
// This file demonstrates how to use the Pedersen hash function
// in Cairo. It covers:
//   1. Hashing simple felt252 values
//   2. Hashing a struct using update_with (with a base state)
//   3. Hashing struct fields individually via serialization
//
// The Pedersen hash is an elliptic-curve-based cryptographic hash
// function that was the first hash used on Starknet. It is still
// used internally for storage variable addressing (e.g. LegacyMap).
// For new Cairo programs, Poseidon is preferred because it is
// cheaper in STARK proofs, but Pedersen remains important to understand.
// ============================================================

use core::hash::{HashStateExTrait, HashStateTrait};
use core::pedersen::PedersenTrait;

// -----------------------------------------------------------------
// A simple struct whose fields are all felt252-compatible (hashable).
// We derive Hash so that PedersenTrait can call update_with on it.
// We also derive Serde so we can serialize the struct into an Array
// for the field-by-field hashing approach.
// -----------------------------------------------------------------
#[derive(Drop, Hash, Serde, Copy)]
struct UserRecord {
    id: felt252,      // unique identifier
    score: felt252,   // score value
    level: felt252,   // game / access level
}

// -----------------------------------------------------------------
// hash_single_value
//
// Shows the simplest possible Pedersen hash: a single felt252 value.
// PedersenTrait::new(base) creates a hash state with the given base.
// update(value) feeds one felt252 into the hash.
// finalize() returns the resulting felt252 hash.
// -----------------------------------------------------------------
fn hash_single_value(value: felt252) -> felt252 {
    // Base state is 0 (a common convention when there is no meaningful base)
    let hash = PedersenTrait::new(0)
        .update(value)
        .finalize();
    hash
}

// -----------------------------------------------------------------
// hash_two_values
//
// Chains two update calls, demonstrating how Pedersen absorbs
// multiple inputs. Each update call feeds another felt252 into
// the running hash state.
// -----------------------------------------------------------------
fn hash_two_values(a: felt252, b: felt252) -> felt252 {
    let hash = PedersenTrait::new(0)
        .update(a)
        .update(b)
        .finalize();
    hash
}

// -----------------------------------------------------------------
// hash_struct_with_base
//
// Hashes a UserRecord struct all at once using update_with.
// The base state is 0 (arbitrary; could be any felt252).
// update_with internally iterates over every field and calls
// update on each one, so the result includes all fields.
// -----------------------------------------------------------------
fn hash_struct_with_base(record: UserRecord) -> felt252 {
    let hash = PedersenTrait::new(0)
        .update_with(record)
        .finalize();
    hash
}

// -----------------------------------------------------------------
// hash_struct_field_by_field
//
// An alternative approach: serialize the struct into an Array<felt252>
// then use the first element as the Pedersen base state and loop
// over the remaining elements with plain update() calls.
//
// This gives the same logical content as hash_struct_with_base
// but makes the field-iteration explicit, which is useful when
// you cannot derive Hash (e.g. if a field is an Array<T>).
// -----------------------------------------------------------------
fn hash_struct_field_by_field(record: UserRecord) -> felt252 {
    // Serialize the struct into a dynamic array of felt252 values
    let mut serialized: Array<felt252> = ArrayTrait::new();
    Serde::serialize(@record, ref serialized);

    // Use the first serialized field as the Pedersen base state
    let first = *serialized.at(0);
    let mut state = PedersenTrait::new(first);

    // Feed the remaining fields into the hash state one by one
    let mut i: usize = 1;
    loop {
        if i >= serialized.len() {
            break;
        }
        state = state.update(*serialized.at(i));
        i += 1;
    };

    state.finalize()
}

// -----------------------------------------------------------------
// main – entry point
//
// Creates sample data, calls each hashing function and prints the
// results so you can observe how different inputs produce different
// hash outputs.
// -----------------------------------------------------------------
fn main() {
    // --- Example 1: hash a single felt252 value ---
    let val: felt252 = 42;
    let h1 = hash_single_value(val);
    println!("Hash of single value (42):          {}", h1);

    // --- Example 2: hash two felt252 values ---
    let h2 = hash_two_values(1, 2);
    println!("Hash of (1, 2):                     {}", h2);

    // --- Example 3: hash a struct using update_with ---
    let record = UserRecord { id: 1001, score: 500, level: 3 };
    let h3 = hash_struct_with_base(record);
    println!("Hash of struct (update_with):        {}", h3);

    // --- Example 4: hash the same struct field-by-field ---
    let h4 = hash_struct_field_by_field(record);
    println!("Hash of struct (field-by-field):     {}", h4);

    // --- Verify determinism: same input → same hash every time ---
    let h3_again = hash_struct_with_base(record);
    println!("Same struct hashed again (must match): {}", h3_again);

    // --- Show that different structs produce different hashes ---
    let other_record = UserRecord { id: 1002, score: 500, level: 3 };
    let h5 = hash_struct_with_base(other_record);
    println!("Hash of different struct (id=1002):  {}", h5);

    // h3 and h5 must differ because the id field differs
    assert!(h3 != h5, "Different structs must have different hashes");
    println!("Confirmed: changing the id changes the hash.");
}

// -----------------------------------------------------------------
// Tests
// -----------------------------------------------------------------
#[cfg(test)]
mod tests {
    use super::{
        UserRecord,
        hash_single_value,
        hash_two_values,
        hash_struct_with_base,
        hash_struct_field_by_field,
    };

    // Pedersen hash is deterministic: same input → same output
    #[test]
    fn test_hash_single_value_is_deterministic() {
        let h1 = hash_single_value(99);
        let h2 = hash_single_value(99);
        assert!(h1 == h2, "Same input must produce same hash");
    }

    // Different single values must produce different hashes
    #[test]
    fn test_different_single_values_differ() {
        let h1 = hash_single_value(1);
        let h2 = hash_single_value(2);
        assert!(h1 != h2, "Different inputs must produce different hashes");
    }

    // Hashing (a, b) must differ from hashing (b, a)  –  order matters
    #[test]
    fn test_order_matters() {
        let h_ab = hash_two_values(10, 20);
        let h_ba = hash_two_values(20, 10);
        assert!(h_ab != h_ba, "Hash(a,b) must differ from Hash(b,a)");
    }

    // Structs with different fields must hash differently
    #[test]
    fn test_different_structs_differ() {
        let r1 = UserRecord { id: 1, score: 100, level: 1 };
        let r2 = UserRecord { id: 2, score: 100, level: 1 };
        assert!(
            hash_struct_with_base(r1) != hash_struct_with_base(r2),
            "Different structs must have different hashes"
        );
    }

    // The two struct-hashing approaches operate on the same field values.
    // Note: they will produce DIFFERENT final hashes because
    //   update_with uses 0 as base and feeds all fields,
    //   while field_by_field uses the FIRST FIELD as the base.
    // This test documents that intentional design difference.
    #[test]
    fn test_both_approaches_are_deterministic() {
        let r = UserRecord { id: 5, score: 250, level: 7 };
        let h_update = hash_struct_with_base(r);
        let h_field  = hash_struct_field_by_field(r);

        // Each approach is self-consistent (deterministic)
        assert!(h_update == hash_struct_with_base(r));
        assert!(h_field  == hash_struct_field_by_field(r));

        // Document that the two approaches produce different values
        // (this is expected, not a bug)
        assert!(h_update != h_field, "Different hashing approaches produce different values");
    }
}
