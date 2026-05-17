// =============================================================================
// Mapping-like storage — Starknet contract (Cairo)
// Author: Muhammad Abdullah Waheed
// Key/value persistence via `Map` in contract storage.
// =============================================================================

use starknet::ContractAddress;

/// Public API of the contract. Embedding this trait exposes these functions on-chain.
#[starknet::interface]
trait IMappingLikeStorage<TContractState> {
    /// Read the admin address set at deployment.
    fn get_admin(self: @TContractState) -> ContractAddress;
    /// Each user may set a `u256` value stored under their own address key.
    fn set_my_value(ref self: TContractState, value: u256);
    /// Read the stored value for any address (unset keys read as 0).
    fn get_value_for(self: @TContractState, account: ContractAddress) -> u256;
    /// Admin-only: write a value for any address (shows privileged updates to a map).
    fn admin_set_value_for(ref self: TContractState, account: ContractAddress, value: u256);
    /// Admin-only: write to a catalog keyed by an explicit `u256` id.
    fn admin_set_catalog_entry(ref self: TContractState, item_id: u256, data: u256);
    /// Anyone may read catalog entries (common “public registry” pattern).
    fn get_catalog_entry(self: @TContractState, item_id: u256) -> u256;
}

#[starknet::contract]
mod MappingLikeStorage {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };

    // -------------------------------------------------------------------------
    // Storage layout: one plain slot + two `Map`s (mapping-like structures).
    // - `values_by_account` is the classic “mapping(address => uint256)” pattern.
    // - `catalog` is “mapping(uint256 => uint256)” for arbitrary numeric IDs.
    // -------------------------------------------------------------------------
    #[storage]
    struct Storage {
        admin: ContractAddress,
        values_by_account: Map<ContractAddress, u256>,
        catalog: Map<u256, u256>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        self.admin.write(admin);
    }

    /// Internal guard: only the configured admin may call admin functions.
    fn assert_only_admin(self: @ContractState) {
        let caller = get_caller_address();
        assert(caller == self.admin.read(), 'Caller is not admin');
    }

    #[abi(embed_v0)]
    impl MappingLikeStorageImpl of super::IMappingLikeStorage<ContractState> {
        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }

        /// Stores `value` at the key `get_caller_address()` inside `values_by_account`.
        fn set_my_value(ref self: ContractState, value: u256) {
            let user = get_caller_address();
            self.values_by_account.write(user, value);
        }

        /// Reads the map without mutation (`@ContractState` = read-only self).
        fn get_value_for(self: @ContractState, account: ContractAddress) -> u256 {
            self.values_by_account.read(account)
        }

        fn admin_set_value_for(ref self: ContractState, account: ContractAddress, value: u256) {
            assert_only_admin(@self);
            self.values_by_account.write(account, value);
        }

        fn admin_set_catalog_entry(ref self: ContractState, item_id: u256, data: u256) {
            assert_only_admin(@self);
            self.catalog.write(item_id, data);
        }

        fn get_catalog_entry(self: @ContractState, item_id: u256) -> u256 {
            self.catalog.read(item_id)
        }
    }
}
