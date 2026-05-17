// Toy NFT Metadata Handler Smart Contract
// Built in Cairo 2.x to handle metadata properties for unique Toy NFTs
// Author: Hassan Uozair

use starknet::ContractAddress;

#[starknet::interface]
trait IToyNFTMetadataHandler<TContractState> {
    fn mint_toy_nft(
        ref self: TContractState,
        to: ContractAddress,
        name: ByteArray,
        description: ByteArray,
        image_uri: ByteArray,
        rarity: ByteArray,
        power_level: u32
    );
    fn update_metadata(
        ref self: TContractState,
        token_id: u256,
        name: ByteArray,
        description: ByteArray,
        image_uri: ByteArray,
        rarity: ByteArray,
        power_level: u32
    );
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::contract]
mod ToyNFTMetadataHandler {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{
        Map,
        StorageMapReadAccess,
        StorageMapWriteAccess,
        StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };

    #[storage]
    struct Storage {
        names: Map<u256, ByteArray>,
        descriptions: Map<u256, ByteArray>,
        image_uris: Map<u256, ByteArray>,
        rarities: Map<u256, ByteArray>,
        power_levels: Map<u256, u32>,
        owners: Map<u256, ContractAddress>,
        owner: ContractAddress,
        total_minted: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ToyNFTMinted: ToyNFTMinted,
        MetadataUpdated: MetadataUpdated,
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct ToyNFTMinted {
        #[key]
        token_id: u256,
        #[key]
        owner: ContractAddress,
        name: ByteArray,
        rarity: ByteArray,
        power_level: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct MetadataUpdated {
        #[key]
        token_id: u256,
        name: ByteArray,
        rarity: ByteArray,
        power_level: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        previous_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
        self.total_minted.write(0_u256);
    }

    #[abi(embed_v0)]
    impl ToyNFTMetadataHandlerImpl of super::IToyNFTMetadataHandler<ContractState> {
        fn mint_toy_nft(
            ref self: ContractState,
            to: ContractAddress,
            name: ByteArray,
            description: ByteArray,
            image_uri: ByteArray,
            rarity: ByteArray,
            power_level: u32
        ) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner can mint');

            let token_id = self.total_minted.read() + 1_u256;
            self.total_minted.write(token_id);

            self.names.write(token_id, name.clone());
            self.descriptions.write(token_id, description);
            self.image_uris.write(token_id, image_uri);
            self.rarities.write(token_id, rarity.clone());
            self.power_levels.write(token_id, power_level);
            self.owners.write(token_id, to);

            self.emit(Event::ToyNFTMinted(ToyNFTMinted {
                token_id,
                owner: to,
                name,
                rarity,
                power_level,
            }));
        }

        fn update_metadata(
            ref self: ContractState,
            token_id: u256,
            name: ByteArray,
            description: ByteArray,
            image_uri: ByteArray,
            rarity: ByteArray,
            power_level: u32
        ) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner can update');

            assert(token_id <= self.total_minted.read(), 'Token does not exist');
            assert(token_id > 0_u256, 'Invalid token ID');

            self.names.write(token_id, name.clone());
            self.descriptions.write(token_id, description);
            self.image_uris.write(token_id, image_uri);
            self.rarities.write(token_id, rarity.clone());
            self.power_levels.write(token_id, power_level);

            self.emit(Event::MetadataUpdated(MetadataUpdated {
                token_id,
                name,
                rarity,
                power_level,
            }));
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let caller = get_caller_address();
            let current_owner = self.owner.read();
            assert(caller == current_owner, 'Only owner can transfer');
            assert(new_owner != starknet::contract_address_const::<0>(), 'Invalid new owner');

            self.owner.write(new_owner);
            self.emit(Event::OwnershipTransferred(OwnershipTransferred {
                previous_owner: current_owner,
                new_owner,
            }));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::ToyNFTMetadataHandler;
    use super::IToyNFTMetadataHandler;
    use starknet::ContractAddress;
    use starknet::contract_address_const;

    #[test]
    fn test_mint_toy_nft() {
        let owner = contract_address_const::<123>();
        let mut state = ToyNFTMetadataHandler::contract_state_for_testing();
        ToyNFTMetadataHandler::constructor(ref state, owner);

        starknet::testing::set_caller_address(owner);

        let to = contract_address_const::<456>();
        let name: ByteArray = "Super Toy";
        let description: ByteArray = "A super powerful toy";
        let image_uri: ByteArray = "https://ipfs.io/super_toy";
        let rarity: ByteArray = "Legendary";
        let power_level = 9000_u32;

        ToyNFTMetadataHandler::ToyNFTMetadataHandlerImpl::mint_toy_nft(
            ref state,
            to,
            name,
            description,
            image_uri,
            rarity,
            power_level
        );

        let total = state.total_minted.read();
        assert(total == 1_u256, 'Expected total minted 1');

        let minted_name = state.names.read(1_u256);
        assert(minted_name == "Super Toy", 'Expected name Super Toy');

        let minted_owner = state.owners.read(1_u256);
        assert(minted_owner == to, 'Expected correct owner');
    }
}

