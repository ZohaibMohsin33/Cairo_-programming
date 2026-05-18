# 🚀 Cairo 101: Counter Smart Contract & Student Tutorial

Welcome to your first Cairo smart contract project! This repository contains a fully working **Counter Smart Contract** written in Cairo 2.8+ (Starknet), along with a basic **Hello World** executable script. 

This guide is formatted as a student-friendly tutorial to help you understand Cairo programming concepts, how the Counter contract works under the hood, and how to build and execute the files on a Windows laptop.

---

## 📚 Section 1: Introduction to Cairo Programming

### What is Cairo?
**Cairo** (CPU Algebraic Intermediate Representation Language) is a Turing-complete programming language developed by StarkWare. It is designed specifically for writing **provable programs**—meaning that executing a Cairo program generates a cryptographic proof that the execution was done correctly. 

### Why do we use Cairo for Starknet Smart Contracts?
1. **Zero-Knowledge Proofs (ZKPs):** Cairo is built to compile into mathematical equations (AIRs) that can generate ZK proofs. This allows Ethereum validators to verify millions of Starknet transactions off-chain instantly and extremely cheaply.
2. **Rust-like Syntax:** Modern Cairo (Cairo 1.0+) looks and feels like Rust, bringing maximum safety, strong typing, and rich syntax (traits, generics, pattern matching) to smart contract development.
3. **Safety & Security:** Unlike Solidity, Cairo separates the compilation step into **Sierra** (Safe Intermediate Representation), ensuring that failed transactions are still provable and gas fees are safely deducted without breaking block production.

---

## 🎯 Section 2: Why do we need a "Counter Contract"?

In blockchain development, a **Counter Contract** is the "Hello World" of stateful smart contracts. 

While a basic "Hello World" script simply prints static text, it does not interact with the blockchain's state. A Counter Contract teaches you the core pillars of blockchain development:
1. **Persistent State Storage:** How to save data permanently on the blockchain ledger (the counter value).
2. **State Mutability:** How to modify stored data through transactions (`increment` / `decrement`).
3. **State Querying:** How to read current data from the ledger without spending gas (`get_count`).
4. **Access Control & Interfaces:** How contracts expose entry points for external users or other contracts to interact with them.

---

## 💻 Section 3: Step-by-Step Guide to Coding the Counter Contract

If you want to build this Counter contract from absolute scratch, follow this step-by-step programming tutorial. It explains how to structure, code, and implement every block of the contract.

---

### Step 1: Set up the Project Configuration (`Scarb.toml`)
Before writing any Cairo code, we must tell Scarb that this project compiles to a Starknet smart contract. 
Open your `Scarb.toml` and write the following configuration:

```toml
[package]
name = "assignment"
version = "0.1.0"
edition = "2024_07"

[dependencies]
starknet = "2.8.2"

[[target.starknet-contract]]
```
* **Explanation:** `[[target.starknet-contract]]` is the target type which instructs the Cairo compiler to output compiled JSON artifacts deployable to Starknet, instead of compiling it as a normal native executable.

---

### Step 2: Define the Public Interface (`ICounter` Trait)
In Cairo, all smart contracts must expose their public functions inside a **Trait** annotated with `#[starknet::interface]`. This defines *what* actions are possible.

Open your `src/lib.cairo` file and write the interface:

```cairo
#[starknet::interface]
pub trait ICounter<TContractState> {
    fn increment(ref self: TContractState);
    fn decrement(ref self: TContractState);
    fn get_count(self: @TContractState) -> u32;
}
```

* **Line-by-line Breakdown:**
  * `#[starknet::interface]`: Instructs the Cairo compiler to generate ABI dispatchers.
  * `TContractState`: A generic parameter representing the contract's state storage.
  * `ref self`: The `ref` keyword allows the function to **write/mutate** the blockchain storage (used for `increment` and `decrement`).
  * `@TContractState`: The `@` symbol represents a **snapshot** (a read-only copy). This is used for `get_count` because reading state does not change it.

---

### Step 3: Initialize the Contract Module & Import Storage Traits
Now, define the contract module structure using `#[starknet::contract]` and import the required storage pointer traits:

```cairo
#[starknet::contract]
pub mod Counter {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    
    // Storage and Implementation will go inside here...
}
```

* **Line-by-line Breakdown:**
  * `#[starknet::contract]`: Marks the module as a Starknet smart contract.
  * `use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};`: Cairo 2.8+ requires importing these traits. If you do not import them, your compiler will throw an error saying `.read()` and `.write()` methods do not exist!

---

### Step 4: Define the Persistent Storage Struct
Every smart contract needs to store data on the blockchain ledger. We define a special struct called `Storage` inside the `Counter` module:

```cairo
    #[storage]
    struct Storage {
        count: u32,
    }
```

