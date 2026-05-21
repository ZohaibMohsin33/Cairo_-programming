# Pedersen Hash in Cairo

**Student:** Hafiza Anila Javed  
**Topic:** Hash in Contract - Pedersen Hash  
**Language:** Cairo 2  

---

## What is Pedersen Hash?

Pedersen Hash is a cryptographic hash function used in Cairo and Starknet. It takes input values and converts them into a fixed-size output called a **hash**. It is based on elliptic curve mathematics and is designed to work efficiently inside zero-knowledge proofs.

---

## Key Properties

| Property | Meaning |
|---|---|
| **Deterministic** | Same input always gives same output |
| **One-way** | Cannot reverse the hash to get original input |
| **Non-commutative** | `H(a, b)` is different from `H(b, a)` |
| **Collision-resistant** | Two different inputs cannot produce same hash |

---

## How It Works

Pedersen Hash uses points on an elliptic curve called the **Stark curve**. The formula is:

```
H(a, b) = [a] * G0 + [b] * G1
```

Where `G0` and `G1` are fixed points on the curve. The result is the x-coordinate of the final point.

For more than 2 values, it uses **chaining**:
```
H(a, b, c) = H(H(a, b), c)
```

---

## Cairo API

```cairo
use core::hash::HashStateTrait;
use core::pedersen::PedersenTrait;

// Hash two values
let hash = PedersenTrait::new(a).update(b).finalize();

// Hash a single value
let hash = PedersenTrait::new(0).update(value).finalize();

// Hash a struct
let hash = PedersenTrait::new(0).update_with(my_struct).finalize();
```

---

## Code Overview

This program demonstrates 6 demos:

| Demo | What it shows |
|---|---|
| Demo 1 | Hash two values: `Pedersen(100, 200)` |
| Demo 2 | Non-commutativity: `H(a,b) != H(b,a)` |
| Demo 3 | Hash a single value: `Pedersen(0, 42)` |
| Demo 4 | Hash a struct (UserRecord) |
| Demo 5 | Determinism: same input = same output |
| Demo 6 | Hash chaining: `H(H(100,200), 300)` |

---

## How to Run

Make sure your `Scarb.toml` contains:

```toml
[package]
name = "pedersen_hash"
version = "0.1.0"
edition = "2024_07"

[dependencies]
cairo_execute = "2.18.0"

[cairo]
enable-gas = false

[[target.executable]]
```

Then run:

```bash
scarb execute
```

---

## Use Cases in Starknet

- **Contract address generation** - every contract address is derived using Pedersen hash
- **Storage keys** - LegacyMap uses Pedersen to compute storage slot addresses
- **Merkle trees** - used to verify membership proofs in airdrops and whitelists
- **Commitment schemes** - commit to a value without revealing it

---

## References

- [Cairo Book](https://book.cairo-lang.org)
- [Scarb Docs](https://docs.swmansion.com/scarb/)
- [Starknet Docs](https://docs.starknet.io)
- [Cairo Playground](https://play.cairo-lang.org)
