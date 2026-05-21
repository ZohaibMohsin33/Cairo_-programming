# Storage Variables in Cairo

## Introduction to Smart Contract State
In Starknet smart contracts, **Storage Variables** are the fundamental way to store data permanently on the blockchain. Unlike regular variables that are cleared from memory once a function finishes executing, storage variables persist their state across different transactions and function calls. They represent the "state" of the smart contract.

## The `#[storage]` Struct
In modern Cairo, all storage variables for a contract must be defined inside a specific struct named `Storage` that is decorated with the `#[storage]` attribute. This struct acts as a blueprint for everything the contract will remember permanently.

```cairo
#[storage]
struct Storage {
    counter: u32,
    is_active: bool,
}