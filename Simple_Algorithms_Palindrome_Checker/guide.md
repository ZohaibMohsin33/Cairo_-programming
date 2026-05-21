# Simple Algorithms: Palindrome Checker in Cairo

## Overview
This project implements a Palindrome Checker algorithm using Cairo. A palindrome is a sequence of elements that reads the same forwards and backwards (e.g., `[1, 2, 3, 2, 1]`). This assignment demonstrates fundamental Cairo programming concepts, focusing on memory safety, array manipulation, and testing.

## Technical Concepts Covered

### 1. Arrays and Spans
In Cairo, arrays (`Array<T>`) are append-only data structures. To safely manipulate and read from both ends of the data without copying, we convert the Array into a `Span`. A `Span` represents a snapshot of the array and provides built-in methods to consume elements efficiently.

### 2. The `pop_front()` and `pop_back()` Methods
The core of the palindrome algorithm relies on checking the outermost elements and moving inward.
- `pop_front()` extracts the first element of the Span.
- `pop_back()` extracts the last element of the Span.
Both methods return an `Option` type, which we safely unpack using `.unwrap()`.

### 3. Infinite Loops and Breaking
Cairo uses a `loop` keyword for continuous iteration, as standard `while` loops operate differently due to the underlying cryptographic architecture. The loop continually checks the remaining length of the Span:
- **Base Case:** If the length is `<= 1`, it breaks and returns `true` (it is a palindrome).
- **Condition Failure:** If the front and back elements do not match, it immediately breaks and returns `false`.

### 4. Unit Testing (`cairo_test`)
Testing is heavily emphasized in smart contract development. The project uses Cairo's native `#[test]` attributes to automatically verify logic. The `scarb test` command evaluates gas usage and asserts that both valid and invalid palindromes return the correct boolean values.

## How to Run
1. Execute the main function: `scarb run`
2. Run the unit tests: `scarb test`