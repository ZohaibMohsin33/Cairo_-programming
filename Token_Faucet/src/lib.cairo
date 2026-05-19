use starknet::ContractAddress;

// ------------------------------------------------------------
// Interface of the Token Faucet contract
// These functions can be called from outside the contract.
// ------------------------------------------------------------
#[starknet::interface]
pub trait ITokenFaucet<TContractState> {
    // Main faucet function
    fn claim_tokens(ref self: TContractState);

    // Owner-only management functions
    fn refill_faucet(ref self: TContractState, amount: u128);
    fn update_claim_amount(ref self: TContractState, new_claim_amount: u128);
    fn update_cooldown(ref self: TContractState, new_cooldown_seconds: u64);

    // Read-only getter functions
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn get_faucet_balance(self: @TContractState) -> u128;
    fn get_claim_amount(self: @TContractState) -> u128;
    fn get_cooldown_seconds(self: @TContractState) -> u64;
    fn get_total_distributed(self: @TContractState) -> u128;
    fn get_user_balance(self: @TContractState, user: ContractAddress) -> u128;
    fn get_last_claim_time(self: @TContractState, user: ContractAddress) -> u64;
    fn has_user_claimed(self: @TContractState, user: ContractAddress) -> bool;
}


// ------------------------------------------------------------
// Token Faucet Smart Contract
// ------------------------------------------------------------
#[starknet::contract]
pub mod TokenFaucet {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

    use starknet::storage::{
        Map,
        StoragePathEntry,
        StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };

    // --------------------------------------------------------
    // Contract Storage
    // --------------------------------------------------------
    #[storage]
    struct Storage {
        // Address that controls the faucet settings
        owner: ContractAddress,

        // Total tokens currently available in the faucet
        faucet_balance: u128,

        // Fixed amount a user receives per successful claim
        claim_amount: u128,

        // Minimum waiting time between two claims by the same user
        cooldown_seconds: u64,

        // Total number of faucet tokens distributed so far
        total_distributed: u128,

        // Internal token balance received by each user from the faucet
        user_balances: Map<ContractAddress, u128>,

        // Last timestamp at which each user claimed tokens
        last_claim_time: Map<ContractAddress, u64>,

        // Tracks whether a user has claimed at least once
        has_claimed_before: Map<ContractAddress, bool>,
    }


