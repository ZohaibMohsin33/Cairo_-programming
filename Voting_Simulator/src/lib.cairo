#[starknet::interface]
trait IVotingSimulator<TContractState> {
    fn register_voter(ref self: TContractState, voter_address: starknet::ContractAddress);
    fn add_candidate(ref self: TContractState, candidate_name: felt252);
    fn vote(ref self: TContractState, candidate_id: u64);
    fn get_candidate_votes(self: @TContractState, candidate_id: u64) -> u64;
    fn get_candidate_name(self: @TContractState, candidate_id: u64) -> felt252;
    fn get_total_candidates(self: @TContractState) -> u64;
    fn has_voted(self: @TContractState, voter: starknet::ContractAddress) -> bool;
} 

#[starknet::contract]
mod VotingSimulator {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        admin: ContractAddress,
        candidates_count: u64,
        candidate_votes: LegacyMap::<u64, u64>,
        candidate_names: LegacyMap::<u64, felt252>,
        registered_voters: LegacyMap::<ContractAddress, bool>,
        has_voted_map: LegacyMap::<ContractAddress, bool>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let deployer = get_caller_address();
        self.admin.write(deployer);
        self.candidates_count.write(0);
    }

    #[abi(embed_v0)]
    impl VotingSimulatorImpl of super::IVotingSimulator<ContractState> {
        fn register_voter(ref self: ContractState, voter_address: ContractAddress) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), 'ONLY_ADMIN_CAN_REGISTER');
            self.registered_voters.write(voter_address, true);
        }

        fn add_candidate(ref self: ContractState, candidate_name: felt252) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), 'ONLY_ADMIN_CAN_ADD');
            let new_id = self.candidates_count.read() + 1;
            self.candidate_names.write(new_id, candidate_name);
            self.candidate_votes.write(new_id, 0);
            self.candidates_count.write(new_id);
        }

        fn vote(ref self: ContractState, candidate_id: u64) {
            let caller = get_caller_address();
            assert(self.registered_voters.read(caller) == true, 'NOT_A_REGISTERED_VOTER');
            assert(!self.has_voted_map.read(caller), 'ALREADY_VOTED');
            assert(candidate_id <= self.candidates_count.read() && candidate_id > 0, 'INVALID_CANDIDATE_ID');

            self.has_voted_map.write(caller, true);
            let current_votes = self.candidate_votes.read(candidate_id);
            self.candidate_votes.write(candidate_id, current_votes + 1);
        }

        fn get_candidate_votes(self: @ContractState, candidate_id: u64) -> u64 {
            assert(candidate_id <= self.candidates_count.read() && candidate_id > 0, 'INVALID_CANDIDATE_ID');
            self.candidate_votes.read(candidate_id)
        }

        fn get_candidate_name(self: @ContractState, candidate_id: u64) -> felt252 {
            assert(candidate_id <= self.candidates_count.read() && candidate_id > 0, 'INVALID_CANDIDATE_ID');
            self.candidate_names.read(candidate_id)
        }

        fn get_total_candidates(self: @ContractState) -> u64 {
            self.candidates_count.read()
        }

        fn has_voted(self: @ContractState, voter: ContractAddress) -> bool {
            self.has_voted_map.read(voter)
        }
    }
}