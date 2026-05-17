# Mapping-like Storage on Starknet

**Author:** Muhammad Abdullah Waheed  
**Tooling:** Cairo (`edition = "2025_12"`), Scarb, `starknet` 2.18.x  

---

## 1. What “mapping-like storage” means

On Ethereum, `mapping(K => V)` ties keys to values in contract storage.

On Starknet, the usual pattern is a **`Map<K, V>`** inside the contract `#[storage]` struct:

- Declare `my_map: Map<K, V>`.
- **Write:** `self.my_map.write(key, value)`.
- **Read:** `self.my_map.read(key)`.
- Missing keys behave like zero-initialization (for `u256`, reads return `0` before any write).

This contract uses two maps:

1. `values_by_account: Map<ContractAddress, u256>` — same idea as `mapping(address => uint256)`.  
2. `catalog: Map<u256, u256>` — numeric id to value (e.g. record or product id).

A non-map field `admin: ContractAddress` sits alongside them to show how single slots and maps share one storage layout.

---

## 2. Contract layout (`src/lib.cairo`)

- **`#[starknet::interface]`** — public ABI (`trait IMappingLikeStorage`).
- **`#[abi(embed_v0)]`** — exposes the trait implementation on-chain.
- **`#[starknet::contract]`** — storage, constructor, and functions. Targets Scarb 2.18 / Cairo 2.18.

### Access

| Function | Caller | Effect |
|----------|--------|--------|
| `set_my_value` | any account | sets `values_by_account[caller]` |
| `get_value_for` | anyone | reads `values_by_account[account]` |
| `admin_set_value_for` | admin only | sets `values_by_account[account]` |
| `admin_set_catalog_entry` | admin only | sets `catalog[item_id]` |
| `get_catalog_entry` | anyone | reads `catalog[item_id]` |

Admin checks use `get_caller_address()` vs `self.admin.read()`, similar to `msg.sender` checks elsewhere.

---

## 3. Storage addressing (intuition)

`Map` cells are derived from the map’s base location and the serialized key; you do not pick raw addresses by hand. Each key you write updates only that entry.

---

## 4. Layout and build

```
Muhammad_Abdullah_Waheed_Mapping_like_Storage/
├── Scarb.toml
├── README.md
├── guide.md
└── src/
    └── lib.cairo
```

```bash
scarb build
```

Build outputs land under `target/` (ignored by git).

---

## 5. What this project demonstrates

- Starknet **`Map`** usage in `#[storage]` with two key types.
- Separating **public** writes (per-caller slot) from **admin-only** writes.
- A minimal **`Scarb.toml`** Starknet contract target.

---

## 6. References

- Cairo Book — https://book.cairo-lang.org/  
- Scarb — https://docs.swmansion.com/scarb/