    // --------------------------------------------------------
    // Events
    // Events help external tools track important actions.
    // --------------------------------------------------------
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        TokensClaimed: TokensClaimed,
        FaucetRefilled: FaucetRefilled,
        ClaimAmountUpdated: ClaimAmountUpdated,
        CooldownUpdated: CooldownUpdated,
    }

    // Emitted when a user successfully claims faucet tokens
    #[derive(Drop, starknet::Event)]
    pub struct TokensClaimed {
        #[key]
        pub claimant: ContractAddress,
        pub amount: u128,
        pub claim_time: u64,
    }

    // Emitted when the owner adds more tokens to the faucet
    #[derive(Drop, starknet::Event)]
    pub struct FaucetRefilled {
        #[key]
        pub owner: ContractAddress,
        pub amount: u128,
        pub new_balance: u128,
    }

    // Emitted when the claim amount is changed
    #[derive(Drop, starknet::Event)]
    pub struct ClaimAmountUpdated {
        #[key]
        pub owner: ContractAddress,
        pub old_amount: u128,
        pub new_amount: u128,
    }

    // Emitted when the cooldown period is changed
    #[derive(Drop, starknet::Event)]
    pub struct CooldownUpdated {
        #[key]
        pub owner: ContractAddress,
        pub old_cooldown: u64,
        pub new_cooldown: u64,
    }


    // --------------------------------------------------------
    // Constructor
    // Runs once when the contract is deployed.
    // --------------------------------------------------------
    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner_address: ContractAddress,
        initial_faucet_balance: u128,
        initial_claim_amount: u128,
        initial_cooldown_seconds: u64,
    ) {
        // A faucet should never distribute zero tokens per claim.
        assert!(
            initial_claim_amount > 0,
            "Claim amount must be greater than zero"
        );

        self.owner.write(owner_address);
        self.faucet_balance.write(initial_faucet_balance);
        self.claim_amount.write(initial_claim_amount);
        self.cooldown_seconds.write(initial_cooldown_seconds);
        self.total_distributed.write(0);
    }


    // --------------------------------------------------------
    // Public Contract Functions
    // --------------------------------------------------------
    #[abi(embed_v0)]
    impl TokenFaucetImpl of super::ITokenFaucet<ContractState> {

        // ----------------------------------------------------
        // claim_tokens
        // Allows a user to receive faucet tokens.
        // Conditions:
        // 1. Faucet must have enough tokens.
        // 2. User must wait for cooldown after a previous claim.
        // ----------------------------------------------------
        fn claim_tokens(ref self: ContractState) {
            let caller = get_caller_address();
            let current_time = get_block_timestamp();

            let amount_to_claim = self.claim_amount.read();
            let available_faucet_balance = self.faucet_balance.read();

            // The faucet must have enough tokens available.
            assert!(
                available_faucet_balance >= amount_to_claim,
                "Faucet does not have enough tokens"
            );

            // Check whether the caller has claimed before.
            let claimed_before = self.has_claimed_before.entry(caller).read();

            // If the user claimed before, enforce cooldown.
            if claimed_before {
                let previous_claim_time = self.last_claim_time.entry(caller).read();
                let cooldown = self.cooldown_seconds.read();

                assert!(
                    current_time >= previous_claim_time + cooldown,
                    "Cooldown period is still active"
                );
            }

            // Read old user balance and increase it by claim amount.
            let previous_user_balance = self.user_balances.entry(caller).read();
            let updated_user_balance = previous_user_balance + amount_to_claim;

            self.user_balances.entry(caller).write(updated_user_balance);

            // Reduce faucet balance.
            let updated_faucet_balance = available_faucet_balance - amount_to_claim;
            self.faucet_balance.write(updated_faucet_balance);

            // Update user's claim history.
            self.last_claim_time.entry(caller).write(current_time);
            self.has_claimed_before.entry(caller).write(true);

            // Update total distributed tokens.
            let previous_total_distributed = self.total_distributed.read();
            let updated_total_distributed = previous_total_distributed + amount_to_claim;
            self.total_distributed.write(updated_total_distributed);

            // Emit event for tracking claims.
            self.emit(TokensClaimed {
                claimant: caller,
                amount: amount_to_claim,
                claim_time: current_time,
            });
        }


        // ----------------------------------------------------
        // refill_faucet
        // Only the owner can add more tokens into the faucet.
        // ----------------------------------------------------
        fn refill_faucet(ref self: ContractState, amount: u128) {
            let caller = get_caller_address();

            assert!(
                caller == self.owner.read(),
                "Only owner can refill the faucet"
            );

            assert!(
                amount > 0,
                "Refill amount must be greater than zero"
            );

            let current_balance = self.faucet_balance.read();
            let new_balance = current_balance + amount;

            self.faucet_balance.write(new_balance);

            self.emit(FaucetRefilled {
                owner: caller,
                amount,
                new_balance,
            });
        }


        // ----------------------------------------------------
        // update_claim_amount
        // Only the owner can change how many tokens a user gets.
        // ----------------------------------------------------
        fn update_claim_amount(ref self: ContractState, new_claim_amount: u128) {
            let caller = get_caller_address();

            assert!(
                caller == self.owner.read(),
                "Only owner can update claim amount"
            );

            assert!(
                new_claim_amount > 0,
                "New claim amount must be greater than zero"
            );

            let old_amount = self.claim_amount.read();
            self.claim_amount.write(new_claim_amount);

            self.emit(ClaimAmountUpdated {
                owner: caller,
                old_amount,
                new_amount: new_claim_amount,
            });
        }


        // ----------------------------------------------------
        // update_cooldown
        // Only the owner can update the waiting time between claims.
        // ----------------------------------------------------
        fn update_cooldown(ref self: ContractState, new_cooldown_seconds: u64) {
            let caller = get_caller_address();

            assert!(
                caller == self.owner.read(),
                "Only owner can update cooldown"
            );

            let old_cooldown = self.cooldown_seconds.read();
            self.cooldown_seconds.write(new_cooldown_seconds);

            self.emit(CooldownUpdated {
                owner: caller,
                old_cooldown,
                new_cooldown: new_cooldown_seconds,
            });
        }


        // ----------------------------------------------------
        // Getter Functions
        // These only read data and do not modify contract state.
        // ----------------------------------------------------
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn get_faucet_balance(self: @ContractState) -> u128 {
            self.faucet_balance.read()
        }

        fn get_claim_amount(self: @ContractState) -> u128 {
            self.claim_amount.read()
        }

        fn get_cooldown_seconds(self: @ContractState) -> u64 {
            self.cooldown_seconds.read()
        }

        fn get_total_distributed(self: @ContractState) -> u128 {
            self.total_distributed.read()
        }

        fn get_user_balance(self: @ContractState, user: ContractAddress) -> u128 {
            self.user_balances.entry(user).read()
        }

        fn get_last_claim_time(self: @ContractState, user: ContractAddress) -> u64 {
            self.last_claim_time.entry(user).read()
        }

        fn has_user_claimed(self: @ContractState, user: ContractAddress) -> bool {
            self.has_claimed_before.entry(user).read()
        }
    }
}