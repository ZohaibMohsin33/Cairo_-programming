# ERC721 Basics — Complete Study Guide

## Table of Contents

1. [What is ERC721?](#1-what-is-erc721)
2. [How NFTs Differ from Fungible Tokens](#2-how-nfts-differ-from-fungible-tokens)
3. [Core ERC721 Concepts](#3-core-erc721-concepts)
4. [Storage Design](#4-storage-design)
5. [Events](#5-events)
6. [Key Functions Explained](#6-key-functions-explained)
7. [The Approval System](#7-the-approval-system)
8. [Minting and Burning](#8-minting-and-burning)
9. [Cairo-Specific Notes](#9-cairo-specific-notes)
10. [How to Build and Run with Scarb](#10-how-to-build-and-run-with-scarb)
11. [Security Considerations](#11-security-considerations)
12. [Real-World Use Cases](#12-real-world-use-cases)
13. [Glossary](#13-glossary)

---

## 1. What is ERC721?

**ERC721** is a token standard originally defined for Ethereum that describes how a smart contract should manage **Non-Fungible Tokens (NFTs)**. The "ERC" stands for *Ethereum Request for Comments*, and 721 is simply the proposal number.

Unlike regular (fungible) tokens where every unit is identical and interchangeable, each ERC721 token has a **unique ID** and can represent something one-of-a-kind — a piece of art, a game item, a real estate deed, a concert ticket, etc.

On **Starknet**, Cairo contracts implement the same interface so that wallets, marketplaces, and dApps written for any EVM-compatible NFT standard can interact with them in a familiar way.

---

## 2. How NFTs Differ from Fungible Tokens

| Property | Fungible Token (ERC20) | Non-Fungible Token (ERC721) |
|---|---|---|
| Unit identity | All units identical | Each token has a unique ID |
| Divisibility | Can be split (e.g. 0.5 tokens) | Whole units only |
| Transfer unit | Amount (e.g. 100 tokens) | Specific token ID |
| Interchangeability | Any unit = any other unit | No two tokens are equivalent |
| Example | Currency, governance token | Digital art, game item, ticket |

---

## 3. Core ERC721 Concepts

### Token ID

Every NFT has a `token_id` — a unique `u256` integer. The first token minted is typically ID `1`, the next is `2`, and so on. The zero ID (`0`) is conventionally reserved as a "null" or "non-existent" token sentinel.

### Ownership

The contract keeps a mapping: `token_id → owner_address`. Only one address can own a token at any time. When a token is transferred, this mapping is updated.

### Balance

The contract also tracks how many tokens each address owns: `owner_address → count`. This is updated on every mint, transfer, and burn.

### Approvals

ERC721 has two approval layers:
- **Single-token approval** (`approve`): The owner allows one specific address to transfer one specific token.
- **Operator approval** (`set_approval_for_all`): The owner allows one address to manage ALL of their tokens.

---

## 4. Storage Design

```
Storage {
    name: felt252                                        // Collection name
    symbol: felt252                                      // Ticker symbol
    owner: ContractAddress                               // Contract admin
    next_token_id: u256                                  // Auto-incrementing ID counter
    token_owner: Map<u256, ContractAddress>              // token_id → owner
    owner_balance: Map<ContractAddress, u256>            // owner → token count
    token_approvals: Map<u256, ContractAddress>          // token_id → approved spender
    operator_approvals: Map<(ContractAddress, ContractAddress), bool>  // (owner, operator) → bool
    token_uri_map: Map<u256, felt252>                    // token_id → metadata URI
}
```

Each field lives on-chain and costs gas (on Starknet, fees) to read/write. The `LegacyMap` type in Cairo is the native key-value store in contract storage.

---

## 5. Events

Events are the on-chain logs that inform wallets, explorers, and marketplaces about what happened without them needing to re-read all state.

### `Transfer`
```
Transfer { from: ContractAddress, to: ContractAddress, token_id: u256 }
```
Emitted every time ownership of a token changes:
- **Mint**: `from = 0x0`, `to = recipient`
- **Normal transfer**: `from = old_owner`, `to = new_owner`
- **Burn**: `from = old_owner`, `to = 0x0`

### `Approval`
```
Approval { owner: ContractAddress, approved: ContractAddress, token_id: u256 }
```
Emitted when a single-token approval is set or cleared.

### `ApprovalForAll`
```
ApprovalForAll { owner: ContractAddress, operator: ContractAddress, approved: bool }
```
Emitted when an operator-level approval is granted (`approved = true`) or revoked (`approved = false`).

---

## 6. Key Functions Explained

### `balance_of(account) → u256`
Returns how many NFTs the given `account` currently holds. Reverts if the address is zero.

### `owner_of(token_id) → ContractAddress`
Returns the current owner of the token. Reverts if the token doesn't exist (has never been minted, or has been burned).

### `transfer_from(from, to, token_id)`
Moves a token from `from` to `to`. The caller must be the owner, the approved address, or an approved operator. Steps:
1. Verify `token_id` exists.
2. Verify `from` is the actual owner.
3. Verify caller has permission.
4. Clear the single-token approval.
5. Update balances and ownership mapping.
6. Emit `Transfer`.

### `approve(to, token_id)`
Grants `to` permission to transfer this one token. Only the owner or their operator can call this. Cannot approve the owner to themselves.

### `set_approval_for_all(operator, approved)`
Grants or revokes `operator`'s ability to manage all tokens owned by the caller. Cannot set yourself as your own operator.

### `get_approved(token_id) → ContractAddress`
Returns the currently approved address for `token_id`, or the zero address if none.

### `is_approved_for_all(owner, operator) → bool`
Returns `true` if `operator` is approved to manage all of `owner`'s tokens.

---

## 7. The Approval System

The approval system is what allows NFT marketplaces to work. Here is the typical flow:

```
User ──approve()──► Marketplace Contract
                          │
                     transfer_from()
                          │
                      New Owner
```

1. The user calls `approve(marketplace_address, token_id)`.
2. The marketplace lists the NFT.
3. A buyer pays the marketplace.
4. The marketplace calls `transfer_from(user, buyer, token_id)`.
5. The token moves; the single-token approval is automatically cleared.

For batch listings, users use `set_approval_for_all(marketplace, true)` instead.

**Security note**: Approvals persist even if the token is transferred. Always clear approvals you no longer need. The `transfer_from` function in this implementation automatically clears the single-token approval on every transfer.

---

## 8. Minting and Burning

### Minting
- Creates a brand new token with the next available ID.
- Assigns ownership to the `recipient`.
- Increments the recipient's balance.
- Stores an optional metadata URI (e.g. `ipfs://Qm...`).
- Emits `Transfer` from the zero address.
- In this implementation, only the contract deployer (owner) can mint. In production, you might open minting to the public with payment logic.

### Burning
- Permanently destroys a token.
- Decrements the owner's balance.
- Clears ownership (sets to zero address).
- Clears approvals.
- Emits `Transfer` to the zero address.
- After burning, `owner_of(token_id)` will revert because the token no longer exists.

---

## 9. Cairo-Specific Notes

### `felt252`
Cairo's native field element type. Used here for the token name, symbol, and URI because they are short string-like values. In a production contract you might use `ByteArray` for longer strings.

### `u256`
A 256-bit unsigned integer, the same width as Solidity's `uint256`. Token IDs use this type to match the Ethereum standard.

### `ContractAddress`
Starknet's address type. The zero address (`contract_address_const::<0>()`) is used as a sentinel meaning "no owner" or "burned."

### `LegacyMap`
Cairo's built-in persistent key-value mapping stored in contract storage. Reading/writing costs STARK execution resources.

### `#[starknet::contract]`
The macro that marks a module as a deployable Starknet contract.

### `#[storage]`
Declares the persistent state struct. All fields here are written to the blockchain.

### `#[event]` / `#[derive(Drop, starknet::Event)]`
Marks an enum as the contract's event type. Individual variants (like `Transfer`) become the actual events emitted with `self.emit(...)`.

### `#[constructor]`
The function called once at deployment time. Receives initial parameters (name, symbol) and sets up the initial state.

### `#[abi(embed_v0)]`
Marks an implementation block as part of the contract's public ABI (the interface callable from outside).

### `#[generate_trait]`
Creates a trait automatically from an `impl` block, used here for internal helper functions that are not part of the public ABI.

---

## 10. How to Build and Run with Scarb

### Project Setup

Create a `Scarb.toml` in your project root:

```toml
[package]
name = "erc721_basics"
version = "0.1.0"
edition = "2024_07"

[dependencies]
starknet = ">=2.6.3"

[[target.starknet-contract]]
```

Place `erc721.cairo` at `src/erc721.cairo` and update `src/lib.cairo`:

```cairo
mod erc721;
```

### Build

```bash
scarb build
```

This compiles the Cairo contract to Sierra (an intermediate representation) and then to CASM (Cairo Assembly), producing artifacts in `target/dev/`.

### Run Tests (if you add a `#[cfg(test)]` module)

```bash
scarb test
```

### Deploy (to Starknet Sepolia testnet)

```bash
starkli declare target/dev/erc721_basics_ERC721Basics.contract_class.json
starkli deploy <CLASS_HASH> <name_felt> <symbol_felt>
```

---

## 11. Security Considerations

| Risk | Mitigation in this contract |
|---|---|
| Unauthorized transfer | `assert_approved_or_owner` checks caller permissions |
| Transfer to zero address | Explicit `assert(!to.is_zero())` check |
| Non-existent token query | `assert_token_exists` guard on read functions |
| Reentrancy | Cairo/Starknet's execution model is not susceptible to classic Solidity reentrancy |
| Unauthorized mint | `assert(caller == self.owner.read(), ...)` guard |
| Integer overflow | Cairo 2.x uses checked arithmetic by default |
| Stale approvals after transfer | `transfer_internal` always clears `token_approvals` on every transfer |

---

## 12. Real-World Use Cases

- **Digital Art (PFPs, 1/1 artwork)**: Each token represents a unique image stored on IPFS; the `token_uri` field points to the metadata JSON.
- **Gaming Items**: Swords, skins, characters — each with unique stats encoded in the URI or on-chain attributes.
- **Event Tickets**: Each ticket NFT has a seat number or access tier; the contract owner mints one per ticket sold.
- **Real Estate / Physical Assets**: Tokenized ownership of real-world items, where the token is the legal deed.
- **Domain Names**: Services like Starknet.id use NFTs to represent human-readable addresses.
- **Music & Royalties**: Artists mint NFTs tied to songs and program royalty splits into the contract.

---

## 13. Glossary

| Term | Definition |
|---|---|
| NFT | Non-Fungible Token — a unique, indivisible digital asset |
| ERC721 | The token standard defining the NFT interface |
| Token ID | A unique `u256` integer identifying each NFT |
| Mint | Creating a new token and assigning it to an address |
| Burn | Permanently destroying a token |
| Approve | Granting a specific address permission to transfer one token |
| Operator | An address approved to manage all tokens of an owner |
| Transfer | Moving ownership of a token from one address to another |
| Metadata URI | A link (e.g. IPFS) pointing to off-chain JSON describing the token |
| felt252 | Cairo's native field element; used for short strings and identifiers |
| Scarb | Cairo's official build tool and package manager |
| Starknet | A ZK-rollup Layer 2 network where Cairo contracts run |
| Zero Address | `0x0` — used as a sentinel meaning "null" or "no owner" |
| ABI | Application Binary Interface — the public contract API |
| Sierra | Cairo's intermediate representation after compilation |
| CASM | Cairo Assembly — the final low-level bytecode executed on Starknet |
