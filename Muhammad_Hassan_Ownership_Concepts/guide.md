# Ownership Concepts in Cairo

## What is Ownership?

Ownership is the set of rules that governs how a programming language manages memory and resource lifetimes. Cairo's ownership model is inspired by Rust's linear type system: every value has exactly **one owner** at a time, and when that owner goes out of scope the value is automatically cleaned up (dropped).

Unlike Rust, Cairo does **not** have mutable references (`&mut T`) or a full borrow-checker. Instead Cairo offers:

| Mechanism | Cairo construct | When to use |
|---|---|---|
| Copy | Types with `#[derive(Copy)]` | Small, cheap-to-duplicate scalars and structs |
| Move | Default for non-Copy types | Structs, arrays, enums with data |
| Snapshot | `@T` | Read-only view without consuming ownership |

---

## 1. The Linear Type System

Cairo's type system is **linear**: a non-Copy value can be used exactly **once**. After it is passed to a function or assigned to another binding it is *moved* and the original binding becomes invalid. The compiler enforces this at compile time — no runtime overhead, no garbage collector.

```cairo
let wallet = Wallet { owner: 'Alice', balance: 100_u64 };
let _ = spend(wallet);   // wallet is MOVED here
// wallet is no longer accessible below this line
```

---

## 2. Copy Types

A type that implements the `Copy` trait is duplicated automatically whenever it is assigned or passed to a function. The original binding remains valid.

**Types that are Copy by default:**
- `felt252`
- All integer types: `u8`, `u16`, `u32`, `u64`, `u128`, `u256`, `i8` … `i128`
- `bool`
- Tuples of Copy types
- Structs/enums explicitly annotated with `#[derive(Copy, Drop)]`

```cairo
let x: u32 = 10;
let y = x;          // x is COPIED; both x and y are valid
let z = double(x);  // x is COPIED into double(); x still valid here
```

### Deriving Copy for a Struct

```cairo
#[derive(Copy, Drop)]
struct Point {
    x: u32,
    y: u32,
}
```

`Drop` must also be derived (or implemented) whenever `Copy` is — Cairo needs to know how to clean up the value even if it is never explicitly consumed.

---

## 3. Move Semantics

When a non-Copy type is passed to a function or assigned to a new binding, **ownership is transferred (moved)**. The compiler will raise a compile error if you attempt to use the original binding afterwards.

```cairo
#[derive(Drop)]
struct Wallet {
    owner: felt252,
    balance: u64,
}

fn spend(w: Wallet) -> u64 { ... }  // w is consumed here

fn main() {
    let w = Wallet { owner: 'Bob', balance: 500_u64 };
    let remaining = spend(w);        // w is moved
    // let _ = w.balance;            // ERROR – w was moved
}
```

### Returning Ownership

To keep using a value after passing it to a function, the function can **return** the value (or a modified version of it):

```cairo
fn add_tokens(mut w: Wallet, amount: u64) -> Wallet {
    w.balance += amount;
    w  // ownership transferred back to the caller
}

fn main() {
    let w = Wallet { owner: 'Bob', balance: 200_u64 };
    let w = add_tokens(w, 100_u64);  // re-bind; we own w again
    assert(w.balance == 300_u64, '');
}
```

---

## 4. The `Drop` Trait

Every value that goes out of scope must be either:
- **Consumed** (moved into a function or returned), or
- **Dropped** (if the type implements `Drop`)

If a type neither implements `Drop` nor `Destruct`, the compiler will refuse to let it go out of scope without being consumed. For most user-defined types, deriving `Drop` is the right choice.

```cairo
#[derive(Drop)]   // Cairo will auto-generate cleanup code
struct Token { id: u64 }
```

---

## 5. Snapshots (`@T`)

A **snapshot** is Cairo's read-only, non-consuming view of a value. It is analogous to an immutable reference in Rust. The syntax is `@value` to create one and `*field` (desnap) to read a field inside a snapshot.

```cairo
fn read_balance(w: @Wallet) -> u64 {
    *w.balance   // desnap to get the u64
}

fn main() {
    let w = Wallet { owner: 'Carol', balance: 777_u64 };
    let bal = read_balance(@w);   // w is NOT moved; just snapshotted
    assert(w.balance == 777_u64, '');  // w still accessible
}
```

Key rules for snapshots:
- A snapshot `@T` is always `Copy` even if `T` is not.
- Snapshots cannot be used to mutate the underlying value.
- Inside a snapshotted struct, every field is also a snapshot.

---

## 6. Ownership with Arrays

`Array<T>` is not `Copy`. Passing an array to a function moves it. The idiomatic pattern to "use then keep" is to return the array from the function:

```cairo
fn sum_array(arr: Array<u32>) -> (u32, Array<u32>) {
    // … compute sum …
    (sum, arr)   // return both the sum and ownership of the array
}
```

Alternatively, pass a snapshot when you only need to read:

```cairo
fn len_of(arr: @Array<u32>) -> usize {
    arr.len()   // snapshots support read-only methods
}
```

---

## 7. Ownership in Enums

Enums that hold non-Copy payloads follow the same move semantics as structs:

```cairo
#[derive(Drop)]
enum Asset {
    Token: u64,
    NFT:   felt252,
    Empty,
}

let asset = Asset::Token(100_u64);
let tag = describe(asset);   // asset is moved; not usable after
```

---

## 8. Why Does Ownership Matter for Smart Contracts?

In a StarkNet smart contract context, ownership semantics matter because:

1. **Storage writes are explicit** — there is no implicit aliasing; every state change is traceable.
2. **No reentrancy surprises** — because values cannot be aliased, you cannot accidentally read stale state through a second pointer.
3. **Zero-copy proofs** — Cairo's VM operates over a trace of field-element operations; move semantics ensure each cell in the trace is written exactly once, which is a natural fit for STARK proof generation.
4. **Gas efficiency** — the compiler can precisely determine when memory cells are last used and avoid unnecessary copies.

---

## 9. Summary Table

| Concept | Keyword / Trait | Effect |
|---|---|---|
| Copy | `#[derive(Copy, Drop)]` | Value is duplicated on assignment or function call |
| Move | default for non-Copy | Ownership transferred; original binding invalid |
| Drop | `#[derive(Drop)]` | Value can go out of scope (auto-cleaned) |
| Snapshot | `@T` / `@value` | Read-only view; does not consume ownership |
| Desnap | `*snapshotted_field` | Reads a Copy value out of a snapshot |
| Return ownership | `fn f(v: T) -> T` | Caller regains ownership after function returns |

---

## 10. File Structure of this Assignment

```
Muhammad_Hassan_Ownership_Concepts/
├── Scarb.toml               # Scarb project manifest
├── ownership_concepts.cairo # Main Cairo source file
└── guide.md                 # This document
```

### Running the Code

```bash
# Install Scarb (Cairo package manager) if not already installed:
# https://docs.swmansion.com/scarb/

cd Muhammad_Hassan_Ownership_Concepts
scarb build    # compile
scarb run      # execute main()
```

---

## 11. References

- [The Cairo Book – Ownership](https://book.cairo-lang.org/ch04-01-what-is-ownership.html)
- [The Cairo Book – References and Snapshots](https://book.cairo-lang.org/ch04-02-references-and-snapshots.html)
- [StarkNet Documentation](https://docs.starknet.io)
- [Scarb – Cairo Package Manager](https://docs.swmansion.com/scarb/)
