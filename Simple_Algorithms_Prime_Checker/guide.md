# Simple Algorithm: Prime Checker

## Introduction

A prime number is a number greater than 1 that has only two factors: 1 and itself.

Examples:

- 2 is prime
- 3 is prime
- 4 is not prime because it is divisible by 2
- 9 is not prime because it is divisible by 3

## Objective

The objective of this assignment is to create a simple algorithm in Cairo that checks whether a number is prime or not.

The function returns:

- `true` if the number is prime
- `false` if the number is not prime

## Algorithm

1. If the number is less than 2, return false.
2. Start checking divisibility from 2.
3. If the number is divisible by any divisor, return false.
4. Keep checking until divisor × divisor becomes greater than the number.
5. If no divisor divides the number, return true.

## Cairo Code

```cairo
pub fn is_prime(number: u32) -> bool {
    if number < 2 {
        return false;
    }

    let mut divisor: u32 = 2;

    loop {
        if divisor * divisor > number {
            break;
        }

        if number % divisor == 0 {
            return false;
        }

        divisor += 1;
    };

    true
}
```

## Code Explanation

`pub fn is_prime(number: u32) -> bool` defines a public function named `is_prime`.

`number: u32` means the input number is an unsigned 32-bit integer.

`-> bool` means the function returns either `true` or `false`.

If the number is less than 2, it is not prime.

The variable `divisor` starts from 2 because every number is divisible by 1, so checking from 1 is not useful.

The loop checks whether the number is divisible by the divisor.

If `number % divisor == 0`, then the number is not prime.

The loop stops when `divisor * divisor > number` because checking beyond the square root is unnecessary.

If no divisor is found, the function returns `true`.

## Test Cases

| Number | Result | Reason |
|---|---|---|
| 0 | false | Less than 2 |
| 1 | false | Less than 2 |
| 2 | true | Prime number |
| 3 | true | Prime number |
| 4 | false | Divisible by 2 |
| 5 | true | Prime number |
| 9 | false | Divisible by 3 |
| 11 | true | Prime number |

## Conclusion

This assignment demonstrates how to write a simple prime checker algorithm in Cairo. It uses functions, loops, conditions, boolean values, and the modulo operator.
