# External Functions in Cairo
##  Muhammad Musadiq


## 1. What Are External Functions?

In Cairo smart contracts (on Starknet), **external functions** are functions that can be **called from outside the contract**  by users submitting transactions, or by other smart contracts interacting with yours.

They form the **public API** of your smart contract. Without external functions, no one can interact with your contract.

Think of a smart contract like a vending machine:
The **buttons you press** = external functions
The **internal mechanics** = private/internal logic
The **slot where you get your item** = the return value


## 2. Why Are External Functions Important?

Reason and Explanation 

**Interactivity**  They let users and other contracts interact with your contract 
**Encapsulation**  Only expose what's necessary; hide internal logic 
**ABI Generation**  They define the contract's ABI (Application Binary Interface) 
**Security**  Controlling what's external limits attack surfaces 
**Composability**  Other contracts can call your external functions on-chain 


## 3. How External Functions Work in Cairo

### Step 1: Define a Trait (Interface)
```cairo
#[starknet::interface]
trait IMyContract<TContractState> {
    fn my_function(ref self: TContractState, value: u128);
}
```

### Step 2: Implement the Trait in Your Contract
```cairo
#[starknet::contract]
mod MyContract {
    #[abi(embed_v0)]
    impl MyContractImpl of super::IMyContract<ContractState> {
        fn my_function(ref self: ContractState, value: u128) {
            // logic here
        }
    }
}
```

### Key Attributes:
 `#[starknet::interface]`  marks a trait as a contract interface
 `#[abi(embed_v0)]`  makes the impl block's functions **external** (part of ABI)
 `ref self: ContractState`  function can **write** to storage (state-changing)
 `self: @ContractState`  function can only **read** storage (view function)

---

## 4. Types of External Functions

### a) State-Changing Functions
These modify on-chain storage. They require a **transaction** (costs gas).

```cairo
fn set_value(ref self: ContractState, val: u128) {
    self.my_storage_var.write(val);
}
```

### b) View Functions (Read-Only)
These only read data. They can be called **for free** off-chain.

```cairo
fn get_value(self: @ContractState) -> u128 {
    self.my_storage_var.read()
}
```

### c) Functions With Logic
External functions can contain complex logic  conditionals, loops, math:

```cairo
fn add_and_store(ref self: ContractState, a: u128, b: u128) {
    let result = a + b;
    self.stored_number.write(result);
}
```

---

## 5. External vs Internal Functions

  Feature               External Function  Internal Function 

 Callable from outside     Yes                   No 
 In ABI                    Yes                   No 
 Needs `#[abi(embed_v0)]`  Yes                   No 
 Gas cost (write)          Yes                   N/A 
 Used for  Public API  Helper logic 

---

## 6. The ABI (Application Binary Interface)

When you mark functions as external using `#[abi(embed_v0)]`, Cairo automatically generates an **ABI**  a JSON description of all callable functions.

This ABI is used by:
- Frontend dApps (React, etc.) to call contract functions
- Wallets (ArgentX, Braavos) to build transactions
- Other contracts to call your functions

---

## 7. Storage in External Functions

External functions interact with persistent **on-chain storage**:

```cairo
#[storage]
struct Storage {
    stored_number: u128,
}
```

 `self.stored_number.write(value)`  save data permanently on blockchain
 `self.stored_number.read()`  fetch saved data

Storage persists **between transactions**  it's the contract's memory.

---

## 8. Data Types Used

 Type              Description                           Example 

 `u128`            Unsigned 128-bit integer              Balances, counts 
 `felt252`         Field element  Cairo's native type    Short strings, IDs 
 `bool`            True or false                         Flags, conditions 
 `ContractAddress` An on-chain address                   User wallets 

---

## 9. Complete Code Walkthrough

```cairo
// 1. Interface  defines what's externally callable
#[starknet::interface]
trait IExternalFunctionsDemo<TContractState> {
    fn set_number(ref self: TContractState, value: u128);  // write
    fn get_number(self: @TContractState)  u128;          // read
}

// 2. Contract implementation
#[starknet::contract]
mod ExternalFunctionsDemo {

    #[storage]
    struct Storage {
        stored_number: u128,  // on-chain variable
    }

    // 3. #[abi(embed_v0)] exposes functions externally
    #[abi(embed_v0)]
    impl ExternalFunctionsDemoImpl of super::IExternalFunctionsDemo<ContractState> {

        fn set_number(ref self: ContractState, value: u128) {
            self.stored_number.write(value);  // modifies state
        }

        fn get_number(self: @ContractState) -> u128 {
            self.stored_number.read()         // reads state
        }
    }
}
```

---

## 10. How to Run with Scarb

```bash
# 1. Install Scarb
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# 2. Create a new project
scarb new external_functions_demo

# 3. Replace src/lib.cairo with the provided .cairo file

# 4. Build the project
scarb build

# 5. Run tests (if tests are added)
scarb test
```

---

## 11. Real-World Use Cases
 
   Use Case              External Function Example 
   Token Contract       `transfer(to, amount)` 
   Voting System        `cast_vote(candidate_id)` 
   NFT Marketplace      `buy_nft(token_id)` 
   DeFi Protocol        `deposit(amount)` 
   Game Contract        `make_move(position)` 

---

## 12. Key Takeaways

1. **External functions**  the public API of your Starknet smart contract
2. Use `#[starknet::interface]` to define the interface (trait)
3. Use `#[abi(embed_v0)]` to make the implementation external
4. `ref self`  state-changing; `@self` = view/read-only
5. Storage persists between all transactions on-chain
6. The ABI generated from external functions is used by frontends and wallets

---

## 13. References

 [Cairo Book — Starknet Smart Contracts](https://book.cairo-lang.org/ch15-00-starknet-smart-contracts.html)
 [Cairo Book — Contract Functions](https://book.cairo-lang.org/ch15-02-contract-functions.html)
 [Starknet Documentation](https://docs.starknet.io)
 [Scarb Package Manager](https://docs.swmansion.com/scarb/)
 [OpenZeppelin Cairo Contracts (Examples)](https://github.com/OpenZeppelin/cairo-contracts)
