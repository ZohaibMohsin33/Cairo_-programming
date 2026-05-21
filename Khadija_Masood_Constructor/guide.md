# Constructor in Cairo — Guide

## Overview
A constructor in a Cairo Starknet contract runs exactly once during deployment. It is used to initialize storage variables and set up the initial state of the contract. After deployment, the constructor can never be called again.

In this assignment, the contract uses a constructor to:
- set the `owner` to the deployer address,
- store an initial `value`,
- store a short `name` identifier.

## Why constructors matter
Because Cairo contracts persist state on-chain, every storage variable must have a known initial value. The constructor is the safest and most explicit place to initialize that state. This prevents accidental use of default values and establishes access control (for example, recording who the owner is).

## Storage layout
The contract defines three storage variables:
- `owner: ContractAddress` — the address that deployed the contract.
- `value: u128` — an example numeric state value.
- `name: felt252` — a label or short identifier stored as a felt.

## Constructor behavior
Signature:
```
constructor(ref self: ContractState, initial_value: u128, name: felt252)
```
Steps performed:
1. Reads the caller address with `get_caller_address()`.
2. Writes that address to `owner`.
3. Stores `initial_value` into `value`.
4. Stores `name` into `name`.

Because this runs at deployment time, the caller is the deployer account.

## External functions
- `set_value(new_value: u128)`
  - Only the owner can call this.
  - Uses `assert` to enforce access control.
- `get_owner()`
  - Read-only accessor for `owner`.
- `get_value()`
  - Read-only accessor for `value`.
- `get_name()`
  - Read-only accessor for `name`.

## How to build
From inside the folder:
```
scarb build
```

## How to deploy (local devnet)
This follows a typical Starknet devnet flow. It assumes you already have sncast and starknet-devnet set up.

1. Start devnet:
```
starknet-devnet --seed=0
```

2. Declare the contract:
```
sncast --profile=devnet declare --contract-name=ConstructorContract
```

3. Deploy with constructor calldata (example values):
```
sncast --profile=devnet deploy \
  --class-hash=<class_hash_from_declare> \
  --constructor-calldata="123" "MyContract"
```

## Key concepts learned
- Constructors run once and initialize storage.
- `get_caller_address()` gives the deployer during construction.
- Storage writes inside the constructor define the initial state.
- Access control can be built by storing and checking the `owner`.

## References
- The Cairo Book — Starknet contracts and storage
- Starknet documentation — contract deployment and constructors
