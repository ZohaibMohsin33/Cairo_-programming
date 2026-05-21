# Token Faucet Smart Contract in Cairo

## 1. Project Overview

This project implements a **Token Faucet smart contract** using the **Cairo programming language** for Starknet.

A token faucet is a contract that gives users a small fixed amount of tokens when they request them. Faucets are commonly used in blockchain test environments to distribute test tokens, but the same idea is also useful for learning how smart contracts manage balances, user requests, permissions, and time-based restrictions.

This assignment focuses on the **faucet logic itself**. Instead of transferring a real external ERC20 token, the contract maintains an **internal faucet balance** and records how many faucet tokens each user has claimed. This keeps the project focused on Cairo fundamentals while still demonstrating realistic smart contract behavior.

---

## 2. Main Features

The contract includes the following features:

1. **Users can claim tokens**
   - Each successful claim gives a fixed token amount.

2. **Cooldown protection**
   - A user cannot claim again immediately after a successful claim.
   - The user must wait until the cooldown time has passed.

3. **Faucet balance control**
   - The faucet must have enough tokens before a claim can succeed.

4. **Owner-only refill**
   - Only the contract owner can add more tokens to the faucet.

5. **Owner-only configuration**
   - Only the owner can update:
     - Claim amount
     - Cooldown duration

6. **User balance tracking**
   - The contract records how many faucet tokens each user has received.

7. **Total distribution tracking**
   - The contract records the total amount distributed from the faucet.

8. **Events**
   - Important actions are emitted as events:
     - Token claim
     - Faucet refill
     - Claim amount update
     - Cooldown update

---

## 3. Project Structure

```text
Rayyan_Khalil_Token_Faucet/
│
├── Scarb.toml
├── guide.md
└── src/
    └── lib.cairo
```

### 3.1 `Scarb.toml`

This file defines:

- The package name
- Package version
- Cairo edition
- Starknet dependency
- Starknet contract compilation target

### 3.2 `src/lib.cairo`

This is the main Cairo source file. It contains:

- The external contract interface
- Contract storage
- Events
- Constructor
- User claim function
- Owner management functions
- Getter functions

### 3.3 `guide.md`

This guide explains:

- What the Token Faucet is
- How the project is structured
- How the code works
- How to compile the project
- How to understand each contract function

---

## 4. Prerequisites

Before working with this project, install or confirm the following tools:

- **Git**
- **Scarb**
- **VS Code** or another code editor
- **PowerShell** or another terminal

### Check Scarb Installation

Run:

```powershell
scarb --version
```

If Scarb is installed correctly, the terminal will print its version.

---

## 5. How to Open the Project

Open PowerShell and move into the project folder.

Because the directory path contains a space in `8th semester`, use double quotation marks:

```powershell
cd "E:\8th semester\Block-Chain\Cairo_-programming\Rayyan_Khalil_Token_Faucet"
```

Check that the files exist:

```powershell
dir
```

Expected project files:

```text
Scarb.toml
guide.md
src
```

Open the folder in VS Code:

```powershell
code .
```

---

## 6. How to Compile / Run the Project

This project is a Cairo smart contract project.  
The local verification step is to **compile it using Scarb**.

Run:

```powershell
scarb build
```

### Expected Successful Output

```text
Compiling token_faucet v0.1.0
Finished `dev` profile target(s)
```

This confirms that:

- The Cairo code is syntactically correct
- The contract compiles successfully
- The Scarb project configuration is valid

### What Scarb Generates

After a successful build, Scarb creates compiled artifacts inside:

```text
target/
```

These artifacts are later used when deploying the contract to a Starknet environment.

---

## 7. Important Note About “Running” a Smart Contract

A normal Cairo console program may be executed directly, but a **Starknet smart contract** follows a different flow:

1. Write the contract
2. Compile it with `scarb build`
3. Deploy it to a Starknet environment such as:
   - Starknet Devnet
   - Testnet
   - Mainnet
4. Call its functions through a wallet, CLI tool, or frontend

For this assignment, the important requirement is that the contract is **written correctly and builds without errors using Scarb**.

---

## 8. Contract Interface

The interface defines which functions are publicly available outside the contract.

### User Function

```cairo
claim_tokens()
```

Allows a user to claim faucet tokens.

### Owner Management Functions