* **Line-by-line Breakdown:**
  * `#[storage]`: A compiler attribute telling Starknet that variables inside this struct belong to persistent on-chain memory.
  * `count: u32`: We declare a single variable named `count` using the `u32` (unsigned 32-bit integer) type.

---

### Step 5: Implement the Contract Logic (`CounterImpl`)
Lastly, we write the implementation block where the actual logic for `increment`, `decrement`, and `get_count` is defined. This block connects to the interface we wrote in **Step 2**:

```cairo
    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn increment(ref self: ContractState) {
            let current = self.count.read();
            self.count.write(current + 1);
        }

        fn decrement(ref self: ContractState) {
            let current = self.count.read();
            self.count.write(current - 1);
        }

        fn get_count(self: @ContractState) -> u32 {
            self.count.read()
        }
    }
```

* **Line-by-line Breakdown:**
  * `#[abi(embed_v0)]`: Exposes the implementation functions as entry points so external clients can call them.
  * `super::ICounter<ContractState>`: References the trait we defined in Step 2.
  * `self.count.read()`: Reads the current value from the blockchain storage.
  * `self.count.write(new_value)`: Overwrites the blockchain storage with the updated value.

---

---

## 🛠️ Section 4: Step-by-Step Running Guide (Windows Terminal)

Since you are running Scarb locally without installing it globally, you will execute these commands in your Windows PowerShell terminal.

### Part A: How to build the Counter Smart Contract

Building a Cairo smart contract translates your high-level Cairo code into an intermediate format (Sierra) that the Starknet blockchain can execute. Here is the step-by-step breakdown of how to build it:

#### **Step 1: Open the Terminal in VS Code**
* Open VS Code in your `Blockchain_ Assignment 4` workspace.
* Open the integrated terminal inside VS Code by pressing **`Ctrl + \``** (Ctrl + Backtick) or going to **Terminal -> New Terminal** in the top menu.

#### **Step 2: Verify Your Working Directory**
* Look at the terminal prompt and ensure you are located in the project's root folder: `C:\Users\marif\OneDrive\Desktop\Blockchain_ Assignment 4`.
* If you ever get lost in a subfolder (like `hello_world_test`), run the following command to return to the root folder:
  ```powershell
  cd "C:\Users\marif\OneDrive\Desktop\Blockchain_ Assignment 4"
  ```

#### **Step 3: Run the Build Command**
* Since we set up a portable Scarb instance inside your project, you will build the contract by running this command:
  ```powershell
  .\scarb-bin\scarb-v2.18.0-x86_64-pc-windows-msvc\bin\scarb.exe build
  ```
* This tells Scarb to parse your package settings in `Scarb.toml` and compile your contract in `src/lib.cairo`.

#### **Step 4: Understand the Compiler Output**
* When the build is complete, your terminal will print:
  ```text
     Compiling assignment v0.1.0 (C:\Users\marif\OneDrive\Desktop\Blcokchain_ Assignment 4\Scarb.toml)
      Finished `dev` profile target(s) in 0 seconds
  ```
* This output tells you that Scarb compiled the code successfully, resolved all Starknet platform dependencies, and found zero syntax or typing errors.

#### **Step 5: Verify the Compiled Artifacts**
* After building, Scarb generates a folder named `target` in your main directory.
* Open `target/dev/` in your VS Code sidebar. You will see the compiled JSON artifacts ready for deployment:
  1. `assignment_Counter.contract_class.json` (Sierra representation)
  2. `assignment_Counter.compiled_contract_class.json` (CASM machine-code representation)
* These files are what gets submitted to the Starknet network to deploy the contract!

### Part B: How to run the Hello World Script

Standard scripts are configured differently than Starknet contracts, which is why we run them in a separate package directory (`hello_world_test`).

1. Navigate to the script directory:
   ```powershell
   cd hello_world_test
   ```
2. Execute the Hello World script:
   ```powershell
   ..\scarb-bin\scarb-v2.18.0-x86_64-pc-windows-msvc\bin\scarb.exe execute --print-program-output
   ```
3. **Expected Output:**
   ```text
      Compiling hello_world v0.1.0 (C:\Users\marif\OneDrive\Desktop\Blcokchain_ Assignment 4\hello_world_test\Scarb.toml)
       Finished `dev` profile target(s) in 0 seconds
      Executing hello_world
   Hello, World!
   ```
4. Return to your main directory when done:
   ```powershell
   cd ..
   ```

---

## 🎓 Glossary for Students

* **Scarb:** The standard build toolchain and package manager for Cairo (equivalent to Cargo in Rust, or npm in Node.js).
* **Sierra:** Safe Intermediate Representation. Cairo code compiles to Sierra, which guarantees that even failing transactions can be proven and charged gas.
* **CASM:** Cairo Assembly. This is the machine code that Starknet OS actually executes.
* **u32:** An unsigned 32-bit integer (can only hold positive whole numbers from `0` to `4,294,967,295`).
