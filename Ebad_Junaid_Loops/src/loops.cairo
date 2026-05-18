// Assignment: Loops in Cairo
// Name: Ebad Junaid
// Roll No: BSCS22046

#[executable]
fn main() {
//     // TODO: Use a loop to print numbers 1 to 10.
//     // TODO: Calculate and print the sum of these numbers.

//     // Example:
//     // let mut sum = 0;
//     // for i in 1..=10 {
//     //     println!("{} ", i);
//     //     sum += i;
//     // }
//     // println!("Sum = {}", sum);

    // my code

    // Variables are immutable by default in Cairo.
    // We use 'mut' so we can update the counter and sum.

    let mut counter: u32 = 1;
    let mut sum: u32 = 0;

    println!("Numbers:");

    // Using a while loop as suggested by the compiler for clarity.
    while counter <= 10 {
        // Print the current number
        println!("{}", counter);

        // Add current number to the total
        sum += counter;

        // Increment the counter
        counter += 1;
    };

    println!("Sum = {}", sum);


}
