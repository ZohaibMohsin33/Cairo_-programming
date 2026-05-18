# 📘 Technical Documentation: Starknet Grade Evaluator Contract


### Author

**Muhammad Arslan Shafi**
Roll No: Bscs22100
Section: B

---

## 🚀 Introduction
The **Grade Evaluator** is a secure, stateful decentralized smart contract engineered using the modern **Cairo 1.0** programming language for the Starknet ecosystem. It acts as an immutable, transparent ledger designed for academic management—allowing authorized instructors to submit numerical grades while preventing unauthorized modification from external entities.

---

## 🏗️ Architecture & Component Breakdown



### 1. Unified Student Record Layout (`Struct`)
To manage data efficiently, the contract groups academic metrics into a single custom structure:
* **`score` (`u8`)**: An unsigned 8-bit integer representing the student's raw marks (constrained mathematically between `0` and `100`).
* **`letter_grade` (`felt252`)**: Cairo's native Field Element type, utilized to store short-string character data representing alphanumeric grading symbols (e.g., `'A'`, `'B'`, `'C'`).

### 2. State Storage Topology
Permanent blockchain storage is defined under the `#[storage]` block:
* **`instructor` (`ContractAddress`)**: Persists the cryptographic wallet address of the deployment admin (the educator).
* **`grades` (`Map`)**: A highly optimized storage mapping (`Map::<ContractAddress, GradeRecord>`) that securely links a student's unique network address directly to their structured academic record.

---

## 🛡️ Core Logical Workflows

### 📥 1. Deployment Initialization (Constructor)
When the smart contract is broadcast and deployed to the network, the `constructor` function triggers exactly once. It captures the designated `instructor_address` passed during deployment and commits it permanently to the ledger state, locking down administrative permissions from day one.

### ✍️ 2. Grade Submission & Boundary Enforcement
The state-mutating function `evaluate_and_submit_grade` implements rigorous computational guards before updating the blockchain state:

* **Access Control Check:** It cross-references the caller's address via `get_caller_address()`. If the caller does not match the stored instructor identity, execution halts instantly with a panic error: `'Only instructor can grade'`.
* **Data Sanitization:** A strict validation check ensures raw inputs never exceed bounds: `assert(score <= 100_u8, 'Score cannot exceed 100')`.

### 🧮 3. Conditional Evaluation Algorithm
The assignment of alphanumeric marks utilizes a safe, deterministic conditional ladder matching numerical limits into distinct character outputs:
* **`>= 90`** $\rightarrow$ `'A'`
* **`>= 80`** $\rightarrow$ `'B'`
* **`>= 70`** $\rightarrow$ `'C'`
* **`>= 60`** $\rightarrow$ `'D'`
* **`< 60`** $\rightarrow$ `'F'`

---

## 💻 Compilation & Ecosystem Tooling

This project leverages **Scarb**, the official package manager and build environment for Cairo. 


### Execution Command
To verify syntactic validity and compile the smart contract architecture into target Sierra artifacts, execute the following command in the terminal root:
```powershell
scarb build


