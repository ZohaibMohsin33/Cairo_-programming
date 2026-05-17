# Simple Calculator Assignment Guide

## Overview
This assignment implements a small calculator in Cairo. The goal is to practice fundamental Cairo syntax, function definitions, arithmetic expressions, assertions, and unit testing. Cairo is a programming language designed for writing provable programs on StarkNet, and understanding basic arithmetic and control flow is essential for smart contract development.

## Cairo Concepts Studied

### 1. Module Structure (`mod calculator { }`)
Cairo uses modules to organize code and control visibility. In this assignment:
- The `calculator` module groups all arithmetic operations together
- Functions are marked `pub` to make them publicly accessible
- The module structure improves code organization and readability
- This is a foundational pattern used in larger Cairo smart contracts

**Why it matters:** As Cairo projects grow, proper module organization prevents naming conflicts and makes code maintainable.

### 2. Function Definitions and Signatures
Each calculator function follows Cairo's function syntax:
```cairo
pub fn add(left: felt252, right: felt252) -> felt252 {
    left + right
}
```

Key elements:
- `pub fn` declares a public function
- Parameters include explicit type annotations (`felt252`)
- Return type is declared after `->`
- The function body's last expression is implicitly returned
- No `return` keyword needed

**Why it matters:** Type safety prevents bugs and makes code intent clear. Cairo's type system helps ensure correct smart contract behavior.

### 3. The `felt252` Type
`felt252` is Cairo's native integer type, representing elements in a finite field:

- **252 bits:** Large enough for most arithmetic operations
- **Field element:** Arithmetic operates modulo a large prime, preventing overflow
- **Universal type:** All Cairo integers naturally use `felt252`
- **No overflow:** Unlike traditional programming languages, arithmetic automatically wraps in the field

Example: In traditional languages, `2^256 + 1` might overflow. In Cairo, field arithmetic handles large numbers naturally.

**Why it matters:** Smart contracts deal with large numbers (balances, token amounts). Field arithmetic prevents overflow vulnerabilities.

### 4. Pure Functions
All calculator functions are **pure**—they:
- Take inputs and return outputs without side effects
- Don't modify global state
- Always produce the same output for the same input
- Can be safely called multiple times

```cairo
pub fn multiply(left: felt252, right: felt252) -> felt252 {
    left * right  // No state changes, just computation
}
```

**Why it matters:** Pure functions are easier to test, reason about, and verify. Smart contracts often need formal verification—pure functions enable this.

### 5. Assertions and Error Handling
Assertions validate preconditions and prevent invalid operations:

```cairo
pub fn divide(left: felt252, right: felt252) -> felt252 {
    assert(right != 0, 'Division by zero');
    left / right
}
```

How assertions work:
- `assert(condition, 'error_message')` checks if condition is true
- If false, the program panics with the error message
- Panics terminate execution and revert state changes (in smart contracts)

**Why it matters:** Smart contracts must validate inputs to prevent exploits. For example:
- Check that balances don't go negative
- Ensure sufficient allowance before transfers
- Validate function parameters

### 6. Unit Testing with `#[cfg(test)]` and `#[test]`
Cairo provides a built-in test framework:

```cairo
#[cfg(test)]
mod tests {
    use super::calculator::{add, divide, modulo, multiply, subtract};

    #[test]
    fn add_works() {
        assert(add(12, 8), 20);
    }
}
```

Key concepts:
- `#[cfg(test)]` marks a module as test-only (only compiled during testing)
- `#[test]` marks a function as a test case
- Tests use `assert()` to verify expected behavior
- Each test is independent and isolated

**Why it matters:** Testing ensures correctness. Smart contracts handle real assets—thorough testing prevents loss of funds.

## Implementation Details

### Features Implemented
The calculator exposes these operations:
1. **Addition** - `add(a, b)` returns `a + b`
2. **Subtraction** - `subtract(a, b)` returns `a - b`
3. **Multiplication** - `multiply(a, b)` returns `a * b`
4. **Division** - `divide(a, b)` returns `a / b` (asserts `b != 0`)
5. **Modulo** - `modulo(a, b)` returns `a % b` (asserts `b != 0`)

### Test Coverage
Each operation has a dedicated test:
- `add_works()` validates addition
- `subtract_works()` validates subtraction
- `multiply_works()` validates multiplication
- `divide_works()` validates division
- `modulo_works()` validates remainder

