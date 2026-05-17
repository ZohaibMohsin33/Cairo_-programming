fn is_palindrome(mut arr: Span<felt252>) -> bool {
    loop {
        
        if arr.len() <= 1 {
            break true;
        }
        
        
        let first = arr.pop_front().unwrap();
        let last = arr.pop_back().unwrap();
        
        
        if first != last {
            break false;
        }
    }
}


fn main() {
   
    let mut palindrome_arr = array![1, 2, 3, 2, 1];
    let mut non_palindrome_arr = array![1, 2, 3, 4, 5];

   
    let result1 = is_palindrome(palindrome_arr.span());
    let result2 = is_palindrome(non_palindrome_arr.span());

    if result1 {
        println!("Array 1 is a palindrome!");
    } else {
        println!("Array 1 is NOT a palindrome.");
    }

    if result2 {
        println!("Array 2 is a palindrome!");
    } else {
        println!("Array 2 is NOT a palindrome.");
    }
}


#[cfg(test)]
mod tests {
    use super::is_palindrome;

    #[test]
    fn test_valid_palindrome() {
        let arr = array![9, 8, 7, 8, 9];
        // FIX: Removed "== true", just pass the function directly
        assert(is_palindrome(arr.span()), 'Should be true');
    }

    #[test]
    fn test_invalid_palindrome() {
        let arr = array![1, 2, 3];
        // FIX: Replaced "== false" with the ! (NOT) operator
        assert(!is_palindrome(arr.span()), 'Should be false');
    }
}