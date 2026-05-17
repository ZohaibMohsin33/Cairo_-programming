// ============================================================
// ownership_concepts.cairo
// Topic: Ownership Concepts in Cairo
// Student: Muhammad Hassan
// ============================================================
// Cairo uses a linear type system inspired by Rust.
// Unlike Rust, Cairo does NOT have references (&T) or borrowing
// in the same way. Instead, values can be:
//   1. MOVED  - ownership transferred; original binding gone
//   2. COPIED - if the type implements the Copy trait, the value
//               is duplicated and the original remains usable
//
// This file demonstrates both behaviours and shows how to work
// with structs, enums, and arrays under Cairo's ownership rules.
// ============================================================

// ------------------------------------------------------------------
// 1. Copy Types
//    Scalar types (felt252, u32, bool, etc.) implement Copy by
//    default, meaning assignment or passing to a function creates
//    a fresh copy; the original variable stays valid.
// ------------------------------------------------------------------

fn demonstrate_copy() {
    let x: u32 = 42;

    // 'x' is copied into 'y'. Both bindings are valid afterwards.
    let y: u32 = x;

    // We can still use x after assigning to y.
    assert(x == 42, 'x should still be 42');
    assert(y == 42, 'y should be 42');

    // Passing a Copy type to a function also copies it.
    let doubled = double_value(x); // x is copied into the function
    assert(x == 42, 'x unchanged after function call');
    assert(doubled == 84, 'doubled should be 84');
}

// Helper – receives a copy of the u32, not ownership transfer
fn double_value(n: u32) -> u32 {
    n * 2
}

// ------------------------------------------------------------------
// 2. Move Semantics
//    Non-Copy types (structs without #[derive(Copy)], arrays, …)
//    follow move semantics. After a move the original binding is
//    no longer accessible.
// ------------------------------------------------------------------

// A struct that does NOT derive Copy – it will be MOVED.
#[derive(Drop)]           // Drop lets Cairo clean up the value
struct Wallet {
    owner: felt252,       // owner identifier (e.g. address hash)
    balance: u64,         // token balance
}

fn demonstrate_move() {
    let wallet = Wallet { owner: 'Alice', balance: 1000_u64 };

    // Transfer ownership to the function; 'wallet' is moved.
    let new_balance = spend_tokens(wallet, 200_u64);
    // From this point, 'wallet' is no longer usable here.
    // Uncommenting the next line would cause a compile error:
    // let _ = wallet.balance; // ERROR: wallet was moved

    assert(new_balance == 800_u64, 'balance after spend should be 800');
}

// Takes full ownership of 'w', modifies it, and returns the new balance.
fn spend_tokens(mut w: Wallet, amount: u64) -> u64 {
    assert(w.balance >= amount, 'insufficient balance');
    w.balance -= amount;
    w.balance   // return the remaining balance (w is dropped here)
}

// ------------------------------------------------------------------
// 3. Returning Ownership
//    Functions can give ownership back to the caller by returning
//    the value. This is the Cairo idiomatic way to "use and keep".
// ------------------------------------------------------------------

fn demonstrate_return_ownership() {
    let wallet = Wallet { owner: 'Bob', balance: 500_u64 };

    // Pass wallet in; get a (modified) wallet back.
    let wallet = add_tokens(wallet, 300_u64);

    // Now we own wallet again and can use it.
    assert(wallet.balance == 800_u64, 'balance should be 800 after add');
}

// Consumes 'w', adds tokens, and returns ownership to the caller.
fn add_tokens(mut w: Wallet, amount: u64) -> Wallet {
    w.balance += amount;
    w               // ownership transferred back to caller
}

// ------------------------------------------------------------------
// 4. Copy Structs
//    Derive both Copy and Drop to allow value-level duplication.
// ------------------------------------------------------------------

#[derive(Copy, Drop)]
struct Point {
    x: u32,
    y: u32,
}

