# Toy ZK-related Contract in Cairo

## What is Zero-Knowledge Proof (ZK)?
Zero-Knowledge Proof is a cryptographic method where one party (the prover) 
can prove to another party (the verifier) that they know a secret value, 
WITHOUT revealing the actual secret itself.

###  Example:
Imagine you know a password. You want to prove you know it without telling 
anyone what it is. ZK proofs make this possible mathematically.

## What does this Contract do?
This is a Toy (educational) ZK-related smart contract that 
simulates the core idea of ZK proofs using hashing:

1. **Commit Phase**: User submits a secret number. The contract stores 
   only the HASH of the secret (not the secret itself).

2. **Verify Phase**: User later submits the secret again. The contract 
   hashes it and compares with stored hash. If they match = proof verified!

## Key Concepts Used

### Poseidon Hash
- A ZK-friendly hash function used in StarkNet
- Converts any input into a fixed-size output
- Same input always gives same output
- Cannot reverse engineer the original input from hash

### Smart Contract Storage
- `Map<ContractAddress, felt252>` stores one hash per user address
- Each user can commit their own secret independently

### Events
- `SecretCommitted`: Emitted when user stores their secret hash
- `ProofVerified`: Emitted when user attempts to verify their secret

## Contract Functions

| Function | Description |
|----------|-------------|
| `commit_secret(secret)` | Hashes the secret and stores it |
| `verify_secret(secret)` | Checks if provided secret matches stored hash |

## How to Build
```bash
scarb build
```

## Technologies Used
- Cairo 2.18.0
- StarkNet smart contract framework
- Poseidon hashing (ZK-friendly)
- Scarb build tool