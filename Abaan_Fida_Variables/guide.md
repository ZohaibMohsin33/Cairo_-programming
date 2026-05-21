# Cairo Variables — Complete Guide

## 1. What Are Variables?
Variables are named storage locations in memory used to hold data that can be manipulated or referenced throughout your program. In Cairo, variables are statically typed, meaning their type is known at compile time.

## 2. Immutable Variables (Default)
By default, variables in Cairo are **immutable**. Once a value is bound to a variable name, you cannot change it. This ensures safety and predictability in smart contract execution.
```cairo
let base_value: u32 = 10;
// base_value = 20; // This would cause a compile-time error
```

## 3. Mutable Variables — the `mut` keyword
When you need a variable to change over time, you can declare it as mutable using the `mut` keyword. This allows reassignment.
```cairo
let mut counter: u32 = 0;
counter += 1;
```

## 4. Constants — `const`
Constants are values that are bound to a name and are not allowed to change. They differ from immutable variables in a few ways:
- **Difference from immutable `let`**: They are always evaluated at compile-time.
- **Where they can be declared**: They can be declared at the module scope (outside of functions).
- **Naming convention**: They must use `SCREAMING_SNAKE_CASE` and require explicit type annotations.
```cairo
const MAX_SCORE: u32 = 100;
```

## 5. Shadowing
Cairo allows you to declare a new variable with the same name as a previous variable. The new variable **shadows** the previous one.
- **How it differs from mutation**: Shadowing creates a completely new variable, whereas mutation modifies an existing one. Shadowing requires the `let` keyword again.
- **Type-changing shadow**: You can shadow a variable and change its type.
- **Scope-based shadow**: A variable can be shadowed within an inner scope without affecting the outer scope.
```cairo
let score: u32 = 5;
let score: u32 = score * 2; // Shadows original
let score: felt252 = 'high'; // Shadows and changes type
```

## 6. Data Types
Cairo is a statically typed language. Every variable must have a specific type, though it can often be inferred.
- **Integer types**: Unsigned (`u8` to `u256`) and Signed (`i8` to `i128`).
- **felt252**: The fundamental type of Cairo, representing a field element.
- **bool**: Represents `true` or `false`.
- **ByteArray**: Used for standard strings of arbitrary length.
```cairo
let age: u8 = 25;
let very_large: u256 = 100_000_000_000;
let temperature: i32 = -10;
let is_valid: bool = true;
let name: ByteArray = "Abaan";
```

## 7. Type Inference & Suffix Annotations
The Cairo compiler can often infer the type of a variable from its assigned value. You can use suffix annotations directly on values to provide type hints without standard annotations.
```cairo
let inferred_val = 5_u32;
```

## 8. Underscore Prefix Convention
If you declare a variable but do not use it, the compiler will issue a warning. Prefixing the variable name with an underscore tells the compiler that the variable is intentionally unused.
```cairo
let _unused: u32 = 99;
```

## 9. Variable Scope & Block Scoping
Variables are valid only within the scope block `{}` where they are defined. Variables in an inner block can shadow variables in an outer block, but once the inner block ends, the outer variable is accessible again.
```cairo
let block_var: u32 = 100;
{
    let block_var: u32 = 500; // Only exists within this block
}
// Here, block_var is 100 again
```

## 10. felt252 Deep Dive
- **What is a field element?**: `felt252` is Cairo's native primitive type. All other types (like `u32` or `bool`) are built on top of it under the hood.
- **Short string encoding**: It can store strings up to 31 characters long. These strings are enclosed in single quotes (`''`).
- **Range and arithmetic**: Its values range from `0` up to `P - 1`, where `P` is a very large prime number used in STARK proofs.
```cairo
let status_label: felt252 = 'pending';
```

## 11. Integer Overflow
Cairo integers have strictly defined bounds (e.g., `u8` can only hold 0 to 255). If an operation exceeds these bounds, the program will panic (crash) at runtime, ensuring safer code execution compared to silent wrapping.

## 12. Summary Table

| Concept | Keyword / Syntax | Example | Description |
|---|---|---|---|
| Immutable | `let name: Type = value;` | `let age: u8 = 25;` | Cannot be changed after assignment. |
| Mutable | `let mut name: Type = value;` | `let mut age: u8 = 25;` | Value can be reassigned. |
| Constant | `const NAME: Type = value;` | `const MAX: u8 = 100;` | Evaluated at compile-time, module scope. |
| Shadowing | `let name` ... `let name` | `let score = 5; let score = 10;` | Re-declaring a variable with same name. |
| Unused | `let _name: Type = value;` | `let _temp: u8 = 0;` | Suppresses unused variable warnings. |

## 13. References
- [The Cairo Book - Variables and Mutability](https://book.cairo-lang.org/ch02-01-variables-and-mutability.html)
- [The Cairo Book - Data Types](https://book.cairo-lang.org/ch02-02-data-types.html)
