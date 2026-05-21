# Mapping like Storage Contract in Cairo

Cairo is a programming language developed by StarkWare Industries for writing provable programs on StarkNet — a decentralized Layer 2 network built on top of Ethereum. Unlike traditional smart contract languages like Solidity, Cairo is built around ZK-STARKs (Zero-Knowledge Scalable Transparent ARguments of Knowledge), which means every program execution can be mathematically verified without exposing private data.

Cairo 1.x, the modern version, has a syntax close to Rust, which makes it safer and more structured than the original Cairo 0. Every StarkNet smart contract is written in Cairo, and understanding how data is stored on-chain is one of the first things you need to get right.

---

## What is a Mapping?

A mapping stores data as **key → value** pairs. You give it a key, and you get back a value. It is one of the most commonly used data structures in smart contract development because most on-chain logic revolves around looking things up — checking a balance, finding the owner of a token, seeing if an address has voted.

Other languages have the same idea under different names:

| Language | Name |
|----------|------|
| Python | Dictionary (`dict`) |
| Rust | `HashMap` |
| Solidity | `mapping` |
| Java | `HashMap` |
| Cairo | `LegacyMap` |

A good way to picture it: imagine a locker system. Each locker has a unique number (the key), and inside is whatever was stored there (the value). You can only open one locker at a time, and you must know the exact number to open it. There is no way to look at all lockers at once.

```
Key              →     Value
-----------            -------
Wallet Address   →     Token Balance
Student ID       →     Grade
User Address     →     Has Voted (true/false)
Token ID         →     Owner Address
```

---

## Storage in Cairo Contracts

In a Cairo contract, all persistent on-chain data is declared inside a special block called `#[storage]`. Anything you put there gets saved to the blockchain and survives across transactions. A mapping is just one kind of variable you can declare inside storage.

The mapping type is called `LegacyMap` and uses this syntax:

```cairo
#[storage]
struct Storage {
    mapping_name: LegacyMap::<KeyType, ValueType>,
}
```

A few real examples showing different key and value types:

```cairo
use starknet::ContractAddress;

#[storage]
struct Storage {
    balances:   LegacyMap::<ContractAddress, u256>,
    has_voted:  LegacyMap::<ContractAddress, bool>,
    scores:     LegacyMap::<u32, u8>,
    names:      LegacyMap::<u32, felt252>,
}
```

Each of these stores a different kind of relationship. `balances` maps a wallet address to a token amount. `has_voted` maps a wallet to a yes/no flag. `scores` maps a numeric ID to an 8-bit score. All four live in the same storage struct and do not interfere with each other.

---

## How Storage Actually Works

StarkNet's storage is a large table of `(contract address, slot) → value` pairs. Each storage variable in your contract occupies its own unique slot. For a mapping, the slot is not fixed — it is calculated dynamically for each key using a **Pedersen Hash**:

```
storage_slot = pedersen_hash("balances", wallet_address)
```

This means the storage slot for `balances[address_A]` is completely different from `balances[address_B]`, and neither collides with any other mapping in the contract. Every `(mapping name, key)` combination has its own guaranteed-unique slot on-chain.

### Default Values

If you read a key that was never written, Cairo returns the zero/default value for that type rather than throwing an error:

| Type | Default Value |
|------|--------------|
| `u8, u16, u32, u64, u128, u256` | `0` |
| `bool` | `false` |
| `felt252` | `0` |
| `ContractAddress` | Zero address |

This means every possible key technically "exists" — it just returns zero until something is written to it. Keep this in mind when writing logic that depends on whether a key was ever set.

---

## Reading and Writing

You interact with a mapping using `.read()` and `.write()`. Both take the key as an argument.

### Writing a value

```cairo
self.balances.write(user_address, 1000_u256);
self.has_voted.write(voter_address, true);
self.scores.write(1_u32, 95_u8);
```

### Reading a value

```cairo
let balance = self.balances.read(user_address);
let voted   = self.has_voted.read(voter_address);
let score   = self.scores.read(1_u32);
```

The type returned by `.read()` matches whatever `ValueType` was declared in the mapping. You do not need to cast it.

---

## A Practical Example — Transfer Function

Here is a transfer function that uses the balances mapping to move tokens from one address to another:

