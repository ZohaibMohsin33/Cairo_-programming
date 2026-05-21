use starknet::ContractAddress;

#[starknet::interface]
pub trait IStorageVariablesExample<TContractState> {
    fn set_counter(ref self: TContractState, new_value: u32);
    fn update_balance(ref self: TContractState, user: ContractAddress, amount: u256);
    fn get_counter(self: @TContractState) -> u32;
    fn get_balance(self: @TContractState, user: ContractAddress) -> u256;
}

#[starknet::contract]
pub mod StorageVariablesExample {
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        counter: u32,
        balances: LegacyMap::<ContractAddress, u256>,
    }

    #[abi(embed_v0)]
    impl StorageVariablesExampleImpl of super::IStorageVariablesExample<ContractState> {
        
        fn set_counter(ref self: ContractState, new_value: u32) {
            self.counter.write(new_value);
        }

        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn update_balance(
            ref self: ContractState,
            user: ContractAddress,
            amount: u256
        ) {
            self.balances.write(user, amount);
        }

        fn get_balance(
            self: @ContractState,
            user: ContractAddress
        ) -> u256 {
            self.balances.read(user)
        }
    }
}