// ============================================================
// Pedersen Hash in Cairo
// Author: Hafiza Anila Javed
// Topic: Hash in Contract (Pedersen Hash)
// ============================================================

use core::hash::{HashStateTrait, HashStateExTrait};
use core::pedersen::PedersenTrait;

// STRUCT: A user record we will hash
#[derive(Drop, Hash, Copy)]
struct UserRecord {
    username: felt252,
    age: u32,
    score: felt252,
}

// Hash two felt252 values: Pedersen(a, b)
fn hash_two(a: felt252, b: felt252) -> felt252 {
    PedersenTrait::new(a).update(b).finalize()
}

// Hash a single value using 0 as base: Pedersen(0, value)
fn hash_single(value: felt252) -> felt252 {
    PedersenTrait::new(0).update(value).finalize()
}

// Hash a UserRecord struct
fn hash_user(user: UserRecord) -> felt252 {
    PedersenTrait::new(0).update_with(user).finalize()
}

// Hash three values in a chain: H(H(a, b), c)
fn hash_chain(a: felt252, b: felt252, c: felt252) -> felt252 {
    hash_two(hash_two(a, b), c)
}

#[executable]
fn main() {
    // Demo 1: Hash two values
    println!("Demo 1 - Pedersen(100, 200)      = {}", hash_two(100, 200));

    // Demo 2: Non-commutativity H(a,b) != H(b,a)
    println!("Demo 2 - Pedersen(200, 100)      = {}", hash_two(200, 100));
    println!("         Are they equal?          = {}", hash_two(100, 200) == hash_two(200, 100));

    // Demo 3: Hash a single value
    println!("Demo 3 - hash_single(42)         = {}", hash_single(42));

    // Demo 4: Hash a struct
    println!("Demo 4 - hash_user(anila,20,999) = {}", hash_user(UserRecord { username: 'anila', age: 20, score: 999 }));

    // Demo 5: Determinism check
    println!("Demo 5 - Determinism check       = {}", hash_two(100, 200) == hash_two(100, 200));

    // Demo 6: Hash chain
    println!("Demo 6 - hash_chain(100,200,300) = {}", hash_chain(100, 200, 300));

    println!("--------------------------------------------------");
    println!("Pedersen Hash properties verified:");
    println!("  Deterministic   : YES (Demo 5)");
    println!("  Non-commutative : YES (Demo 2)");
    println!("  Works on structs: YES (Demo 4)");
    println!("  Supports chaining: YES (Demo 6)");
}