```cairo
refill_faucet(amount)
update_claim_amount(new_claim_amount)
update_cooldown(new_cooldown_seconds)
```

These functions modify the contract configuration and are restricted to the owner.

### Getter Functions

```cairo
get_owner()
get_faucet_balance()
get_claim_amount()
get_cooldown_seconds()
get_total_distributed()
get_user_balance(user)
get_last_claim_time(user)
has_user_claimed(user)
```

Getter functions return stored contract data without changing the state.

---

## 9. Storage Variables

The contract stores information using Cairo storage variables.

| Storage Variable | Purpose |
|---|---|
| `owner` | Stores the administrator address |
| `faucet_balance` | Stores the number of tokens currently available |
| `claim_amount` | Stores the fixed amount given per claim |
| `cooldown_seconds` | Stores the required waiting time between claims |
| `total_distributed` | Stores total tokens distributed since deployment |
| `user_balances` | Stores token balance received by each user |
| `last_claim_time` | Stores the last claim timestamp for each user |
| `has_claimed_before` | Tracks whether a user has claimed before |

---

## 10. Constructor Logic

The constructor executes once when the contract is deployed.

### Constructor Inputs

```cairo
owner_address: ContractAddress
initial_faucet_balance: u128
initial_claim_amount: u128
initial_cooldown_seconds: u64
```

### Constructor Responsibilities

The constructor:

1. Saves the owner address
2. Sets the starting faucet balance
3. Sets the initial amount distributed per claim
4. Sets the cooldown duration
5. Sets `total_distributed` to zero
6. Rejects deployment if the claim amount is zero

### Example Configuration

A possible deployment configuration could be:

```text
owner_address = deployer address
initial_faucet_balance = 1000
initial_claim_amount = 50
initial_cooldown_seconds = 3600
```

This means:

- Faucet starts with 1000 tokens
- Every successful claim gives 50 tokens
- A user must wait 3600 seconds, which is 1 hour, before claiming again

---

## 11. Main Function: `claim_tokens`

The `claim_tokens` function is the most important function in the contract.

### Step-by-Step Logic

When a user calls `claim_tokens()`:

1. The contract gets the caller address using `get_caller_address()`.
2. It reads the current block timestamp using `get_block_timestamp()`.
3. It reads the current `claim_amount`.
4. It reads the current `faucet_balance`.
5. It checks that the faucet has enough tokens.
6. It checks whether the user has claimed before.
7. If the user has claimed before, the cooldown period is checked.
8. The user's stored balance is increased.
9. The faucet balance is decreased.
10. The latest claim timestamp is stored.
11. The user is marked as having claimed before.
12. The total distributed amount is increased.
13. A `TokensClaimed` event is emitted.

---

## 12. Claim Example

Assume the contract state is:

```text
faucet_balance = 1000
claim_amount = 50
cooldown_seconds = 3600
```

### First Claim by User A

User A calls:

```text
claim_tokens()
```

Result:

```text
User A balance = 50
Faucet balance = 950
Total distributed = 50
```

The claim succeeds because User A has not claimed before.

### Immediate Second Claim by User A

If User A calls again immediately:

```text
claim_tokens()
```

The transaction fails because:

```text
Cooldown period is still active
```

### Claim After Cooldown

After the cooldown period passes, User A can claim again.

Result:

```text
User A balance = 100
Faucet balance = 900
Total distributed = 100
```

---

## 13. Owner Function: `refill_faucet`

The `refill_faucet` function adds more tokens to the faucet balance.

### Function Signature

```cairo
refill_faucet(amount: u128)
```

### Rules

- Only the owner can call it.
- The refill amount must be greater than zero.

### Example

Current state:

```text
faucet_balance = 200
```

Owner calls:

```text
refill_faucet(500)
```

New state:

```text
faucet_balance = 700
```

The contract also emits a `FaucetRefilled` event.

---

## 14. Owner Function: `update_claim_amount`

This function changes how many tokens users receive per successful claim.

### Function Signature

```cairo
update_claim_amount(new_claim_amount: u128)
```

### Rules

- Only the owner can call it.
- The new claim amount must be greater than zero.

### Example

Current claim amount:

```text
claim_amount = 50
```

Owner calls:

```text
update_claim_amount(100)
```

New setting:

```text
claim_amount = 100
```

All future successful claims now give 100 tokens.

---

