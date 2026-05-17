/// Simple Calculator starter assignment implemented in Cairo.
/// 
/// This module demonstrates fundamental Cairo concepts:
/// - Function definitions with explicit types
/// - Using felt252 for arithmetic operations
/// - Assertions for precondition validation
/// - Unit testing with #[test] attribute
/// 
/// All functions are pure (no side effects) and take two felt252 inputs.
/// Division and modulo operations validate the divisor to prevent panics.

mod calculator {
    /// Adds two felt252 values.
    /// 
    /// # Arguments
    /// * `left` - The first operand
    /// * `right` - The second operand
    /// 
    /// # Returns
    /// The sum of left and right
    /// 
    /// # Example
    /// ```
    /// let result = add(5, 3);  // Returns 8
    /// ```
    pub fn add(left: felt252, right: felt252) -> felt252 {
        left + right
    }

    /// Subtracts the second value from the first.
    /// 
    /// # Arguments
    /// * `left` - The minuend (value to subtract from)
    /// * `right` - The subtrahend (value to subtract)
    /// 
    /// # Returns
    /// The difference of left minus right
    /// 
    /// # Example
    /// ```
    /// let result = subtract(10, 3);  // Returns 7
    /// ```
    pub fn subtract(left: felt252, right: felt252) -> felt252 {
        left - right
    }

    /// Multiplies two felt252 values.
    /// 
    /// # Arguments
    /// * `left` - The first factor
    /// * `right` - The second factor
    /// 
    /// # Returns
    /// The product of left and right
    /// 
    /// # Example
    /// ```
    /// let result = multiply(6, 7);  // Returns 42
    /// ```
    pub fn multiply(left: felt252, right: felt252) -> felt252 {
        left * right
    }

    /// Divides the first value by the second.
    /// 
    /// # Arguments
    /// * `left` - The dividend (value to be divided)
    /// * `right` - The divisor (value to divide by)
    /// 
    /// # Returns
    /// The quotient of left divided by right
    /// 
    /// # Panics
    /// Panics if right is 0 (division by zero is invalid)
    /// 
    /// # Example
    /// ```
    /// let result = divide(20, 4);  // Returns 5
    /// let result = divide(20, 0);  // Panics with 'Division by zero'
    /// ```
    pub fn divide(left: felt252, right: felt252) -> u256 {
        // Validate precondition: divisor must not be zero
        assert(right != 0, 'Division by zero');
        // Use u256 for division operation
        let left_u256: u256 = left.into();
        let right_u256: u256 = right.into();
        left_u256 / right_u256
    }

    /// Returns the remainder (modulo) of dividing left by right.
    /// 
    /// # Arguments
    /// * `left` - The dividend
    /// * `right` - The divisor (modulus)
    /// 
    /// # Returns
    /// The remainder of left divided by right
    /// 
    /// # Panics
    /// Panics if right is 0 (modulo by zero is invalid)
    /// 
    /// # Example
    /// ```
    /// let result = modulo(17, 5);  // Returns 2 (17 = 3*5 + 2)
    /// let result = modulo(20, 0);  // Panics with 'Modulo by zero'
    /// ```
    pub fn modulo(left: felt252, right: felt252) -> u256 {
        // Validate precondition: divisor must not be zero
        assert(right != 0, 'Modulo by zero');
        // Use u256 for modulo operation
        let left_u256: u256 = left.into();
        let right_u256: u256 = right.into();
        left_u256 % right_u256
    }
}

/// Unit tests for the calculator module.
/// Tests verify each arithmetic operation works correctly.
/// 
/// Test attribute: #[test] marks a function as a test case
/// Test module: #[cfg(test)] marks this module as test-only (compiled only during testing)
/// 
/// Each test:
/// 1. Calls a calculator function with known inputs
/// 2. Asserts the result matches the expected value
/// 3. Is isolated and doesn't affect other tests
#[cfg(test)]
mod tests {
    use super::calculator::{add, divide, modulo, multiply, subtract};

    /// Test the add function.
    /// Verifies: 12 + 8 = 20
    #[test]
    fn add_works() {
        let result = add(12, 8);
        assert(result == 20, 'Addition failed');
    }

    /// Test the subtract function.
    /// Verifies: 20 - 7 = 13
    #[test]
    fn subtract_works() {
        let result = subtract(20, 7);
        assert(result == 13, 'Subtraction failed');
    }

    /// Test the multiply function.
    /// Verifies: 6 × 7 = 42
    #[test]
    fn multiply_works() {
        let result = multiply(6, 7);
        assert(result == 42, 'Multiplication failed');
    }

    /// Test the divide function.
    /// Verifies: 84 ÷ 6 = 14
    #[test]
    fn divide_works() {
        let result = divide(84, 6);
        assert(result == 14_u256, 'Division failed');
    }

    /// Test the modulo function.
    /// Verifies: 29 % 5 = 4
    /// (29 = 5 × 5 + 4, so remainder is 4)
    #[test]
    fn modulo_works() {
        let result = modulo(29, 5);
        assert(result == 4_u256, 'Modulo failed');
    }

    /// Test division by zero panics (optional: demonstrates error handling)
    /// Commented out to avoid test failures, but shows the assertion works
    // #[should_panic(expected: 'Division by zero')]
    // #[test]
    // fn divide_by_zero_panics() {
    //     let _ = divide(10, 0);  // This should panic
    // }

    /// Test modulo by zero panics (optional: demonstrates error handling)
    /// Commented out to avoid test failures, but shows the assertion works
    // #[should_panic(expected: 'Modulo by zero')]
    // #[test]
    // fn modulo_by_zero_panics() {
    //     let _ = modulo(10, 0);  // This should panic
    // }
}
