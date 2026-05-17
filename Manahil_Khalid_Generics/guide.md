# Generics in Cairo

**Name:** Manahil Khalid  
**Topic:** Generics  

---

## What are Generics?

So basically generics are a way to write code that works for multiple types without copy pasting the same logic again and again. Instead of making a separate function for u32, u64, felt252 etc., you write it once with a type placeholder (usually called T) and it works for all of them.

For example without generics you'd have to do something like:

```cairo
fn wrap_u32(val: u32) -> u32 { val }
fn wrap_u64(val: u64) -> u64 { val }
// and so on...
```

With generics you just write:

```cairo
fn wrap<T>(val: T) -> T { val }
```

Much cleaner. Cairo's own standard library uses generics everywhere — Array<T>, Option<T>, Result<T, E> are all generic.

---

## Generic Functions

You put the type parameter in angle brackets right after the function name:

```cairo
fn identity<T>(x: T) -> T {
    x
}
```

If you need to do something with T like compare values or print it, you have to add trait bounds. These tell Cairo what T is capable of:

```cairo
fn find_largest<T, +PartialOrd<T>, +Copy<T>, +Drop<T>>(list: @Array<T>) -> T {
    // now we can use > because of PartialOrd
}
```

---

## Trait Bounds

This was the trickiest part honestly. When you write a generic function or impl, Cairo needs to know what the type T can actually do. You specify this using `+TraitName<T>` in the generic parameters.

Common ones:

- `+Drop<T>` — means T can be dropped from memory (almost always needed)
- `+Copy<T>` — means T can be copied, so you can read it without consuming it
- `+PartialOrd<T>` — means you can compare T values with < and >
- `+PartialEq<T>` — means you can check equality with ==

---

## Generic Structs

You can make structs hold any type:

```cairo
#[derive(Drop)]
struct Wrapper<T> {
    value: T,
}
```

The `#[derive(Drop)]` is needed so Cairo knows how to remove this from memory when its done. Without it the compiler complains.

For two different types in one struct:

```cairo
#[derive(Drop, Copy)]
struct Pair<T, U> {
    first: T,
    second: U,
}
```

---

## Generic Traits and Impls

A trait defines what a type should be able to do. When combined with generics it becomes really powerful:

```cairo
trait StackTrait<T> {
    fn new() -> Stack<T>;
    fn push(ref self: Stack<T>, val: T);
    fn pop(ref self: Stack<T>) -> MyOption<T>;
}
```

Then the impl provides the actual code. The impl also needs to declare its own bounds:

```cairo
impl StackImpl<T, +Drop<T>, +Copy<T>> of StackTrait<T> {
    // actual implementation here
}
```

---

## Generic Enums

Enums can be generic too. The Cairo standard library has Option<T> which is either Some(value) or None. I made my own version called MyOption<T> to understand how it works:

```cairo
#[derive(Drop)]
enum MyOption<T> {
    Some: T,
    None,
}
```

You use match to handle both cases safely which avoids null errors completely.

---

## What I implemented

I wrote 5 things in the cairo file:

1. **Wrapper<T>** - simple generic struct that stores any value and lets you get it back
2. **find_largest<T>** - generic function that finds the max element in an array
3. **Pair<T, U>** - struct with two different generic types
4. **MyOption<T>** - custom generic enum to understand how Option<T> works internally
5. **Stack<T>** - a full LIFO stack implementation that works with any type

One thing I found annoying is Cairo arrays don't have pop_back, so for the stack I had to manually rebuild the array every time you pop. Not the most efficient but it works.

---

## How to Run

You need Scarb installed first (Cairo's build tool).

```bash
scarb new my_generics
cd my_generics
# paste the code into src/lib.cairo
scarb build
scarb run
```

---

## References

- The Cairo Book - chapter on Generics: https://book.cairo-lang.org/ch08-01-generic-data-types.html
- Cairo docs on generics: https://docs.cairo-lang.org/language_constructs/generics.html
