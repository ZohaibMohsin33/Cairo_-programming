# Pedersen Hash Example — Guide

**Student:** Muhammad Abdullah Zahid  
**Topic:** Pedersen Hash Example  
**Language:** Cairo (Starknet)  
**Tool:** Scarb

---

## 1. What is Hashing?

Hashing is the process of converting any input of arbitrary length into a fixed-size output (the *hash* or *digest*). A good hash function has three key properties:

| Property | Meaning |
|---|---|
| **Deterministic** | Same input always → same hash |
| **One-way** | Cannot recover the input from the hash |
| **Collision-resistant** | Hard to find two inputs that produce the same hash |

Hash functions are used everywhere in smart contracts: Merkle trees, storage key derivation, commitment schemes, and identity verification.

---

## 2. What is the Pedersen Hash?

Pedersen hash is a **cryptographic hash function based on elliptic curve cryptography (ECC)**. It works by performing scalar multiplication of points on an elliptic curve, which is:

- **Easy to compute** in the forward direction
- **Hard to reverse** — based on the *Elliptic Curve Discrete Logarithm Problem (ECDLP)*

### Mathematical intuition

Given elliptic curve points `G₀, G₁, …, Gₙ` and scalar inputs `a₀, a₁, …, aₙ`:

```
Pedersen(a₀, a₁, …, aₙ) = a₀·G₀ + a₁·G₁ + … + aₙ·Gₙ
```

The result is a point on the curve; its x-coordinate becomes the hash output.

---

## 3. Pedersen on Starknet

Pedersen was the **first hash function used on Starknet** and is still used in several system-level operations:

- **Storage addressing** — `LegacyMap` uses Pedersen to derive storage keys for mapped values.
- **Contract address computation** — the address of a deployed contract is derived using Pedersen.
- **Older infrastructure** — many existing contracts and tooling still rely on Pedersen.

> **Note:** For new Cairo programs, **Poseidon** is now recommended because it is cheaper (fewer STARK proof constraints). However, understanding Pedersen is essential because it remains in use and appears in security-critical paths.

---

## 4. Pedersen vs Poseidon (quick comparison)

| Feature | Pedersen | Poseidon |
|---|---|---|
| Based on | Elliptic curves (ECDLP) | Hades permutation (algebraic) |
| STARK cost | Higher | Lower (recommended) |
| Base state | Required (`PedersenTrait::new(base)`) | Not required (`PoseidonTrait::new()`) |
| Starknet history | First / original hash | Current recommendation |
| Common use today | Storage key derivation, legacy code | New contracts, Merkle trees |

---

## 5. Cairo Core Library API

### Import

```cairo
use core::hash::{HashStateExTrait, HashStateTrait};
use core::pedersen::PedersenTrait;
```

### Initialization — requires a base state

```cairo
let state = PedersenTrait::new(base: felt252);
```

Pedersen is unique in that it **requires a base state** (a starting `felt252`). This is unlike Poseidon which can start from a zeroed state with no arguments.

### Updating the state

```cairo
// Feed one raw felt252 value
let state = state.update(value: felt252);

// Feed any type that implements Hash (e.g. a struct with #[derive(Hash)])
let state = state.update_with(value: T);
```

Each `update` / `update_with` call returns a *new* state (Cairo's ownership model — states are not mutated in place).

### Finalizing

```cairo
let hash: felt252 = state.finalize();
```

Returns the final hash as a `felt252`.

### Full example — single value

```cairo
let hash = PedersenTrait::new(0).update(42).finalize();
```

---

## 6. Hashing Structs

### Approach A — `#[derive(Hash)]` + `update_with`

```cairo
#[derive(Drop, Hash, Serde, Copy)]
struct UserRecord {
    id:    felt252,
    score: felt252,
    level: felt252,
}

let record = UserRecord { id: 1001, score: 500, level: 3 };
let hash = PedersenTrait::new(0).update_with(record).finalize();
```

`update_with` internally walks every field and calls `update` on each one. The struct must have `#[derive(Hash)]` and every field must be hashable (i.e., convertible to `felt252`).

> **Limitation:** You cannot derive `Hash` on a struct that contains `Array<T>` or `Felt252Dict<T>`, even if `T` is hashable. For those cases use Approach B.

### Approach B — serialize + loop

```cairo
let mut serialized: Array<felt252> = ArrayTrait::new();
Serde::serialize(@record, ref serialized);

let first = *serialized.at(0);
let mut state = PedersenTrait::new(first); // first field as base

let mut i: usize = 1;
loop {
    if i >= serialized.len() { break; }
    state = state.update(*serialized.at(i));
    i += 1;
};

let hash = state.finalize();
```

Here the struct is flattened to a `felt252` array via `Serde::serialize`, and then hashed field-by-field. This approach works even when you cannot derive `Hash`.

> **Important:** The two approaches produce **different hash values** because they use a different base state (0 vs the first field). Choose one approach and use it consistently.

---

## 7. File Structure

```
Muhammad_Abdullah_Zahid_Pedersen_Hash_Example/
├── Scarb.toml       ← Scarb project manifest
├── guide.md         ← this file
└── src/
    └── lib.cairo    ← all Cairo source code + tests
```

### `lib.cairo` contents

| Function | Purpose |
|---|---|
| `hash_single_value(value)` | Hash a single `felt252` |
| `hash_two_values(a, b)` | Hash two `felt252` values in sequence |
| `hash_struct_with_base(record)` | Hash a `UserRecord` struct with `update_with` |
| `hash_struct_field_by_field(record)` | Hash a `UserRecord` by serializing it first |
| `main()` | Runs all examples and prints results |
| `tests` module | Unit tests verifying determinism and collision resistance |

---

## 8. How to Run

Make sure you have **Scarb** installed (`scarb --version`). Then from the project root:

```bash
# Build
scarb build

# Run main
scarb cairo-run

# Run tests
scarb test
```

---

## 9. Key Concepts Demonstrated

1. **Determinism** — hashing the same value twice always gives the same result.  
2. **Avalanche effect** — changing even one field (e.g. `id: 1001` → `id: 1002`) produces a completely different hash.  
3. **Order matters** — `hash(a, b) ≠ hash(b, a)`.  
4. **Base state matters** — Pedersen's base state is part of the hash computation; different base states yield different hashes for the same input.  
5. **Struct hashing** — two valid approaches (derive-based and serialize-based) and why they produce different outputs.

---

## 10. Real-World Applications

- **Merkle trees** — Pedersen is used to build Merkle proofs on Starknet (e.g. in older SNIP standards).
- **Commitments** — commit to a secret value `s` by publishing `hash(s, nonce)`, then reveal later.
- **Storage keys** — `LegacyMap<K, V>` hashes `K` with Pedersen to derive the storage slot address.
- **Contract addresses** — Starknet uses Pedersen internally when computing a contract's on-chain address.

---

## 11. References

- [Cairo Book — Working with Hashes](https://book.cairo-lang.org/ch11-04-hash.html)
- [Cairo Book — Pedersen Builtin](https://www.starknet.io/cairo-book/ch204-02-01-pedersen.html)
- [Starknet Docs — Contract Address](https://docs.starknet.io/architecture-and-concepts/smart-contracts/contract-address/)
- [Wikipedia — Pedersen Hash](https://en.wikipedia.org/wiki/Pedersen_commitment)
