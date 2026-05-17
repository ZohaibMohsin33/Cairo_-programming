# Simple Searching Algorithms in Cairo
**Student:** Syed Tabish Ali  
**Assignment:** Simple_Algorithms_Searching  
**Language:** Cairo (Starknet Smart Contract Language)

---

## What is Cairo?

Cairo is a programming language created by StarkWare. It is used to write smart contracts on **Starknet**, which is a Layer 2 blockchain built on top of Ethereum. Cairo is inspired by the **Rust** programming language, so its syntax looks similar to Rust.

What makes Cairo special is that every program written in Cairo can generate a **mathematical proof** that the program ran correctly. This is very useful in blockchain because you don't have to trust anyone — the math proves it.

---

## What is Searching?

Imagine you have a list of 1000 phone numbers and you want to find one specific number. How would you find it?

- You could check every number one by one — this is **Linear Search**
- If the list is sorted, you could open it in the middle, and keep narrowing down — this is **Binary Search**

Searching is one of the most basic and important things in computer science. We use it every day — when you search Google, when you look for a contact, when you search for a file.

---

## Algorithm 1: Linear Search

### Simple Explanation
Linear Search is the simplest search algorithm. It goes through the list **from the beginning to the end**, checking each element one by one until it finds the target.

Think of it like looking for your keys in your bag — you check every pocket one by one until you find them.

### Step-by-Step Example
```
Array = [10, 25, 7, 42, 3]
Target = 42

Step 1: Check index 0 → value is 10 → 10 ≠ 42 → move on
Step 2: Check index 1 → value is 25 → 25 ≠ 42 → move on
Step 3: Check index 2 → value is 7  → 7  ≠ 42 → move on
Step 4: Check index 3 → value is 42 → 42 = 42 → FOUND! Return index 3
```

### When to Use Linear Search
- When your list is **not sorted**
- When the list is **small**
- When you need a **simple solution**

### Performance (Time Complexity)
| Case | Speed |
|------|-------|
| Best case (found at start) | O(1) — very fast |
| Worst case (found at end or not found) | O(n) — slow for large lists |

`O(n)` means: if there are 1000 items, you might need 1000 checks in the worst case.

---

## Algorithm 2: Binary Search

### Simple Explanation
Binary Search is a **smart and fast** search algorithm. BUT it only works on a **sorted array** (numbers must be in order, smallest to largest).

Think of it like finding a word in a dictionary:
- You open the dictionary in the middle
- If the word comes before the middle, you search the left half
- If the word comes after the middle, you search the right half
- You keep doing this until you find the word

### Step-by-Step Example
```
Sorted Array = [5, 10, 15, 20, 25, 30]
Indices       = [0,  1,  2,  3,  4,  5]
Target = 20

Step 1:
  low=0, high=6, mid=3 → arr[3]=20 → 20 == 20 → FOUND at index 3!
```

Another example — searching for 25:
```
Sorted Array = [5, 10, 15, 20, 25, 30]
Target = 25

Step 1: low=0, high=6, mid=3 → arr[3]=20 → 20 < 25 → search RIGHT half
Step 2: low=4, high=6, mid=5 → arr[5]=30 → 30 > 25 → search LEFT half
Step 3: low=4, high=5, mid=4 → arr[4]=25 → 25 == 25 → FOUND at index 4!
```

### When to Use Binary Search
- When your list **IS sorted**
- When the list is **large** and speed matters
- When you want a **much faster** search than Linear Search

### Performance (Time Complexity)
| Case | Speed |
|------|-------|
| Best case (found at middle immediately) | O(1) — very fast |
| Worst case | O(log n) — very fast even for large lists |

`O(log n)` means: if there are **1,000,000** items, Binary Search only needs about **20 checks**!  
Compare that to Linear Search which might need 1,000,000 checks!

---

## Comparison Table

| Feature | Linear Search | Binary Search |
|--------|--------------|--------------|
| Works on unsorted array? | ✅ Yes | ❌ No (must be sorted) |
| Easy to understand? | ✅ Very easy | 🔶 A bit harder |
| Speed (small list) | Similar | Similar |
| Speed (large list) | 🐢 Slow — O(n) | 🚀 Fast — O(log n) |
| Best for | Small/unsorted lists | Large sorted lists |

---

## Cairo-Specific Concepts Used in This Code

### 1. `Array<u32>`
This is how we create a list of numbers in Cairo. `u32` means an unsigned 32-bit integer (a positive whole number up to 4,294,967,295).

```cairo
let mut arr: Array<u32> = ArrayTrait::new();
arr.append(10);
arr.append(25);
```

### 2. `Option<usize>`
In Cairo, when a function might or might not return a value, we use `Option`. It has two cases:
- `Option::Some(value)` — we found something, here is the value
- `Option::None` — we found nothing

```cairo
// Example: function that might return an index
fn linear_search(arr: @Array<u32>, target: u32) -> Option<usize>
```

### 3. `match`
`match` is used to check which case of `Option` we got. It's like an if-else but cleaner.

```cairo
match result {
    Option::Some(index) => println!("Found at index {}", index),
    Option::None => println!("Not found"),
}
```

### 4. `@` (Snapshot)
The `@` symbol before `arr` means we are passing a "snapshot" (read-only view) of the array. This prevents Cairo from consuming the array when we pass it to the function.

```cairo
linear_search(@arr, 42)  // @ means "read only, don't consume"
```

### 5. `loop` and `break`
Cairo uses `loop` for repeating code. We use `break` to exit the loop and return a value.

```cairo
loop {
    if condition {
        break Option::Some(i); // exit loop and return value
    }
    i += 1;
}
```

---

## How to Run This Code

1. Make sure you have **Scarb** installed (Cairo's package manager)
2. Create a new project: `scarb new searching_project`
3. Copy the `searching_algorithms.cairo` code into `src/lib.cairo`
4. Run: `scarb cairo-run`

---

## Expected Output

```
========================================
       LINEAR SEARCH TESTS
========================================
Linear Search: 42 found at index 3
Linear Search: 99 NOT found
Linear Search: 10 found at index 0
========================================
       BINARY SEARCH TESTS
========================================
Binary Search: 20 found at index 3
Binary Search: 13 NOT found
Binary Search: 5 found at index 0
Binary Search: 30 found at index 5
========================================
         ALL TESTS COMPLETE!
========================================
```

---

## Key Takeaways

1. **Linear Search** = Simple but slow for large data. Checks every item.
2. **Binary Search** = Fast but requires sorted data. Cuts the search in half each time.
3. Cairo uses `Option` to safely handle "not found" cases.
4. Cairo's syntax is similar to Rust — variables, loops, match expressions.
5. Both algorithms are building blocks of more complex programs and smart contracts.

---

## References
- [The Cairo Book](https://www.starknet.io/cairo-book/) — Official Cairo documentation
- [Cairo by Example](https://cairo-by-example.com/) — Practical Cairo examples
- [Starknet Documentation](https://docs.starknet.io/) — Starknet official docs
