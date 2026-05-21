# Cairo Interfaces (Traits)

## What Even Are Interfaces?

So imagine you're working in a team and everyone needs to follow certain rules — like "every smart contract MUST have a transfer function" or "every token MUST be able to return its balance." Interfaces are basically that agreement in code.

In Cairo, we don't call them "interfaces" like in Solidity. Instead, Cairo uses **traits** to do the same job — and honestly, they're cleaner.

---

## The Basic Idea

A trait says: *"whoever implements me, MUST have these functions."*

It doesn't care HOW you do it. Just that you do it.

```cairo
trait Animal {
    fn speak(self: @ContractState) -> felt252;
    fn move(self: @ContractState);
}
```

Any struct that says `impl Dog of Animal` now HAS to define `speak` and `move`. No shortcuts. The compiler will yell at you if you skip one.

---

## Why Should You Care?

- **Consistency** — every contract following the same trait behaves predictably
- **Reusability** — write the interface once, implement it anywhere
- **Security** — in blockchain, you NEED guarantees. Traits give you that.
- **Interoperability** — other contracts can interact with yours without knowing your internals, just your interface

---

## Traits in Starknet Contracts

In real Starknet development, you'll see this pattern everywhere:

```cairo
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_count(self: @TContractState) -> u32;
    fn increment(ref self: TContractState);
    fn reset(ref self: TContractState);
}
```

The `#[starknet::interface]` attribute tells Cairo: this trait is meant to be the public face of a smart contract. Other contracts and frontends will use this to talk to your contract.

---

## self vs ref self — What is the Difference?

This confused me at first too, so let me explain it simply:

| Keyword | Meaning |
|---|---|
| `self: @TContractState` | Read-only. Just looking, not touching. |
| `ref self: TContractState` | Can modify state. Writing to blockchain. |

Think of `@` as "I am just reading the menu" and `ref` as "I am actually ordering and changing things."

---

## What I Built

I built a simple Counter Contract that demonstrates interfaces in Cairo.

It has three functions exposed through a trait:
- `get_count` — returns the current count
- `increment` — adds 1 to the count
- `reset` — sets count back to zero

This shows how a trait defines the contract and the implementation fulfills it.

---

## Real World Use Case

Imagine you are building a DeFi protocol. You define one interface:

```cairo
#[starknet::interface]
trait IERC20<TContractState> {
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
}
```

Now ANY token contract — whether it is USDC, ETH, or your custom token — that implements this interface can be used interchangeably in your protocol. You do not care what token it is. You just call `transfer` and it works. That is the power of interfaces.

---

## How Interfaces Help With Security

In traditional programming, you might just trust that a function exists. In blockchain, trust is everything — and you cannot afford to be wrong. Interfaces enforce at the compiler level that a contract will behave as expected. If a function is missing, the code will not even compile. No runtime surprises. No exploits from missing functions.

---

## How to Run It

Make sure you have Scarb installed, then:

```bash
scarb build
```

If it compiles without errors, the interface is correctly implemented.

---

## Key Takeaways

- Traits in Cairo = Interfaces in Solidity, but cleaner
- They define WHAT a contract must do, not HOW
- `@TContractState` means read-only, `ref TContractState` means write
- The `#[starknet::interface]` attribute marks a trait as a contract interface
- Every serious Starknet contract uses this pattern
- They make your code consistent, reusable, and secure

---

## Resources I Used

- Cairo Book: https://book.cairo-lang.org
- Starknet Docs: https://docs.starknet.io
- Cairo by Example: https://cairo-by-example.com
