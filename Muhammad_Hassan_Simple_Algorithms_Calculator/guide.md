# Simple Algorithms & Calculator, Cairo Programming

## What is Cairo?
Cairo is a programming language designed for writing provable programs. It is used
to build smart contracts on the Starknet blockchain. Cairo ensures mathematical
correctness and is based on a STARK-provable virtual machine.

## Topic: Simple Algorithms & Calculator

This assignment implements basic mathematical algorithms using the Cairo programming
language. The goal is to understand functions, data types, control flow, and
recursion in Cairo.

## Algorithms Implemented

### 1. Addition
Adds two integers together.
- Input: two `i32` integers
- Output: their sum

### 2. Subtraction
Subtracts one integer from another.
- Input: two `i32` integers
- Output: their difference

### 3. Multiplication
Multiplies two integers.
- Input: two `i32` integers
- Output: their product

### 4. Division
Divides one integer by another with a zero-division guard.
- Input: two `i32` integers
- Output: quotient
- Safety: panics if divisor is zero

### 5. Is Even
Checks whether a number is even or odd.
- Input: one `i32` integer
- Output: `bool` (true if even)

### 6. Factorial
Recursively calculates the factorial of a number.
- Input: one `u32` integer
- Output: factorial result (e.g. 5! = 120)

### 7. Maximum
Returns the larger of two integers.
- Input: two `i32` integers
- Output: the maximum value

## Key Cairo Concepts Used
- **Functions:** Defined with `fn` keyword
- **Data Types:** `i32` for signed integers, `u32` for unsigned, `bool` for boolean
- **Control Flow:** `if/else` statements
- **Recursion:** Used in factorial function
- **Assertions:** `assert()` used for input validation
- **Testing:** `#[cfg(test)]` and `#[test]` attributes for unit tests

## How to Run

### Build:
```bash
scarb build
```

### Test:
```bash
scarb test
```

## Resources
- [Cairo Book](https://book.cairo-lang.org)
- [Scarb Documentation](https://docs.swmansion.com/scarb)
- [Starknet Documentation](https://docs.starknet.io)