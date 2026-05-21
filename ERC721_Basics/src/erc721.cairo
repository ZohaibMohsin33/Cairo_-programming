// ============================================================
// ERC721 Basics - Cairo Smart Contract
// Topic: Non-Fungible Token (NFT) Standard Implementation
// Compatible with: Scarb 2.6.4 / Cairo 2.6.x
// ============================================================

// ============================================================
// Interface Definition (must come before the contract module)
// ============================================================
use starknet::ContractAddress;

#[starknet::interface]
trait IERC721<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn token_uri(self: @TContractState, token_id: u256) -> felt252;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TContractState, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn mint(ref self: TContractState, recipient: ContractAddress, uri: felt252) -> u256;
    fn burn(ref self: TContractState, token_id: u256);
}

// ============================================================
// Contract Module
// ============================================================
#[starknet::contract]
mod ERC721Basics {

    // --------------------------------------------------------
    // Imports — LegacyMap is the correct map type for Cairo 2.6
    // --------------------------------------------------------
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::contract_address_const;

    // --------------------------------------------------------
    // Storage
    // --------------------------------------------------------
    #[storage]
    struct Storage {
        // Collection name e.g. 'MyNFT'
        name: felt252,
        // Ticker symbol e.g. 'MNFT'
        symbol: felt252,
        // Deployer address — has admin/mint rights
        owner: ContractAddress,
        // Counter for the next token ID to mint (starts at 1)
        next_token_id: u256,
        // token_id -> owner address
        token_owner: LegacyMap<u256, ContractAddress>,
        // owner address -> number of tokens held
        owner_balance: LegacyMap<ContractAddress, u256>,
        // token_id -> approved spender (single-token approval)
        token_approvals: LegacyMap<u256, ContractAddress>,
        // (owner, operator) -> bool for full operator approval
        operator_approvals: LegacyMap<(ContractAddress, ContractAddress), bool>,
        // token_id -> metadata URI string (e.g. IPFS link)
        token_uri_map: LegacyMap<u256, felt252>,
    }

