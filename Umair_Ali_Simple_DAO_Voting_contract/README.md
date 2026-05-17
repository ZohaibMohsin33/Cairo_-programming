# Simple DAO Voting Contract

**Author:** Umair Ali
**Language:** Cairo 2.18.0

## Description

A DAO voting smart contract on Starknet. Owner manages membership. Members create proposals and vote. Results recorded on-chain.

## Build

```bash
scarb build
```

## Test

```bash
snforge test
```

## Test Results

Tests: 10 passed, 0 failed

## Functions

| Function | Access | Description |
|---|---|---|
| add_member | Owner | Register a new member |
| create_proposal | Members | Open a new proposal |
| vote | Members | Cast YES or NO vote |
| close_proposal | Anyone | Close and record result |
| get_proposal | Anyone | Read proposal data |
| is_member | Anyone | Check membership |
| has_voted | Anyone | Check vote status |
