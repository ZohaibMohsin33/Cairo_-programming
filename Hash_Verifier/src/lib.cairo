use core::poseidon::poseidon_hash_span;
use starknet::ContractAddress;

pub fn hash_age(age: u64) -> felt252 {
    let age_felt: felt252 = age.into();
    poseidon_hash_span(array![age_felt].span())
}

pub fn verify_age_constraint(age: u64) -> bool {
    age >= 18
}

pub fn verify_hash_with_constraint(stored_hash: felt252, age: u64) -> bool {
    if stored_hash == 0 {
        return false;
    }

    let recomputed = hash_age(age);
    if recomputed != stored_hash {
        return false;
    }

    if !verify_age_constraint(age) {
        return false;
    }

    true
}

#[starknet::interface]
pub trait IHashVerifier<TContractState> {
    fn store_hash(ref self: TContractState, user: ContractAddress, age: u64);
    fn verify_hash(ref self: TContractState, age: u64) -> bool;
    fn verify_hash_for(self: @TContractState, user: ContractAddress, age: u64) -> bool;
    fn get_hash(self: @TContractState, user: ContractAddress) -> felt252;
    fn get_admin(self: @TContractState) -> ContractAddress;
    fn transfer_admin(ref self: TContractState, new_admin: ContractAddress);
}

#[starknet::contract]
mod HashVerifier {
    use super::{hash_age, verify_hash_with_constraint};
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        admin: ContractAddress,
        hashes: Map<ContractAddress, felt252>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        self.admin.write(admin);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        HashStored: HashStored,
        HashVerified: HashVerified,
        AdminTransferred: AdminTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct HashStored {
        #[key]
        user: ContractAddress,
        hash: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct HashVerified {
        #[key]
        user: ContractAddress,
        success: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct AdminTransferred {
        #[key]
        old_admin: ContractAddress,
        #[key]
        new_admin: ContractAddress,
    }

    #[abi(embed_v0)]
    impl HashVerifierImpl of super::IHashVerifier<ContractState> {
        fn store_hash(ref self: ContractState, user: ContractAddress, age: u64) {
            self._assert_admin();

            let hash = hash_age(age);
            assert!(hash != 0, "INVALID_HASH");

            self.hashes.write(user, hash);
            self.emit(HashStored { user, hash });
        }

        fn verify_hash(ref self: ContractState, age: u64) -> bool {
            let caller = get_caller_address();
            let stored_hash = self.hashes.read(caller);

            let success = verify_hash_with_constraint(stored_hash, age);
            self.emit(HashVerified { user: caller, success });

            success
        }

        fn verify_hash_for(self: @ContractState, user: ContractAddress, age: u64) -> bool {
            let stored_hash = self.hashes.read(user);
            verify_hash_with_constraint(stored_hash, age)
        }

        fn get_hash(self: @ContractState, user: ContractAddress) -> felt252 {
            self.hashes.read(user)
        }

        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }

        fn transfer_admin(ref self: ContractState, new_admin: ContractAddress) {
            self._assert_admin();

            let old_admin = self.admin.read();
            assert!(old_admin != new_admin, "SAME_ADMIN");

            self.admin.write(new_admin);
            self.emit(AdminTransferred { old_admin, new_admin });
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _assert_admin(self: @ContractState) {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert!(caller == admin, "ONLY_ADMIN");
        }
    }
}

#[cfg(test)]
mod tests;
