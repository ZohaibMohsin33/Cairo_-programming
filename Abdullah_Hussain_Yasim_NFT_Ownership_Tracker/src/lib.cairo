#[starknet::contract]
mod NFTOwnershipTracker {
    use starknet::ContractAddress;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    // Event emitted whenever NFT ownership changes
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        NFTMinted: NFTMinted,
        NFTTransferred: NFTTransferred,
    }

    // NFT Mint Event
    #[derive(Drop, starknet::Event)]
    struct NFTMinted {
        token_id: u256,
        owner: ContractAddress,
    }

    // NFT Transfer Event
    #[derive(Drop, starknet::Event)]
    struct NFTTransferred {
        token_id: u256,
        old_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    // Storage section
    #[storage]
    struct Storage {
        // Stores NFT owner address
        nft_owner: Map<u256, ContractAddress>,
        // Stores whether NFT exists
        nft_exists: Map<u256, bool>,
    }

    // Mint a new NFT
    #[external(v0)]
    fn mint(ref self: ContractState, token_id: u256, owner: ContractAddress) {
        // Prevent duplicate minting
        let exists = self.nft_exists.read(token_id);

        assert(!exists, 'NFT already exists');

        // Store owner
        self.nft_owner.write(token_id, owner);

        // Mark NFT as existing
        self.nft_exists.write(token_id, true);

        // Emit mint event
        self.emit(Event::NFTMinted(NFTMinted { token_id, owner }));
    }

    // Transfer NFT ownership
    #[external(v0)]
    fn transfer(ref self: ContractState, token_id: u256, new_owner: ContractAddress) {
        // Check NFT exists
        let exists = self.nft_exists.read(token_id);

        assert(exists, 'NFT does not exist');

        // Get current owner
        let old_owner = self.nft_owner.read(token_id);

        // Update owner
        self.nft_owner.write(token_id, new_owner);

        // Emit transfer event
        self.emit(Event::NFTTransferred(NFTTransferred { token_id, old_owner, new_owner }));
    }

    // Get current owner
    #[external(v0)]
    fn get_owner(self: @ContractState, token_id: u256) -> ContractAddress {
        self.nft_owner.read(token_id)
    }

    // Check if NFT exists
    #[external(v0)]
    fn nft_exists(self: @ContractState, token_id: u256) -> bool {
        self.nft_exists.read(token_id)
    }
}


#[cfg(test)]
mod tests {
    #[test]
    fn test_basic_math() {
        assert(1 == 1, 'Test failed');
    }
}
