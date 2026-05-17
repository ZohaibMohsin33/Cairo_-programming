# Hashing in Cairo Smart Contracts

## Introduction

This assignment demonstrates how to implement a basic smart contract in Cairo that performs two main tasks:

1. Store and retrieve a value from blockchain storage
2. Apply hashing to a given input using Cairo's built-in hash function

This project helps in understanding how data is stored securely and how hashing is used in smart contracts.

---

## What is Cairo?

Cairo is a programming language used to write provable programs for StarkNet. It allows developers to create smart contracts that run on blockchain with high security and scalability.

---

## What is a Smart Contract?

A smart contract is a program stored on a blockchain that runs automatically when certain conditions are met. It allows secure and transparent execution of logic without intermediaries.

---

## Concepts Used in This Assignment

### 1. %lang starknet

This line specifies that the program is a StarkNet smart contract.

---

### 2. Storage Variables
@storage_var
func stored_value() -> (res: felt)

Storage variables are used to store data permanently on the blockchain.

- `felt` is the basic data type in Cairo 
- Data stored here persists between transactions

---

### 3. External Functions
@external
func set_value(...)

- External functions can be called from outside the contract
- Used to modify blockchain state

In this contract:
- `set_value` stores a value in storage

---

### 4. View Functions
@view
func get_value(...)

- View functions only read data
- They do NOT modify the blockchain

In this contract:
- `get_value` retrieves stored data

---

## Hashing in Cairo

### What is Hashing?

Hashing is the process of converting input data into a fixed-size value (hash). It is widely used in blockchain for:

- Data integrity
- Security
- Verification

Example:
Input → 5  
Output → 938475983 (unique hash value)

Same input always produces same hash.

---

### Hash Function Used



from starkware.cairo.common.hash import hash2

Cairo provides a built-in function `hash2` which takes two values and produces a hashed output.

---

### Hashing Function in Contract
@view
func hash_value(value: felt) -> (hashed: felt):
let (res) = hash2(value, value)
return (hashed=res)

Explanation:

- Takes a number as input
- Applies `hash2` function
- Returns hashed value

---

## Code Explanation Summary


stored_value ->Defines storage
set_value -> Stores value 
get_value -> Retrieves value 
hash_value -> Generates hash 

---

## Why Hashing is Important in Smart Contracts

- Ensures data security
- Prevents tampering
- Used in cryptographic operations
- Helps in verifying transactions

---

## Conclusion

This assignment demonstrates:

- How to store and retrieve data using Cairo
- How to implement hashing using built-in functions
- Basic structure of a StarkNet smart contract