    // --------------------------------------------------------
    // Events
    // --------------------------------------------------------
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
    }

    // Emitted on every ownership change (mint, transfer, burn)
    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key] from: ContractAddress,
        #[key] to: ContractAddress,
        #[key] token_id: u256,
    }

    // Emitted when a single token approval is set
    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key] owner: ContractAddress,
        #[key] approved: ContractAddress,
        #[key] token_id: u256,
    }

    // Emitted when operator approval is granted or revoked
    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        #[key] owner: ContractAddress,
        #[key] operator: ContractAddress,
        approved: bool,
    }

    // --------------------------------------------------------
    // Constructor — called once at deployment
    // --------------------------------------------------------
    #[constructor]
    fn constructor(ref self: ContractState, name: felt252, symbol: felt252) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.owner.write(get_caller_address());
        self.next_token_id.write(1_u256); // IDs start at 1; 0 = null/non-existent
    }

    // --------------------------------------------------------
    // Public ABI
    // --------------------------------------------------------
    #[abi(embed_v0)]
    impl ERC721Impl of super::IERC721<ContractState> {

        // Returns the human-readable name of the collection
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        // Returns the short ticker symbol
        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        // Returns the stored metadata URI for a token
        fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
            let token_owner = self.token_owner.read(token_id);
            assert(token_owner != contract_address_const::<0>(), 'ERC721: does not exist');
            self.token_uri_map.read(token_id)
        }

        // Returns how many tokens an address currently owns
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            assert(account != contract_address_const::<0>(), 'ERC721: zero address');
            self.owner_balance.read(account)
        }

        // Returns the owner address of a specific token
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let token_owner = self.token_owner.read(token_id);
            assert(token_owner != contract_address_const::<0>(), 'ERC721: does not exist');
            token_owner
        }

        // Returns the address approved for a single token
        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            let token_owner = self.token_owner.read(token_id);
            assert(token_owner != contract_address_const::<0>(), 'ERC721: does not exist');
            self.token_approvals.read(token_id)
        }

        // Returns true if operator can manage ALL tokens of owner
        fn is_approved_for_all(
            self: @ContractState,
            owner: ContractAddress,
            operator: ContractAddress,
        ) -> bool {
            self.operator_approvals.read((owner, operator))
        }

        // Approve one address to transfer one specific token
        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let token_owner = self.token_owner.read(token_id);
            assert(token_owner != contract_address_const::<0>(), 'ERC721: does not exist');
            let caller = get_caller_address();
            let is_operator = self.operator_approvals.read((token_owner, caller));
            assert(caller == token_owner || is_operator, 'ERC721: not authorized');
            assert(to != token_owner, 'ERC721: approve to owner');
            self.token_approvals.write(token_id, to);
            self.emit(Approval { owner: token_owner, approved: to, token_id });
        }

        // Grant or revoke an operator for ALL tokens of caller
        fn set_approval_for_all(
            ref self: ContractState,
            operator: ContractAddress,
            approved: bool,
        ) {
            let caller = get_caller_address();
            assert(operator != caller, 'ERC721: approve to self');
            self.operator_approvals.write((caller, operator), approved);
            self.emit(ApprovalForAll { owner: caller, operator, approved });
        }

        // Move a token from one address to another
        fn transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
        ) {
            let token_owner = self.token_owner.read(token_id);
            assert(token_owner != contract_address_const::<0>(), 'ERC721: does not exist');
            assert(token_owner == from, 'ERC721: wrong owner');
            assert(to != contract_address_const::<0>(), 'ERC721: transfer to zero');

            let caller = get_caller_address();
            let approved_addr = self.token_approvals.read(token_id);
            let is_operator = self.operator_approvals.read((from, caller));
            assert(
                caller == from || caller == approved_addr || is_operator,
                'ERC721: not authorized'
            );

            // Clear single-token approval on transfer
            self.token_approvals.write(token_id, contract_address_const::<0>());

            // Update balances
            let from_bal = self.owner_balance.read(from);
            self.owner_balance.write(from, from_bal - 1_u256);
            let to_bal = self.owner_balance.read(to);
            self.owner_balance.write(to, to_bal + 1_u256);

            // Transfer ownership
            self.token_owner.write(token_id, to);
            self.emit(Transfer { from, to, token_id });
        }

        // Create a new token — only contract deployer can call
        fn mint(ref self: ContractState, recipient: ContractAddress, uri: felt252) -> u256 {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'ERC721: caller not owner');
            assert(recipient != contract_address_const::<0>(), 'ERC721: mint to zero');

            let token_id = self.next_token_id.read();
            self.next_token_id.write(token_id + 1_u256);

            self.token_owner.write(token_id, recipient);
            let bal = self.owner_balance.read(recipient);
            self.owner_balance.write(recipient, bal + 1_u256);
            self.token_uri_map.write(token_id, uri);

            // Mint = Transfer from the zero address
            self.emit(Transfer {
                from: contract_address_const::<0>(),
                to: recipient,
                token_id,
            });
            token_id
        }

        // Permanently destroy a token — only the token owner can call
        fn burn(ref self: ContractState, token_id: u256) {
            let token_owner = self.token_owner.read(token_id);
            assert(token_owner != contract_address_const::<0>(), 'ERC721: does not exist');
            let caller = get_caller_address();
            assert(caller == token_owner, 'ERC721: not token owner');

            self.token_approvals.write(token_id, contract_address_const::<0>());

            let bal = self.owner_balance.read(token_owner);
            self.owner_balance.write(token_owner, bal - 1_u256);

            // Burn = set owner to zero
            self.token_owner.write(token_id, contract_address_const::<0>());

            // Burn = Transfer to the zero address
            self.emit(Transfer {
                from: token_owner,
                to: contract_address_const::<0>(),
                token_id,
            });
        }
    }
}