## 15. Owner Function: `update_cooldown`

This function changes the waiting time between claims.

### Function Signature

```cairo
update_cooldown(new_cooldown_seconds: u64)
```

### Rules

- Only the owner can call it.

### Example

Current cooldown:

```text
cooldown_seconds = 3600
```

Owner calls:

```text
update_cooldown(7200)
```

New setting:

```text
cooldown_seconds = 7200
```

Users must now wait 2 hours before claiming again.

---

## 16. Getter Functions

Getter functions read contract state and return values.

### 16.1 `get_owner()`

Returns the contract owner address.

### 16.2 `get_faucet_balance()`

Returns the remaining faucet balance.

### 16.3 `get_claim_amount()`

Returns the amount distributed per claim.

### 16.4 `get_cooldown_seconds()`

Returns the cooldown time in seconds.

### 16.5 `get_total_distributed()`

Returns the total amount distributed since deployment.

### 16.6 `get_user_balance(user)`

Returns the total faucet tokens received by a specific user.

### 16.7 `get_last_claim_time(user)`

Returns the last timestamp when the given user claimed tokens.

### 16.8 `has_user_claimed(user)`

Returns:

- `true` if the user has claimed at least once
- `false` if the user has never claimed

---

## 17. Events

Events allow frontends, explorers, and off-chain systems to detect contract activity.

### 17.1 `TokensClaimed`

Emitted after a successful claim.

Contains:

- Claimant address
- Claimed amount
- Claim timestamp

### 17.2 `FaucetRefilled`

Emitted when the owner refills the faucet.

Contains:

- Owner address
- Refill amount
- New faucet balance

### 17.3 `ClaimAmountUpdated`

Emitted when the owner changes the claim amount.

Contains:

- Owner address
- Old claim amount
- New claim amount

### 17.4 `CooldownUpdated`

Emitted when the owner changes cooldown time.

Contains:

- Owner address
- Old cooldown
- New cooldown

---

## 18. Validation and Safety Checks

The contract includes several checks to avoid invalid behavior.

### 18.1 Claim Amount Must Be Positive

The constructor rejects a zero claim amount.

### 18.2 Faucet Must Have Enough Balance

A claim fails if:

```text
faucet_balance < claim_amount
```

### 18.3 Cooldown Must Have Passed

A returning user can only claim if:

```text
current_time >= previous_claim_time + cooldown_seconds
```

### 18.4 Only Owner Can Manage the Faucet

Only the owner can call:

- `refill_faucet`
- `update_claim_amount`
- `update_cooldown`

### 18.5 Refill Amount Must Be Positive

The owner cannot refill the faucet with zero tokens.

---

## 19. Commands Used in This Project

### 19.1 Move into the Assignment Folder

```powershell
cd "E:\8th semester\Block-Chain\Cairo_-programming\Rayyan_Khalil_Token_Faucet"
```

### 19.2 Check Project Files

```powershell
dir
```

### 19.3 Check Scarb Installation

```powershell
scarb --version
```

### 19.4 Build the Contract

```powershell
scarb build
```

---

## 20. Successful Compilation Result

This project was compiled successfully using:

```powershell
scarb build
```

Terminal output:

```text
Compiling token_faucet v0.1.0
Finished `dev` profile target(s)
```

This confirms that the Cairo smart contract builds correctly with Scarb.

---

## 21. Learning Outcomes

Through this assignment, the following concepts were learned and practiced:

- Creating a Cairo project with Scarb
- Defining a Starknet smart contract interface
- Writing a contract constructor
- Using contract storage variables
- Using storage maps with `ContractAddress`
- Reading the caller using `get_caller_address()`
- Reading the block timestamp using `get_block_timestamp()`
- Implementing cooldown logic
- Restricting functions using owner-only access checks
- Updating contract state safely
- Emitting events
- Writing getter functions
- Building and verifying a Cairo contract using Scarb

---

## 22. Final Summary

This project implements a complete Token Faucet smart contract in Cairo. It allows users to claim a fixed amount of internal faucet tokens while preventing repeated immediate claims through a cooldown mechanism. The owner can refill the faucet, update the claim amount, and change the cooldown duration. The contract also records user balances, total distributed tokens, and emits events for important actions.

The project demonstrates important beginner-to-intermediate Cairo smart contract concepts and has been successfully compiled using Scarb.
