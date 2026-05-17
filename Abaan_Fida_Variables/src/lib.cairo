
// MODULE-LEVEL CONSTANT (outside any function)
const MAX_SCORE: u32 = 100;
const APP_NAME: felt252 = 'CairoVars';

fn main() {

    // ── 1. IMMUTABLE VARIABLES ──────────────────
    // Variables are immutable by default in Cairo.
    // Reassigning this would cause a compiler error.
    let base_value: u32 = 10;

    // ── 2. MUTABLE VARIABLES ───────────────────
    // Using the `mut` keyword allows the variable to be reassigned later.
    let mut counter: u32 = 0;
    counter += 1;

    // ── 3. SHADOWING ───────────────────────────
    // Shadowing re-declares a variable with the same name.
    // It can also change the type of the variable.
    let score: u32 = 5;
    let score: u32 = score * 2; // Shadows original
    let score: felt252 = 'high'; // Shadows with a different type

    // ── 4. DATA TYPES ──────────────────────────
    // Unsigned integers
    let age: u8 = 25;
    let max_supply: u64 = 1_000_000;
    let very_large: u256 = 100_000_000_000;

    // Signed integers
    let temperature: i32 = -10;

    // felt252 (Cairo's native type)
    let id: felt252 = 42;

    // bool
    let is_valid: bool = true;

    // ByteArray
    let name: ByteArray = "Abaan";

    // ── 5. TYPE INFERENCE ──────────────────────
    // The compiler infers the type from the suffix annotation.
    let inferred_val = 5_u32;

    // ── 6. UNDERSCORE PREFIX ───────────────────
    // Prefixing with an underscore suppresses unused variable warnings.
    let _unused: u32 = 99;

    // ── 7. SCOPE DEMONSTRATION ─────────────────
    // Variables are scoped to their enclosing block.
    let block_var: u32 = 100;
    {
        // This shadows the outer block_var only within this block.
        let block_var: u32 = 500;
        println!("Inner block_var: {}", block_var);
    }

    // ── 8. felt252 DEEP DIVE ───────────────────
    // felt252 can store short strings (up to 31 characters).
    let status_label: felt252 = 'pending';

    // ── INTEGER OVERFLOW BEHAVIOUR ─────────────
    // Cairo integers have strict bounds (e.g., u8 is 0 to 255).
    // Operations that exceed these bounds will panic at runtime.
    // let overflow_example: u8 = 255;
    // let result = overflow_example + 1; // This would panic!

    // ── 9. PRINT ALL VALUES ────────────────────
    println!("APP_NAME: {}", APP_NAME);
    println!("MAX_SCORE: {}", MAX_SCORE);
    println!("base_value: {}", base_value);
    println!("counter: {}", counter);
    println!("score: {}", score);
    println!("age: {}", age);
    println!("max_supply: {}", max_supply);
    println!("very_large: {}", very_large);
    println!("temperature: {}", temperature);
    println!("id: {}", id);
    println!("is_valid: {}", is_valid);
    println!("name: {}", name);
    println!("inferred_val: {}", inferred_val);
    println!("block_var (outer): {}", block_var);
    println!("status_label: {}", status_label);
}
