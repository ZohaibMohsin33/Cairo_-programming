// Generics Assignment - Cairo Programming
// Topic: Generics in Cairo
// Name: Manahil Khalid

// I studied generics from the Cairo book. Basically generics let you write
// one function or struct that works for multiple types instead of writing
// the same thing over and over for u32, u64, felt252 etc.

// --------------------------------------------------
// Part 1: Generic Struct
// I made a simple Wrapper struct that can hold any type
// --------------------------------------------------

#[derive(Drop)]
struct Wrapper<T> {
    value: T,
}

// trait for the wrapper
trait WrapperTrait<T> {
    fn new(val: T) -> Wrapper<T>;
    fn get(self: @Wrapper<T>) -> T;
}

// impl needs Drop and Copy so Cairo knows how to handle memory
impl WrapperImpl<T, +Drop<T>, +Copy<T>> of WrapperTrait<T> {
    fn new(val: T) -> Wrapper<T> {
        Wrapper { value: val }
    }

    fn get(self: @Wrapper<T>) -> T {
        *self.value
    }
}


// --------------------------------------------------
// Part 2: Generic Function
// finds the biggest number in an array
// T needs PartialOrd so we can compare, Copy so we can read values
// --------------------------------------------------

fn find_largest<T, +PartialOrd<T>, +Copy<T>, +Drop<T>>(list: @Array<T>) -> T {
    // cant work on empty array
    assert!(list.len() > 0, "array is empty");

    let mut largest = *list.at(0);
    let mut i: usize = 1;

    loop {
        if i == list.len() {
            break;
        }
        let current = *list.at(i);
        if current > largest {
            largest = current;
        }
        i += 1;
    };

    largest
}


// --------------------------------------------------
// Part 3: Generic Struct with two type params
// Pair can hold two values of different types
// --------------------------------------------------

#[derive(Drop, Copy)]
struct Pair<T, U> {
    first: T,
    second: U,
}

trait PairTrait<T, U> {
    fn new(a: T, b: U) -> Pair<T, U>;
    fn first(self: @Pair<T, U>) -> T;
    fn second(self: @Pair<T, U>) -> U;
}

impl PairImpl<T, +Copy<T>, +Drop<T>, U, +Copy<U>, +Drop<U>> of PairTrait<T, U> {
    fn new(a: T, b: U) -> Pair<T, U> {
        Pair { first: a, second: b }
    }

    fn first(self: @Pair<T, U>) -> T {
        *self.first
    }

    fn second(self: @Pair<T, U>) -> U {
        *self.second
    }
}


// --------------------------------------------------
// Part 4: Generic Enum
// similar to Option<T> from the Cairo standard library
// either has a value or doesnt
// --------------------------------------------------

#[derive(Drop)]
enum MyOption<T> {
    Some: T,
    None,
}


// --------------------------------------------------
// Part 5: Generic Stack
// LIFO structure - last in first out
// push adds to top, pop removes from top
// --------------------------------------------------

#[derive(Drop)]
struct Stack<T> {
    data: Array<T>,
}

trait StackTrait<T> {
    fn new() -> Stack<T>;
    fn push(ref self: Stack<T>, val: T);
    fn pop(ref self: Stack<T>) -> MyOption<T>;
    fn is_empty(self: @Stack<T>) -> bool;
    fn size(self: @Stack<T>) -> usize;
}

impl StackImpl<T, +Drop<T>, +Copy<T>> of StackTrait<T> {
    fn new() -> Stack<T> {
        Stack { data: ArrayTrait::new() }
    }

    fn push(ref self: Stack<T>, val: T) {
        self.data.append(val);
    }

    // pop removes last element
    // Cairo arrays dont have pop_back so i rebuild the array manually
    fn pop(ref self: Stack<T>) -> MyOption<T> {
        let len = self.data.len();
        if len == 0 {
            return MyOption::None;
        }

        let mut temp: Array<T> = ArrayTrait::new();
        let mut i: usize = 0;
        let mut result: MyOption<T> = MyOption::None;

        loop {
            if i == len {
                break;
            }
            let v = *self.data.at(i);
            if i == len - 1 {
                result = MyOption::Some(v); // this is the top element
            } else {
                temp.append(v);
            }
            i += 1;
        };

        self.data = temp;
        result
    }

    fn is_empty(self: @Stack<T>) -> bool {
        self.data.len() == 0
    }

    fn size(self: @Stack<T>) -> usize {
        self.data.len()
    }
}


// --------------------------------------------------
// main - testing everything
// --------------------------------------------------

fn main() {
    // testing Wrapper with u32
    let w: Wrapper<u32> = WrapperTrait::new(55_u32);
    println!("wrapper value: {}", w.get());

    // testing Wrapper with felt252
    let w2: Wrapper<felt252> = WrapperTrait::new('hello');
    println!("wrapper felt: {}", w2.get());

    // testing find_largest
    let mut nums: Array<u64> = ArrayTrait::new();
    nums.append(4_u64);
    nums.append(12_u64);
    nums.append(7_u64);
    nums.append(2_u64);
    let big = find_largest(@nums);
    println!("largest: {}", big); // should print 12

    // testing Pair
    let p: Pair<u32, u64> = PairTrait::new(10_u32, 999_u64);
    println!("pair first: {}", p.first());
    println!("pair second: {}", p.second());

    // testing Stack with u32
    let mut s: Stack<u32> = StackTrait::new();
    println!("stack empty? {}", s.is_empty()); // true

    s.push(1_u32);
    s.push(2_u32);
    s.push(3_u32);
    println!("stack size: {}", s.size()); // 3

    match s.pop() {
        MyOption::Some(v) => println!("popped: {}", v), // 3
        MyOption::None => println!("nothing to pop"),
    }

    println!("stack size after pop: {}", s.size()); // 2

    // testing MyOption enum
    let x: MyOption<u32> = MyOption::Some(42_u32);
    match x {
        MyOption::Some(v) => println!("got value: {}", v),
        MyOption::None => println!("no value"),
    }

    let y: MyOption<u32> = MyOption::None;
    match y {
        MyOption::Some(_) => println!("got value"),
        MyOption::None => println!("none as expected"),
    }
}
