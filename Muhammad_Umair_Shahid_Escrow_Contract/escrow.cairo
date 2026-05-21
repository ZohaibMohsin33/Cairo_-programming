// Escrow Contract in Cairo (StarkNet)
//
// An escrow holds funds between a buyer and seller.
// A trusted arbiter approves or cancels the release of funds.
//
// Flow:
//   1. Buyer deposits funds into the contract
//   2. Seller delivers goods/service off-chain
//   3. Arbiter calls approve_release() → seller receives funds
//   4. If dispute, arbiter calls cancel() → buyer gets refund

use starknet::ContractAddress;

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

#[starknet::interface]
trait IEscrow<TContractState> {
    // Deposit funds into escrow (called by buyer)
    fn deposit(ref self: TContractState, amount: u256);

    // Arbiter approves release: transfers funds to seller
    fn approve_release(ref self: TContractState);

    // Arbiter cancels escrow: refunds buyer
    fn cancel(ref self: TContractState);

    // Read-only getters
    fn get_buyer(self: @TContractState) -> ContractAddress;
    fn get_seller(self: @TContractState) -> ContractAddress;
    fn get_arbiter(self: @TContractState) -> ContractAddress;
    fn get_balance(self: @TContractState) -> u256;
    fn is_completed(self: @TContractState) -> bool;
}

// ---------------------------------------------------------------------------
// Contract
// ---------------------------------------------------------------------------

#[starknet::contract]
mod Escrow {
    use super::ContractAddress;
    use starknet::get_caller_address;

    // -----------------------------------------------------------------------
    // Storage — all persistent state lives here
    // -----------------------------------------------------------------------
    #[storage]
    struct Storage {
        buyer: ContractAddress,      // The party sending funds
        seller: ContractAddress,     // The party receiving funds on approval
        arbiter: ContractAddress,    // Neutral third party who resolves disputes
        balance: u256,               // Amount currently held in escrow
        completed: bool,             // True once the escrow is settled
    }

    // -----------------------------------------------------------------------
    // Events — emitted so off-chain indexers can track activity
    // -----------------------------------------------------------------------
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Deposited: Deposited,
        Released: Released,
        Cancelled: Cancelled,
    }

    // Buyer deposited funds
    #[derive(Drop, starknet::Event)]
    struct Deposited {
        #[key]
        buyer: ContractAddress,
        amount: u256,
    }

    // Arbiter approved — seller got paid
    #[derive(Drop, starknet::Event)]
    struct Released {
        #[key]
        seller: ContractAddress,
        amount: u256,
    }

    // Arbiter cancelled — buyer refunded
    #[derive(Drop, starknet::Event)]
    struct Cancelled {
        #[key]
        buyer: ContractAddress,
        amount: u256,
    }

    // -----------------------------------------------------------------------
    // Constructor — sets the three parties when contract is deployed
    // -----------------------------------------------------------------------
    #[constructor]
    fn constructor(
        ref self: ContractState,
        buyer: ContractAddress,
        seller: ContractAddress,
        arbiter: ContractAddress,
    ) {
        // All three addresses must be distinct to avoid conflicts
        assert(buyer != seller, 'Buyer and seller must differ');
        assert(buyer != arbiter, 'Buyer and arbiter must differ');
        assert(seller != arbiter, 'Seller and arbiter must differ');

        self.buyer.write(buyer);
        self.seller.write(seller);
        self.arbiter.write(arbiter);
        self.balance.write(0_u256);
        self.completed.write(false);
    }

    // -----------------------------------------------------------------------
    // Implementation
    // -----------------------------------------------------------------------
    #[abi(embed_v0)]
    impl EscrowImpl of super::IEscrow<ContractState> {

        // Buyer deposits an amount into the escrow
        fn deposit(ref self: ContractState, amount: u256) {
            // Only the buyer may deposit
            let caller = get_caller_address();
            assert(caller == self.buyer.read(), 'Only buyer can deposit');

            // Escrow must not already be settled
            assert(!self.completed.read(), 'Escrow already completed');

            // Must deposit a positive amount
            assert(amount > 0_u256, 'Amount must be positive');

            // Add amount to the held balance
            let current = self.balance.read();
            self.balance.write(current + amount);

            // Emit event for off-chain indexers
            self.emit(Deposited { buyer: caller, amount });
        }

        // Arbiter approves: releases funds to the seller
        fn approve_release(ref self: ContractState) {
            let caller = get_caller_address();
            // Only the arbiter can approve a release
            assert(caller == self.arbiter.read(), 'Only arbiter can release');

            // There must be funds to release
            let amount = self.balance.read();
            assert(amount > 0_u256, 'No funds in escrow');

            // Escrow must still be active
            assert(!self.completed.read(), 'Escrow already completed');

            // Mark as complete and zero out the balance
            self.completed.write(true);
            self.balance.write(0_u256);

            // NOTE: On a real StarkNet contract you would call an ERC-20
            // transfer here to send `amount` tokens to self.seller.read().
            // This is omitted to keep the example focused on escrow logic.

            self.emit(Released { seller: self.seller.read(), amount });
        }

        // Arbiter cancels: refunds the buyer
        fn cancel(ref self: ContractState) {
            let caller = get_caller_address();
            // Only the arbiter can cancel
            assert(caller == self.arbiter.read(), 'Only arbiter can cancel');

            let amount = self.balance.read();
            assert(amount > 0_u256, 'No funds in escrow');
            assert(!self.completed.read(), 'Escrow already completed');

            // Mark as complete and zero out the balance
            self.completed.write(true);
            self.balance.write(0_u256);

            // NOTE: Similarly, a real implementation would transfer `amount`
            // tokens back to self.buyer.read() via an ERC-20 call.

            self.emit(Cancelled { buyer: self.buyer.read(), amount });
        }

        // ---- Getters -------------------------------------------------------

        fn get_buyer(self: @ContractState) -> ContractAddress {
            self.buyer.read()
        }

        fn get_seller(self: @ContractState) -> ContractAddress {
            self.seller.read()
        }

        fn get_arbiter(self: @ContractState) -> ContractAddress {
            self.arbiter.read()
        }

        fn get_balance(self: @ContractState) -> u256 {
            self.balance.read()
        }

        fn is_completed(self: @ContractState) -> bool {
            self.completed.read()
        }
    }
}
