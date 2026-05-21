// Algorithms Calculator in Cairo
// The module implements basic mathematical operations and algorithms

// Adds two integers and returns the result
fn add(a: i32, b: i32) -> i32 {
    a + b
}

// Subtracts b from a and returns the result
fn subtract(a: i32, b: i32) -> i32 {
    a - b
}

// Multiplies two integers and returns the result
fn multiply(a: i32, b: i32) -> i32 {
    a * b
}

// Divides a by b, panics if b is zero to prevent division by zero error
fn divide(a: i32, b: i32) -> i32 {
    assert(b != 0, 'Cannot divide by zero');
    a / b
}

// Returns true if n is even, false if odd
fn is_even(n: i32) -> bool {
    n % 2 == 0
}

// Recursively calculates the factorial of n (e.g, 5! = 120)
fn factorial(n: u32) -> u32 {
    if n == 0 {
        1 // Base case: 0! = 1
    } else {
        n * factorial(n - 1) // Recursive case
    }
}

// Returns the larger of two integers
fn max(a: i32, b: i32) -> i32 {
    if a > b {
        a
    } else {
        b
    }
}

#[cfg(test)]
mod tests {
    use super::{add, subtract, multiply, divide, is_even, factorial, max};

    #[test]
    fn test_add() {
        assert(add(10, 5) == 15, 'add failed');
    }

    #[test]
    fn test_subtract() {
        assert(subtract(10, 5) == 5, 'subtract failed');
    }

    #[test]
    fn test_multiply() {
        assert(multiply(10, 5) == 50, 'multiply failed');
    }

    #[test]
    fn test_divide() {
        assert(divide(10, 5) == 2, 'divide failed');
    }

    #[test]
    fn test_is_even() {
        assert(is_even(4) == true, 'is_even failed');
    }

    #[test]
    fn test_factorial() {
        assert(factorial(5) == 120, 'factorial failed');
    }

    #[test]
    fn test_max() {
        assert(max(10, 5) == 10, 'max failed');
    }
}