```cairo
fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) {
    let caller = get_caller_address();

    let sender_balance = self.balances.read(caller);
    assert(sender_balance >= amount, 'Insufficient balance');

    let receiver_balance = self.balances.read(to);

    self.balances.write(caller, sender_balance - amount);
    self.balances.write(to, receiver_balance + amount);
}
```

The pattern here is: read current values into local variables, validate, then write the updated values back. Reading into a local variable first also means you are not hitting storage twice for the same key, which matters for transaction fees.

---

## Supported Key and Value Types

### Key Types

| Type | Description | Common Use |
|------|-------------|------------|
| `ContractAddress` | Wallet or contract address | Token balances, access control |
| `felt252` | Cairo's native 252-bit field element | General purpose |
| `u8` | 8-bit unsigned integer (0–255) | Subject IDs, small indices |
| `u16` | 16-bit unsigned integer | Medium indices |
| `u32` | 32-bit unsigned integer | Student IDs, item IDs |
| `u64` | 64-bit unsigned integer | Timestamps, large IDs |
| `u128` | 128-bit unsigned integer | Large numerical keys |
| `u256` | 256-bit unsigned integer | NFT token IDs |
| `(T1, T2)` | Tuple of two types | Composite / nested keys |

### Value Types

The value can be any type that implements Cairo's `Store` trait. This includes all integer types, `bool`, `felt252`, `ContractAddress`, and custom structs as long as they also implement `Store`.

---

## Tuple Keys — Nested Mappings

Solidity allows nested mappings like `mapping(address => mapping(uint => uint))`. Cairo does not have that syntax. Instead, you combine multiple keys into a single **tuple key**, which achieves the same result:

### Solidity (for comparison):
```solidity
mapping(address => mapping(uint256 => uint256)) public subjectGrades;
```

### Cairo equivalent:
```cairo
#[storage]
struct Storage {
    subject_grades: LegacyMap::<(ContractAddress, u8), u8>,
}
```

Access looks like this:

```cairo
self.subject_grades.write((student_addr, 1_u8), 90_u8);
let grade = self.subject_grades.read((student_addr, 1_u8));
```

Internally, Cairo hashes both parts of the tuple together to form a single unique storage slot, so the behavior is identical to a nested mapping — just written differently.

You can also go three levels deep with a three-part tuple:

```cairo
permissions: LegacyMap::<(ContractAddress, ContractAddress, u8), bool>,
```

This could represent `(owner, operator, token_type) → is_approved`, which is the kind of structure used in multi-token standards.

---

## Multiple Mappings in One Contract

Most real contracts use several mappings together. Here is what a basic token contract's storage might look like:

```cairo
#[storage]
struct Storage {
    balances:     LegacyMap::<ContractAddress, u256>,
    allowances:   LegacyMap::<(ContractAddress, ContractAddress), u256>,
    owners:       LegacyMap::<u256, ContractAddress>,
    is_admin:     LegacyMap::<ContractAddress, bool>,
    total_supply: u256,
}
```

`balances` tracks how many tokens each address holds. `allowances` tracks how much one address is permitted to spend on behalf of another — this is the ERC-20 approve system. `owners` maps NFT token IDs to their current owner. `is_admin` is an access control flag. And `total_supply` is just a plain single value. A contract's storage can mix mappings and regular variables freely.

---

## Mappings vs Arrays vs Single Variables

It helps to know when to reach for a mapping versus an array or a plain variable:

| Feature | `LegacyMap` | Array | Single Variable |
|---------|-------------|-------|-----------------|
| Access by | Any key | Integer index only | Direct |
| Iterable | No | Yes | N/A |
| Default for missing key | Zero | Must push first | Must initialize |
| Storage cost | Per key written | Per element | Fixed |
| Best for | Lookups (balance, ownership) | Ordered lists | Counters, flags |
| Can check if key exists | No (returns 0) | Yes (check length) | N/A |

Use a mapping when you need fast lookups by an arbitrary key. Use an array when order matters or you need to loop through everything. Use a plain variable for a single piece of state like a counter or a flag.

---

## Limitations of Mappings

Mappings in Cairo have a few hard constraints that are worth understanding before you run into them:

**No iteration** — There is no way to loop through all the keys in a mapping. The blockchain stores individual slots but does not keep track of which keys were ever written. This is the same limitation as in Solidity.

**No length or count** — There is no built-in `.len()` or similar method. If you need to know how many entries exist, you have to track that yourself with a separate counter.

