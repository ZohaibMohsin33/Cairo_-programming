# View Functions in Cairo

## Introduction

View functions are special functions in Cairo smart contracts that allow users to read blockchain data without modifying the contract state.

These functions are commonly used by frontend applications to display blockchain information.

Examples:
- Reading balances
- Checking stored data
- Fetching user profiles
- Viewing transaction-related information

---

# Objective of this Assignment

The purpose of this assignment is to understand:

- Storage handling in Cairo
- Read-only functions
- Difference between mutable and immutable contract access
- Returning values from storage
- Returning structures from view functions

---

# What is a View Function?

A view function is a read-only function.

It:
- Reads blockchain state
- Does not modify storage
- Is used for querying information
- Usually does not consume gas when called externally for reading

In Cairo, view functions use:

```rust
self: @ContractState