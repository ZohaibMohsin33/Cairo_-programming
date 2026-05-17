# NFT Ownership Tracker

## Introduction

This project is a smart contract written in Cairo for the Starknet blockchain. The contract tracks NFT ownership using blockchain storage mappings.

---

## What is Cairo?

Cairo is a programming language used for developing Starknet smart contracts.

---

## What is Starknet?

Starknet is a Layer 2 blockchain built on Ethereum that provides faster and cheaper transactions.

---

## Project Features

- Mint NFTs
- Transfer NFT ownership
- Check NFT owner
- Prevent duplicate NFT minting
- Emit blockchain events

---

## Storage Variables

### nft_owner

Stores NFT owner addresses.

```text
token_id -> owner_address
```

### nft_exists

Checks whether an NFT exists.

```text
token_id -> true/false
```

---

## Functions

### mint()

Creates a new NFT and assigns ownership.

### transfer()

Transfers NFT ownership to another user.

### get_owner()

Returns the current NFT owner.

### nft_exists()

Checks whether an NFT exists.

---

## Events

### NFTMinted

Triggered when a new NFT is created.

### NFTTransferred

Triggered when NFT ownership changes.

---

## Assertions

Assertions are used to prevent invalid operations.

Example:

```rust
assert(!exists, 'NFT already exists');
```

---

## Build and Test

Build project:

```bash
scarb build
```

Run tests:

```bash
scarb test
```

---

## Conclusion

This project demonstrates Cairo smart contract development using storage mappings, events, assertions, and NFT ownership tracking on Starknet.