**No deletion** — You cannot remove an entry. The closest you can do is overwrite it with the zero value, but the slot still exists on-chain.

**No existence check** — Since an unwritten key returns `0` by default, you cannot distinguish between "this key was never set" and "this key was explicitly set to zero" without extra logic.

**Key must be known** — You can only retrieve a value if you already know the exact key. There is no search or filter operation.

### Workaround for Iteration

If you need to iterate over all entries, maintain a companion mapping that acts as an indexed list, alongside a counter variable:

```cairo
#[storage]
struct Storage {
    grades:        LegacyMap::<ContractAddress, u8>,
    student_list:  LegacyMap::<u32, ContractAddress>,
    student_count: u32,
}

fn add_student(ref self: ContractState, student: ContractAddress, grade: u8) {
    self.grades.write(student, grade);

    let count = self.student_count.read();
    self.student_list.write(count, student);
    self.student_count.write(count + 1);
}
```

Now you can iterate from index `0` to `student_count - 1` to get every address, then use those addresses to look up the actual grades. It is more verbose than a native iteration, but it works reliably.

---

## Mappings and Transaction Fees

On StarkNet, every storage write costs a fee paid in ETH or STRK. Reads are cheaper but still have a cost. A few practices make a noticeable difference:

**Read once, reuse.** If you need a value more than once in a function, read it into a local variable the first time and reuse that variable instead of calling `.read()` again.

```cairo
// Less efficient — reads from storage twice
if self.balances.read(addr) > 0 {
    let b = self.balances.read(addr);
    self.balances.write(addr, b - 1);
}

// Better — reads once, stores in a local variable
let balance = self.balances.read(addr);
if balance > 0 {
    self.balances.write(addr, balance - 1);
}
```

**Only write when the value changes.** Writing the same value back to storage wastes fees. Check whether the new value actually differs before writing, when that makes sense in your logic.

**Batch related changes.** If a single operation updates multiple related mappings — like a transfer updating both sender and receiver balances — do it all in one transaction rather than spreading it across multiple calls.

---

## Common Real-World Use Cases

### Token Balances (ERC-20 style)
```cairo
balances: LegacyMap::<ContractAddress, u256>
```
Every wallet address maps to how many tokens it holds. This is the most common mapping in any token contract.

### NFT Ownership (ERC-721 style)
```cairo
owners: LegacyMap::<u256, ContractAddress>
```
Every token ID maps to the address that currently owns it.

### Voting System
```cairo
has_voted:           LegacyMap::<ContractAddress, bool>
votes_for_candidate: LegacyMap::<felt252, u32>
```
Track which addresses have cast a vote, and how many votes each candidate has received.

### Access Control and Whitelists
```cairo
is_whitelisted: LegacyMap::<ContractAddress, bool>
role:           LegacyMap::<ContractAddress, u8>
```
A simple role system where `0` means no role, `1` means admin, `2` means moderator, and so on. The address is the key and the role number is the value.

### Allowances (ERC-20 approve)
```cairo
allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>
```
Maps `(owner, spender)` to how much the spender is allowed to transfer on the owner's behalf.

### Student Grade Book
```cairo
grades:         LegacyMap::<ContractAddress, u8>
subject_grades: LegacyMap::<(ContractAddress, u8), u8>
is_registered:  LegacyMap::<ContractAddress, bool>
```
A contract that tracks whether a student is registered, their overall grade, and their grade broken down per subject using a tuple key.

---

## Summary

| Concept | Detail |
|---------|--------|
| Type name | `LegacyMap::<KeyType, ValueType>` |
| Declared in | `#[storage]` struct |
| Write | `self.mapping.write(key, value)` |
| Read | `self.mapping.read(key)` |
| Default value | Zero / false for any unwritten key |
| Nested mappings | Use tuple keys: `(T1, T2)` |
| Iterable | No |
| Storage mechanism | Pedersen hash of (variable name + key) |
| Primary use cases | Balances, ownership, voting, access control |

---

## References

- [Cairo Book — Contract Storage](https://book.cairo-lang.org/ch14-01-contract-storage.html)
- [StarkNet Documentation](https://docs.starknet.io)
- [OpenZeppelin Cairo Contracts](https://github.com/OpenZeppelin/cairo-contracts)
- [Scarb Package Manager](https://docs.swmansion.com/scarb/)
- [StarkNet Foundry — Testing](https://foundry-rs.github.io/starknet-foundry/)