## Design Notes
- The logic is kept in a single module so the assignment stays focused and easy to review.
- Each function is pure and returns a value directly.
- Division and modulo validate the divisor before performing the operation.
- Comments are included to explain the purpose of each function.
- All code follows Cairo naming conventions (snake_case for functions, CamelCase for types).

## Assignment Rules Followed
✅ Work is contained in this folder only  
✅ Code is written in Cairo  
✅ The implementation is original and understandable  
✅ Code follows Cairo naming conventions and best practices  
✅ The project is structured so it can be built and tested with Scarb  
✅ Comprehensive comments explain all logic  
✅ Detailed guide documents all concepts  
✅ All assertions include meaningful error messages  

## How To Run

### Prerequisites
- Cairo 2.16.1 or later
- Scarb 0.7.0 or later

### Build the Project
```bash
cd /path/to/project
scarb build
```

### Run Tests
```bash
scarb test
```

Expected output shows all 5 tests passing.

## What To Explain During Evaluation

### 1. The Role of `felt252` in Arithmetic
"In Cairo, `felt252` is the primary integer type. It represents elements in a finite field with 252-bit values. Unlike traditional programming languages with fixed-size integers that can overflow, field arithmetic in Cairo automatically handles large numbers. This is crucial for smart contracts that deal with large token amounts or numerical balances."

### 2. How Cairo Functions Return Values
"Cairo functions use implicit returns. The last expression in a function's body is automatically returned. There's no need for a `return` keyword. The return type is declared in the function signature after `->`, and Cairo's type system ensures the returned value matches this type."

### 3. Why Assertions Are Necessary
"Assertions like `assert(right != 0, 'Division by zero')` validate preconditions before executing operations. If the assertion fails, the program panics. In smart contracts, a panic reverts all state changes, preventing invalid operations like dividing by zero. This is a fundamental security mechanism."

### 4. How Unit Tests Verify Operations
"Each test function is marked with `#[test]` and calls a calculator operation with known inputs. The test then asserts that the output matches the expected value. Tests are isolated (run in `#[cfg(test)]` modules) and don't affect production code. This ensures each operation works correctly independently."

### 5. The Importance of Module Organization
"The `calculator` module groups related functions together, improving code organization and making the assignment easier to understand. In larger smart contracts, modules help manage complexity and prevent naming conflicts. The `pub` keyword controls visibility, allowing the module to expose specific functions while hiding implementation details."

## Cairo Programming Best Practices Demonstrated

1. **Type Safety** — All values have explicit types, preventing type-related bugs
2. **Pure Functions** — No side effects make code predictable and testable
3. **Explicit Error Handling** — Assertions validate critical preconditions
4. **Comprehensive Testing** — Each function has a dedicated test case
5. **Clear Documentation** — Comments and doc strings explain the "why" behind the code
6. **Consistent Naming** — snake_case functions, clear variable names
7. **Modular Design** — Related functionality grouped in modules

## Advanced Concepts (For Further Learning)

While this assignment focuses on basics, these concepts extend the foundation:

- **Traits** — Define shared behavior across types (like Rust traits)
- **Generics** — Write functions that work with multiple types
- **Error Handling** — Beyond assertions, using custom error types
- **Smart Contracts** — Using Cairo for Starknet smart contracts
- **Cryptographic Operations** — Hash functions, signatures, zero-knowledge proofs
- **State Management** — Storing and modifying contract state

## Project Structure
```
.
├── Scarb.toml           # Package manifest
├── README.md            # Project overview and completion checklist
├── guide.md             # This detailed learning guide
└── src/
    ├── lib.cairo        # Package entrypoint (imports starter module)
    └── starter.cairo    # Calculator implementation and tests
```

## References for Further Learning
- **[Cairo Book](https://www.starknet.io/cairo-book/)** — Official language reference
- **[Cairo Core Library Docs](https://docs.cairo-lang.org/core)** — Built-in types and functions
- **[Scarb Documentation](https://docs.swmansion.com/scarb/)** — Package manager and build tool
- **[StarkNet Dev Docs](https://docs.starknet.io/)** — Smart contract platform documentation
- **[Cairo Playground](https://www.cairo-lang.org/cairovm/)** — Browser-based Cairo environment

## Notes
This assignment covers beginner-level Cairo concepts. The calculator demonstrates core language features that are building blocks for smart contract development. Understanding function definitions, types, assertions, and testing is essential before moving to more advanced topics like state management and contract interactions.
