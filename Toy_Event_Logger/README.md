# Toy Event Logger

**Topic:** Events & Storage in Cairo Smart Contracts
**Language:** Cairo 2.x
**Build Tool:** Scarb

---

## What This Project Does

A Starknet smart contract that acts as an on-chain diary for toy-related events.
Any wallet can record that something happened to a toy — played with, lost, broken, gifted — and the entry is stored permanently on-chain.
Every entry also fires a Starknet **event** so block explorers and indexers can track the full history.

---

## Project Structure

```
Toy_Event_Logger/
├── Scarb.toml              ← Project manifest (name, version, dependencies)
├── README.md               ← This file
├── guide.md                ← Full topic deep-dive and concept explanations
└── src/
    ├── lib.cairo           ← Root module (declares sub-modules)
    └── toy_event_logger.cairo  ← Main contract code
```

---

## Key Concepts Covered

| Concept | Location in Code |
|---|---|
| `#[storage]` and `Map<K,V>` | `Storage` struct in `toy_event_logger.cairo` |
| `#[event]` and `emit()` | `ToyEventLogged`, `LogReset` events |
| Structs with `#[derive]` | `ToyEvent` struct |
| `#[starknet::interface]` | `IToyEventLogger` trait |
| Constructor | `fn constructor(...)` |
| Access control with `assert` | `reset_log()` function |
| `get_caller_address()` | Used in `log_event` and `reset_log` |
| `get_block_timestamp()` | Timestamp field in `ToyEvent` |

---

## How to Build

```bash
# Install Scarb (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# From the project root (where Scarb.toml lives):
scarb build
```

Compiled output will appear in `target/dev/`.

---

## Contract Functions

### Write Functions (change state)

```
log_event(toy_name, event_type, notes)   → logs an event, emits ToyEventLogged
reset_log()                              → owner only, wipes all logs
```

### Read Functions (free, no gas)

```
get_event_count()                        → u64
get_event(index)                         → ToyEvent
get_last_event_by(address)              → ToyEvent
```

---

## Assignment Rules Followed

- [x] Unique assignment completed individually
- [x] Written in Cairo programming language
- [x] Includes `guide.md` with detailed topic description
- [x] Includes starter `.cairo` file with comments
- [x] Code is syntactically correct and runs with Scarb
- [x] Follows Cairo naming conventions (snake_case functions, PascalCase types)
