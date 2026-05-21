// ============================================================
// Simple Searching Algorithms in Cairo
// Student: Syed Tabish Ali
// Assignment: Simple_Algorithms_Searching
// ============================================================
//
// What is searching?
// Searching means finding a specific item inside a list/array.
// Just like searching for a name in your contact list.
//
// We will implement two types of searching:
// 1. Linear Search  --> Check every item one by one
// 2. Binary Search  --> Keep cutting the list in half (only works on sorted lists)
// ============================================================


// ============================================================
// ALGORITHM 1: LINEAR SEARCH
// ============================================================
// How it works (very simple explanation):
// - Start from the first item in the array
// - Check: is this the item I'm looking for?
// - If YES --> return its position (index)
// - If NO  --> move to the next item
// - If we reach the end and never found it --> return None
//
// Example:
//   Array = [10, 25, 7, 42, 3]
//   Search for 42
//   Step 1: Is 10 == 42? No
//   Step 2: Is 25 == 42? No
//   Step 3: Is 7  == 42? No
//   Step 4: Is 42 == 42? YES! Found at index 3
// ============================================================

fn linear_search(arr: @Array<u32>, target: u32) -> Option<usize> {
    let mut i: usize = 0;       // Start from position 0 (first item)
    let len = arr.len();        // Total number of items in the array

    loop {
        // If we have gone through all items and didn't find it
        if i >= len {
            break Option::None; // Return None (means "not found")
        }

        // Check if current item equals what we are looking for
        if *arr[i] == target {
            break Option::Some(i); // Return the position where we found it
        }

        i += 1; // Move to the next item
    }
}


// ============================================================
// ALGORITHM 2: BINARY SEARCH
// ============================================================
// How it works (very simple explanation):
// IMPORTANT: The array MUST be sorted (arranged in order) first!
//
// Think of it like guessing a number between 1 and 100:
// - You guess 50 first (the middle)
// - If the answer is higher, you now search between 51-100
// - If the answer is lower, you now search between 1-49
// - Keep doing this until you find it
//
// Example:
//   Sorted Array = [5, 10, 15, 20, 25, 30]
//   Search for 20
//   Step 1: Middle = index 2 (value 15). 15 < 20, so search right half
//   Step 2: Middle = index 4 (value 25). 25 > 20, so search left half
//   Step 3: Middle = index 3 (value 20). 20 == 20, FOUND at index 3!
// ============================================================

fn binary_search(arr: @Array<u32>, target: u32) -> Option<usize> {
    let mut low: usize = 0;          // Start of our search range
    let mut high: usize = arr.len(); // End of our search range

    loop {
        // If the search range is empty, the item is not in the array
        if low >= high {
            break Option::None; // Return None (means "not found")
        }

        // Find the middle position
        let mid: usize = low + (high - low) / 2;
        let mid_val = *arr[mid]; // Get the value at the middle position

        if mid_val == target {
            // We found the target at position 'mid'
            break Option::Some(mid);
        } else if mid_val < target {
            // Target is bigger, so search the RIGHT half
            low = mid + 1;
        } else {
            // Target is smaller, so search the LEFT half
            high = mid;
        }
    }
}


// ============================================================
// MAIN FUNCTION
// This is where the program starts running.
// We test both algorithms here.
// ============================================================

fn main() {
    // ----------------------------------------------------------
    // TEST 1: Linear Search
    // ----------------------------------------------------------
    println!("========================================");
    println!("       LINEAR SEARCH TESTS");
    println!("========================================");

    // Create an unsorted array
    let mut arr: Array<u32> = ArrayTrait::new();
    arr.append(10);
    arr.append(25);
    arr.append(7);
    arr.append(42);
    arr.append(3);
    // Array looks like: [10, 25, 7, 42, 3]

    // Test 1a: Search for 42 (it EXISTS in the array at index 3)
    let result1 = linear_search(@arr, 42);
    match result1 {
        Option::Some(index) => println!("Linear Search: 42 found at index {}", index),
        Option::None => println!("Linear Search: 42 NOT found"),
    }

    // Test 1b: Search for 99 (it does NOT exist in the array)
    let result2 = linear_search(@arr, 99);
    match result2 {
        Option::Some(index) => println!("Linear Search: 99 found at index {}", index),
        Option::None => println!("Linear Search: 99 NOT found"),
    }

    // Test 1c: Search for 10 (it exists at the very beginning, index 0)
    let result3 = linear_search(@arr, 10);
    match result3 {
        Option::Some(index) => println!("Linear Search: 10 found at index {}", index),
        Option::None => println!("Linear Search: 10 NOT found"),
    }


    // ----------------------------------------------------------
    // TEST 2: Binary Search
    // ----------------------------------------------------------
    println!("========================================");
    println!("       BINARY SEARCH TESTS");
    println!("========================================");

    // Create a SORTED array (this is required for Binary Search)
    let mut sorted_arr: Array<u32> = ArrayTrait::new();
    sorted_arr.append(5);
    sorted_arr.append(10);
    sorted_arr.append(15);
    sorted_arr.append(20);
    sorted_arr.append(25);
    sorted_arr.append(30);
    // Array looks like: [5, 10, 15, 20, 25, 30]

    // Test 2a: Search for 20 (it EXISTS at index 3)
    let result4 = binary_search(@sorted_arr, 20);
    match result4 {
        Option::Some(index) => println!("Binary Search: 20 found at index {}", index),
        Option::None => println!("Binary Search: 20 NOT found"),
    }

    // Test 2b: Search for 13 (it does NOT exist)
    let result5 = binary_search(@sorted_arr, 13);
    match result5 {
        Option::Some(index) => println!("Binary Search: 13 found at index {}", index),
        Option::None => println!("Binary Search: 13 NOT found"),
    }

    // Test 2c: Search for 5 (it exists at the very beginning, index 0)
    let result6 = binary_search(@sorted_arr, 5);
    match result6 {
        Option::Some(index) => println!("Binary Search: 5 found at index {}", index),
        Option::None => println!("Binary Search: 5 NOT found"),
    }

    // Test 2d: Search for 30 (it exists at the very end, index 5)
    let result7 = binary_search(@sorted_arr, 30);
    match result7 {
        Option::Some(index) => println!("Binary Search: 30 found at index {}", index),
        Option::None => println!("Binary Search: 30 NOT found"),
    }

    println!("========================================");
    println!("         ALL TESTS COMPLETE!");
    println!("========================================");
}
