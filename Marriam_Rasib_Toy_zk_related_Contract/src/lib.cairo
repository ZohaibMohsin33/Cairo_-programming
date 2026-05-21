// Toy ZK-related Contract in Cairo
// User commits a secret number, later proves they know it without revealing it

use starknet::storage::StorageMapWriteAccess;
use starknet::storage::StorageMapReadAccess;

#[starknet::interface]
trait IToyZK<TContractState> {
    fn commit_secret(ref self: TContractState, secret: felt252);
    fn verify_secret(ref self: TContractState, secret: felt252) -> bool;
}

#[starknet::contract]
mod ToyZKContract {
    use starknet::get_caller_address;
    use core::poseidon::poseidon_hash_span;
    use super::StorageMapWriteAccess;
    use super::StorageMapReadAccess;

    #[storage]
    struct Storage {
        commitments: starknet::storage::Map::<starknet::ContractAddress, felt252>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        SecretCommitted: SecretCommitted,
        ProofVerified: ProofVerified,
    }

    #[derive(Drop, starknet::Event)]
    struct SecretCommitted {
        user: starknet::ContractAddress,
        hash: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct ProofVerified {
        user: starknet::ContractAddress,
        success: bool,
    }

    #[abi(embed_v0)]
    impl ToyZKImpl of super::IToyZK<ContractState> {
        // Step 1: User commits their secret (stores hash)
        fn commit_secret(ref self: ContractState, secret: felt252) {
            let caller = get_caller_address();
            let hash = poseidon_hash_span(array![secret].span());
            self.commitments.write(caller, hash);
            self.emit(SecretCommitted { user: caller, hash });
        }

        // Step 2: User proves they know the secret
        fn verify_secret(ref self: ContractState, secret: felt252) -> bool {
            let caller = get_caller_address();
            let stored_hash = self.commitments.read(caller);
            let provided_hash = poseidon_hash_span(array![secret].span());
            let success = stored_hash == provided_hash;
            self.emit(ProofVerified { user: caller, success });
            success
        }
    }
}