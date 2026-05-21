pub fn is_prime(number: u32) -> bool {
    // this checks whether the number is prime or not 

    if number < 2 {
        //if 1 or 0, return false automatically

        return false;
    }

    // strat to check divisiblity by 2 
    let mut divisor: u32 = 2;

    loop {

        // continue until the suare becoms greater than the number

        if divisor * divisor > number {
            break;
        }


        // if a number is divided then it not prime for sure 
        if number % divisor == 0 {
            return false;
        }

        divisor += 1;
    };
    true
}


#[cfg(test)]
mod tests {
    use super::is_prime;


    // for primes 

    #[test]
    fn test_prime_numbers() {
        assert!(is_prime(2));
        assert!(is_prime(3));
        assert!(is_prime(5));
        assert!(is_prime(7));
        assert!(is_prime(11));
    }


    // for no-primes

    #[test]
    fn test_non_prime_numbers() {
        assert!(!is_prime(0));
        assert!(!is_prime(1));
        assert!(!is_prime(4));
        assert!(!is_prime(9));
        assert!(!is_prime(15));
    }
}
