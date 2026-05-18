#[starknet::interface]
pub trait ICounter<TContractState> {
    fn increment(ref self: TContractState);
    fn decrement(ref self: TContractState);
    fn get_count(self: @TContractState) -> u32;
}

#[starknet::contract]
pub mod Counter {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        count: u32,
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn increment(ref self: ContractState) {
            let current = self.count.read();
            self.count.write(current + 1);
        }

        fn decrement(ref self: ContractState) {
            let current = self.count.read();
            self.count.write(current - 1);
        }

        fn get_count(self: @ContractState) -> u32 {
            self.count.read()
        }
    }
}
