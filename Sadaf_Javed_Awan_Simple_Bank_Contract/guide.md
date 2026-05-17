# Simple Bank Contract — Guide

## What is a Smart Contract?
A smart contract is a self-executing program stored on a blockchain.
It runs automatically when conditions are met, without any middleman.

## What is Cairo?
Cairo is a programming language by StarkWare for writing smart 
contracts on Starknet — a Layer 2 blockchain built on Ethereum.

## What Does This Contract Do?
This is a Simple Bank Contract with these features:
- deposit: User deposits amount into the bank
- withdraw: User withdraws their own funds
- get_balance: Check balance of any address
- get_total_balance: View total funds in the bank
- get_owner: View the contract owner address

## Key Cairo Concepts Used

### 1. Storage
Variables permanently saved on blockchain.
- owner: who deployed the contract
- balances: each user's balance (Map)
- total_deposits: total funds in bank

### 2. Map
A key-value store like a dictionary.
Map<ContractAddress, u256> stores each wallet's balance.

### 3. get_caller_address()
Returns the wallet address of whoever is calling the function.
This is how we know WHO is depositing or withdrawing.

### 4. assert()
Checks a condition and stops execution if it fails.
Used to ensure deposit > 0 and sufficient balance.

### 5. Events
Logs emitted on-chain to track activity.
- Deposited: when deposit happens
- Withdrawn: when withdrawal happens

### 6. Constructor
Runs once when contract is deployed. Sets the owner.

## Folder Structure
