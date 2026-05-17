use starknet::storage::StoragePointerReadAccess;
use starknet::storage::StoragePointerWriteAccess;

#[starknet::interface]
trait ICounter<TContractState> {
    fn get_count(self: @TContractState) -> u32;
    fn increment(ref self: TContractState);
    fn decrement(ref self: TContractState);
    fn reset(ref self: TContractState);
    fn set_count(ref self: TContractState, value: u32);
    fn get_increment_count(self: @TContractState) -> u32;
    fn get_decrement_count(self: @TContractState) -> u32;
}

#[starknet::contract]
mod Counter {
    use starknet::storage::StoragePointerReadAccess;
    use starknet::storage::StoragePointerWriteAccess;

    #[storage]
    struct Storage {
        count: u32,
        total_increments: u32,
        total_decrements: u32,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncremented: CounterIncremented,
        CounterDecremented: CounterDecremented,
        CounterReset: CounterReset,
        CounterSet: CounterSet,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterIncremented {
        #[key]
        new_value: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterDecremented {
        #[key]
        new_value: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterReset {}

    #[derive(Drop, starknet::Event)]
    struct CounterSet {
        #[key]
        new_value: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u32) {
        self.count.write(initial_value);
        self.total_increments.write(0);
        self.total_decrements.write(0);
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {

        fn get_count(self: @ContractState) -> u32 {
            self.count.read()
        }

        fn increment(ref self: ContractState) {
            let current = self.count.read();
            let new_value = current + 1;
            self.count.write(new_value);
            let increments = self.total_increments.read();
            self.total_increments.write(increments + 1);
            self.emit(Event::CounterIncremented(CounterIncremented { new_value }));
        }

        fn decrement(ref self: ContractState) {
            let current = self.count.read();
            if current > 0 {
                let new_value = current - 1;
                self.count.write(new_value);
                let decrements = self.total_decrements.read();
                self.total_decrements.write(decrements + 1);
                self.emit(Event::CounterDecremented(CounterDecremented { new_value }));
            }
        }

        fn reset(ref self: ContractState) {
            self.count.write(0);
            self.emit(Event::CounterReset(CounterReset {}));
        }

        fn set_count(ref self: ContractState, value: u32) {
            self.count.write(value);
            self.emit(Event::CounterSet(CounterSet { new_value: value }));
        }

        fn get_increment_count(self: @ContractState) -> u32 {
            self.total_increments.read()
        }

        fn get_decrement_count(self: @ContractState) -> u32 {
            self.total_decrements.read()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{Counter, ICounterDispatcher, ICounterDispatcherTrait};
    use starknet::syscalls::deploy_syscall;
    use starknet::SyscallResultTrait;
    use core::traits::Into;

    fn deploy_counter(initial_value: u32) -> ICounterDispatcher {
        let mut calldata = array![initial_value.into()];
        let (contract_address, _) = deploy_syscall(
            Counter::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            calldata.span(),
            false
        ).unwrap_syscall();
        ICounterDispatcher { contract_address }
    }

    #[test]
    fn test_initial_value_zero() {
        let counter = deploy_counter(0);
        assert(counter.get_count() == 0, 'Initial value should be 0');
    }

    #[test]
    fn test_custom_initial_value() {
        let counter = deploy_counter(10);
        assert(counter.get_count() == 10, 'Initial value should be 10');
    }

    #[test]
    fn test_increment() {
        let counter = deploy_counter(0);
        counter.increment();
        assert(counter.get_count() == 1, 'Should be 1 after increment');
        counter.increment();
        assert(counter.get_count() == 2, 'Should be 2 after increment');
        counter.increment();
        assert(counter.get_count() == 3, 'Should be 3 after increment');
    }

    #[test]
    fn test_decrement() {
        let counter = deploy_counter(5);
        counter.decrement();
        assert(counter.get_count() == 4, 'Should be 4 after decrement');
        counter.decrement();
        assert(counter.get_count() == 3, 'Should be 3 after decrement');
    }

    #[test]
    fn test_decrement_stops_at_zero() {
        let counter = deploy_counter(0);
        counter.decrement();
        assert(counter.get_count() == 0, 'Should stay at 0, not go below');
    }

    #[test]
    fn test_reset() {
        let counter = deploy_counter(0);
        counter.increment();
        counter.increment();
        counter.increment();
        assert(counter.get_count() == 3, 'Should be 3 before reset');
        counter.reset();
        assert(counter.get_count() == 0, 'Should be 0 after reset');
    }

    #[test]
    fn test_set_count() {
        let counter = deploy_counter(0);
        counter.set_count(42);
        assert(counter.get_count() == 42, 'Should be 42 after set');
        counter.set_count(100);
        assert(counter.get_count() == 100, 'Should be 100 after set');
    }

    #[test]
    fn test_increment_tracker() {
        let counter = deploy_counter(0);
        counter.increment();
        counter.increment();
        counter.increment();
        assert(counter.get_increment_count() == 3, 'Increment count should be 3');
    }

    #[test]
    fn test_decrement_tracker() {
        let counter = deploy_counter(5);
        counter.decrement();
        counter.decrement();
        assert(counter.get_decrement_count() == 2, 'Decrement count should be 2');
    }

    #[test]
    fn test_full_workflow() {
        let counter = deploy_counter(0);
        counter.increment();
        counter.increment();
        counter.increment();
        counter.decrement();
        counter.increment();
        counter.set_count(10);
        counter.decrement();
        counter.reset();
        assert(counter.get_count() == 0, 'Final value should be 0');
        assert(counter.get_increment_count() == 4, 'Total increments should be 4');
        assert(counter.get_decrement_count() == 2, 'Total decrements should be 2');
    }
}