fn demonstrate_copy_struct() {
    let p1 = Point { x: 3, y: 7 };
    let p2 = p1;    // p1 is COPIED (not moved) because Point: Copy

    // Both p1 and p2 are independently valid.
    assert(p1.x == 3, 'p1.x should be 3');
    assert(p2.x == 3, 'p2.x should be 3');

    let p3 = translate(p1, 10, 5); // p1 is copied into the function
    assert(p1.x == 3,  'p1 unchanged after translate');
    assert(p3.x == 13, 'p3.x should be 13');
    assert(p3.y == 12, 'p3.y should be 12');
}

// Receives a copy of Point; returns a new Point.
fn translate(p: Point, dx: u32, dy: u32) -> Point {
    Point { x: p.x + dx, y: p.y + dy }
}

// ------------------------------------------------------------------
// 5. Ownership with Enums
//    Enums containing non-Copy payloads also follow move semantics.
// ------------------------------------------------------------------

#[derive(Drop)]
enum Asset {
    Token: u64,       // fungible token amount
    NFT: felt252,     // NFT identifier
    Empty,            // no asset
}

fn demonstrate_enum_ownership() {
    let asset = Asset::Token(250_u64);

    // Move asset into the function; it cannot be used here after.
    let description = describe_asset(asset);
    // 'asset' is no longer accessible here.
    assert(description == 'token', 'should be token');
}

// Consumes 'a' and returns a felt252 description tag.
fn describe_asset(a: Asset) -> felt252 {
    match a {
        Asset::Token(_) => 'token',
        Asset::NFT(_)   => 'nft',
        Asset::Empty    => 'empty',
    }
}

// ------------------------------------------------------------------
// 6. Arrays and Ownership
//    Array<T> is not Copy. Passing an array to a function moves it.
//    To keep using the array, either return it or use snapshots (@T).
// ------------------------------------------------------------------

fn demonstrate_array_ownership() {
    let mut scores: Array<u32> = ArrayTrait::new();
    scores.append(10_u32);
    scores.append(20_u32);
    scores.append(30_u32);

    // Move array into the function; get back the sum AND the array.
    let (total, scores) = sum_array(scores);

    // We own 'scores' again because the function returned it.
    assert(total == 60_u32, 'sum should be 60');
    assert(*scores.at(0) == 10_u32, 'first element should be 10');
}

// Consumes the array, computes the sum, and returns both.
fn sum_array(arr: Array<u32>) -> (u32, Array<u32>) {
    let mut sum: u32 = 0;
    let mut i: usize = 0;
    loop {
        if i >= arr.len() {
            break;
        }
        sum += *arr.at(i);
        i += 1;
    };
    (sum, arr)  // return ownership of the array together with the sum
}

// ------------------------------------------------------------------
// 7. Snapshots (@T)  –  Read-Only "Borrow" Equivalent
//    A snapshot (@T) gives read-only access to a value without
//    consuming ownership. This is Cairo's closest construct to an
//    immutable reference.
// ------------------------------------------------------------------

fn demonstrate_snapshot() {
    let wallet = Wallet { owner: 'Carol', balance: 777_u64 };

    // Pass a snapshot; 'wallet' is NOT moved.
    let bal = read_balance(@wallet);

    // 'wallet' is still accessible here.
    assert(wallet.balance == 777_u64, 'wallet unchanged');
    assert(bal == 777_u64, 'snapshot read correct balance');
}

// Accepts a snapshot – read-only; does not consume the Wallet.
fn read_balance(w: @Wallet) -> u64 {
    *w.balance   // desnap the field to obtain the u64 value
}

// ------------------------------------------------------------------
// Main entry point – runs all demonstrations
// ------------------------------------------------------------------

fn main() {
    demonstrate_copy();
    demonstrate_move();
    demonstrate_return_ownership();
    demonstrate_copy_struct();
    demonstrate_enum_ownership();
    demonstrate_array_ownership();
    demonstrate_snapshot();
}
