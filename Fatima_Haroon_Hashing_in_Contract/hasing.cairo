%lang starknet

from starkware.cairo.common.hash import hash2

// Storage variable to store a value
@storage_var
func stored_value() -> (res: felt):
end

// Function to store a value on blockchain
@external
func set_value{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(value: felt):
    stored_value.write(value)
    return ()
end

// Function to retrieve stored value
@view
func get_value{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (value: felt):
    let (value) = stored_value.read()
    return (value=value)
end

// Function to hash a value using Cairo hash2
@view
func hash_value{range_check_ptr}(value: felt) -> (hashed: felt):
    let (res) = hash2(value, value)
    return (hashed=res)
end