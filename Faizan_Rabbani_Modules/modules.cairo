
// Define a module
mod math_utils {
    // Public function (accessible outside module)
    pub fn add(a: felt252, b: felt252) -> felt252 {
        a + b
    }

    pub fn subtract(a: felt252, b: felt252) -> felt252 {
        a - b
    }

    // Private function (only inside module)
    fn multiply(a: felt252, b: felt252) -> felt252 {
        a * b
    }

    // Public function using private function
    pub fn square(x: felt252) -> felt252 {
        multiply(x, x)
    }
}

// Another module
mod greetings {
    pub fn say_hello() -> felt252 {
        1  // Just a placeholder (Cairo doesn't print directly)
    }
}

// Main function
#[executable]
fn main() {
    // Using module functions
    let sum = math_utils::add(10, 5);
    let diff = math_utils::subtract(10, 5);
    let sq = math_utils::square(4);

    let greet = greetings::say_hello();

    // Return values (for testing)
    assert(sum == 15, 'Addition failed');
    assert(diff == 5, 'Subtraction failed');
    assert(sq == 16, 'Square failed');
    assert(greet == 1, 'Greeting failed');
}