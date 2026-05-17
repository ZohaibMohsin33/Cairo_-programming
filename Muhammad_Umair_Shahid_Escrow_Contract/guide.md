# Escrow Contract — Guide

**Student:** Muhammad Umair Shahid
**Topic:** Escrow Contract in Cairo (StarkNet)

---

## What is an Escrow?

An **escrow** is a financial arrangement where a neutral third party holds funds on behalf of two parties (a buyer and a seller) until a specific condition is met.

**Real-world example:** When you buy a house, the bank holds your money in escrow until ownership paperwork is complete, then releases it to the seller. If something goes wrong, the money is returned to you.

In blockchain/Web3, we replace the bank with a **smart contract** — code that automatically enforces the rules without needing to trust any institution.

---

## How This Contract Works

### Parties Involved

| Role | Responsibility |
|------|---------------|
| **Buyer** | Deposits funds into the contract |
| **Seller** | Delivers goods or service off-chain |
| **Arbiter** | Trusted neutral party who approves or cancels |

### Lifecycle / Flow

```
1. Deploy contract  →  set buyer, seller, arbiter addresses
2. Buyer calls deposit()  →  funds are locked in escrow
3. Seller delivers goods/service (off-chain)
4a. If delivery OK  →  Arbiter calls approve_release()  →  Seller gets paid
4b. If dispute     →  Arbiter calls cancel()            →  Buyer gets refund
```

Once the escrow is settled (approved or cancelled), it cannot be used again — `completed` is set to `true` permanently.

---

## Cairo & StarkNet Concepts Used

### `#[starknet::contract]`
Marks a module as a StarkNet smart contract. The Cairo compiler generates all the ABI (Application Binary Interface) boilerplate automatically.

### `#[storage]`
A special struct where all **persistent state** lives. Unlike regular variables, storage values survive between transactions and are stored on-chain. Each field maps to a unique storage slot.

### `#[constructor]`
Runs exactly once when the contract is deployed. Used here to set the buyer, seller, and arbiter addresses that govern the escrow.

### `#[starknet::interface]`
Defines the public API of the contract — a list of function signatures without implementations. Clients (frontends, other contracts) use this interface to know how to call the contract.

### `#[abi(embed_v0)]`
Tells the compiler to expose the implementation functions as part of the contract's ABI so they can be called from outside.

### `get_caller_address()`
A StarkNet built-in that returns the address of the account that sent the current transaction. Used for access control — e.g., only the arbiter can call `approve_release()`.

### `assert(condition, 'error message')`
Panics (reverts the transaction) if the condition is false. This is how Cairo enforces rules — if a rule is broken, nothing changes and the caller pays gas but gets no effect.

### Events (`#[event]`)
Emitted after state changes so off-chain apps (block explorers, frontends) can track what happened. Events are not stored in contract storage — they live in the transaction receipt.

### `u256`
A 256-bit unsigned integer type, the standard for token amounts in StarkNet (matching Ethereum's ERC-20 standard).

### `ContractAddress`
A StarkNet-specific type representing an on-chain address. Different from a plain integer — it carries semantic meaning and type safety.

---

## Storage Variables Explained

```
buyer     → who deposited the funds
seller    → who will receive the funds on approval
arbiter   → who decides the outcome
balance   → how much is currently locked in this escrow
completed → flag to prevent re-use after settlement
```

---

## Security Properties

| Property | How it's enforced |
|----------|------------------|
| Only buyer can deposit | `assert(caller == self.buyer.read())` |
| Only arbiter can release or cancel | `assert(caller == self.arbiter.read())` |
| No double-spend | `assert(!self.completed.read())` before any action |
| No zero-amount actions | `assert(amount > 0_u256)` |
| Distinct roles | Constructor checks all three addresses differ |

---

## What a Production Version Would Add

- **ERC-20 token transfer** — call an actual token contract to move funds (omitted here to keep the logic focused)
- **Timeout / deadline** — if the seller doesn't deliver by a certain block, the buyer can cancel without the arbiter
- **Partial releases** — release a portion of funds as milestones are completed
- **Multi-sig arbiter** — require 2-of-3 approvals instead of a single arbiter

---

## Cairo Book References

- [Starknet Smart Contracts](https://book.cairo-lang.org/ch100-00-introduction-to-smart-contracts.html)
- [Storage](https://book.cairo-lang.org/ch101-01-contract-storage.html)
- [Events](https://book.cairo-lang.org/ch101-03-contract-events.html)
- [Contract Interfaces](https://book.cairo-lang.org/ch101-02-contract-functions.html)
- [Access Control patterns](https://book.cairo-lang.org/ch103-00-building-advanced-starknet-smart-contracts.html)
