# Guide — Toy Event Logger
### Topic: Events & Storage in Cairo Smart Contracts

---

## 1. What Is Cairo?

Cairo is a programming language designed specifically for writing provable programs — programs whose correct execution can be verified mathematically using zero-knowledge proofs. Starknet is a Layer 2 blockchain on Ethereum that uses Cairo as its smart contract language.

Unlike Solidity (Ethereum's language), Cairo:
- Is statically and strongly typed
- Has no null or undefined values
- Uses a "felt252" (252-bit field element) as its fundamental number type
- Requires explicit ownership / copy semantics (similar to Rust)
- Compiles to CASM (Cairo Assembly) → then to Sierra → then deployed on Starknet

---

## 2. What Are Smart Contracts?

A smart contract is a program that lives on a blockchain. Once deployed:
- Its code **cannot be changed** (immutable)
- It runs identically for **every node** on the network
- Calling its write functions costs **gas** (a fee)
- Calling its read functions is **free** (no transaction needed)

In Cairo/Starknet, a contract is written inside `#[starknet::contract] mod MyContract { }`.

---

## 3. Storage — Persisting Data On-Chain

```cairo
#[storage]
struct Storage {
    event_count: u64,
    events: starknet::storage::Map<u64, ToyEvent>,
    owner: ContractAddress,
}
```

- `#[storage]` marks the struct that holds **all persistent state**.
- Every field in `Storage` is written to and read from the Starknet State Trie — a global key-value database.
- Reading uses `.read()` and writing uses `.write()`.
- `Map<K, V>` is a hash map where every possible key exists by default with a zero value. You must track which keys you have actually written to yourself (that is why we have `event_count` and `has_logged`).

**Cost model:**

| Operation | Gas cost |
|---|---|
| Reading a storage slot | Low |
| Writing a storage slot | High |
| Reading a Map slot | Low |
| Writing a Map slot | High |

---

## 4. Events — Broadcasting What Happened

```cairo
#[event]
#[derive(Drop, starknet::Event)]
enum Event {
    ToyEventLogged: ToyEventLogged,
}

#[derive(Drop, starknet::Event)]
struct ToyEventLogged {
    #[key]
    index: u64,
    logged_by: ContractAddress,
    toy_name: felt252,
}
```

Events are **not stored** in the contract's storage. They are appended to the **transaction receipt** — a record of what happened during a transaction.

**Why use events?**
1. **Cheaper than storage** — emitting an event costs far less gas than writing a storage slot.
2. **Off-chain indexing** — services like Apibara or The Graph watch for events and store them in fast databases, enabling efficient queries.
3. **Transparency** — block explorers display events on every transaction, making contract activity human-readable.

`#[key]` fields are indexed — they let indexers filter events without scanning every receipt.

**Emitting an event:**
```cairo
self.emit(Event::ToyEventLogged(ToyEventLogged {
    index,
    logged_by: caller,
    toy_name,
}));
```

---

## 5. Structs and Derive Macros

```cairo
#[derive(Drop, Serde, starknet::Store, Copy)]
struct ToyEvent {
    toy_name: felt252,
    event_type: felt252,
    notes: felt252,
    logged_by: ContractAddress,
    timestamp: u64,
}
```

Structs group related data into a single type. The `#[derive(...)]` attribute automatically generates trait implementations:

| Trait | What it does |
|---|---|
| `Drop` | Allows Cairo to silently discard the value when it goes out of scope |
| `Serde` | Enables serialisation/deserialisation — required for ABI (external calls) |
| `starknet::Store` | Allows the struct to be written to and read from a storage `Map` |
| `Copy` | Allows the value to be duplicated without moving ownership |

Without `starknet::Store`, you cannot use a struct as the value type in a `Map`.

---

## 6. Interfaces — The Contract's Public API

```cairo
#[starknet::interface]
trait IToyEventLogger<TContractState> {
    fn log_event(ref self: TContractState, toy_name: felt252, ...);
    fn get_event_count(self: @TContractState) -> u64;
}
```

- An interface lists function signatures **without implementations**.
- Starknet compiles the interface into the **ABI** (Application Binary Interface) — the JSON spec that wallets, dApps, and other contracts use to call your contract.
- `ref self: TContractState` — mutable reference; used for **write** functions.
- `self: @TContractState` — immutable snapshot; used for **read-only** functions.

---

## 7. Constructor — One-Time Initialisation

```cairo
#[constructor]
fn constructor(ref self: ContractState) {
    self.owner.write(get_caller_address());
    self.event_count.write(0);
}
```

- Runs **exactly once** when the contract is deployed.
- `get_caller_address()` at deployment time returns the wallet deploying the contract — making them the owner.

---

## 8. Access Control — Who Can Do What

```cairo
fn reset_log(ref self: ContractState) {
    let caller = get_caller_address();
    let owner = self.owner.read();
    assert(caller == owner, 'Only owner can reset');
}
```

- `assert(condition, message)` — if false, the transaction **reverts** (all state changes undo).
- This is the standard permission-check pattern in Cairo.

---

## 9. felt252 — Cairo's Base Type

`felt252` is a **252-bit field element** — Cairo's fundamental numeric type.

- Integers from `0` to `P-1` where P is a large prime.
- Short ASCII strings are automatically converted: `'Lego'` becomes a felt252.
- Max ~31 ASCII characters per felt252.
- For longer text, use `ByteArray` (Cairo 2.4+).

---

## 10. ContractAddress

`ContractAddress` is Starknet's native address type — a 251-bit number identifying either a user wallet or a deployed contract. Functions like `get_caller_address()` return a `ContractAddress`.

---

## 11. Block Timestamp

```cairo
let timestamp: u64 = get_block_timestamp();
```

Returns the Unix timestamp (seconds since 1 Jan 1970) of the current block. Reliable for logging; avoid for high-precision timing.

---

## 12. Full Data Flow

```
User calls log_event('Lego', 'played', 'garden')
  │
  ▼
Cairo VM executes:
  1. get_caller_address()   → 0xABC...
  2. get_block_timestamp()  → 1718000000
  3. event_count.read()     → 5
  4. events.write(5, ToyEvent{...})
  5. last_event_index_by.write(0xABC, 5)
  6. has_logged.write(0xABC, true)
  7. event_count.write(6)
  8. emit(ToyEventLogged{index:5, ...})
  │
  ▼
Storage updated permanently on Starknet
ToyEventLogged appears in transaction receipt
Off-chain indexers pick it up → block explorer shows it
```

---

## 13. Common Errors and Fixes

| Error | Cause | Fix |
|---|---|---|
| `Index out of bounds` | index >= event_count | Check `get_event_count()` first |
| `Address has never logged` | `get_last_event_by` on unknown address | Only call after address has logged |
| `Only owner can reset` | Non-owner called `reset_log` | Only deployer wallet can call this |
| felt252 string too long | ASCII > 31 characters | Shorten or use `ByteArray` |
| Missing `starknet::Store` | Struct in Map without the derive | Add `starknet::Store` to `#[derive(...)]` |

---

## 14. Extension Ideas (for extra marks)

- Add `toy_id: u32` and filter events per toy
- Add event categories as an enum: `Played`, `Broken`, `Lost`, `Found`, `Gifted`
- Emit a `MilestoneReached` event at 10, 50, 100 total events
- Add `transfer_ownership(new_owner)` for the owner role
- Soft-delete with a `deleted: bool` flag on `ToyEvent`

---

## 15. References

- [The Cairo Book](https://book.cairo-lang.org/)
- [Starknet Docs — Contract Storage](https://docs.starknet.io/architecture-and-concepts/smart-contracts/contract-storage/)
- [Scarb — Cairo Build Tool](https://docs.swmansion.com/scarb/)
- [OpenZeppelin Cairo Contracts](https://github.com/OpenZeppelin/cairo-contracts)
- [Starknet Foundry — Testing](https://foundry-rs.github.io/starknet-foundry/)
