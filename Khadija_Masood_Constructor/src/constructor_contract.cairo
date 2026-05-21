#[starknet::contract]
mod ConstructorContract {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess,
    };

    #[storage]
    struct Storage {
        owner: ContractAddress,
        value: u128,
        name: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u128, name: felt252) {
        // The deployer becomes the owner and sets initial state.
        self.owner.write(get_caller_address());
        self.value.write(initial_value);
        self.name.write(name);
    }

    #[external(v0)]
    fn set_value(ref self: ContractState, new_value: u128) {
        let caller = get_caller_address();
        assert(caller == self.owner.read(), 'Only owner can set value');
        self.value.write(new_value);
    }

    #[external(v0)]
    fn get_owner(self: @ContractState) -> ContractAddress {
        self.owner.read()
    }

    #[external(v0)]
    fn get_value(self: @ContractState) -> u128 {
        self.value.read()
    }

    #[external(v0)]
    fn get_name(self: @ContractState) -> felt252 {
        self.name.read()
    }
}
