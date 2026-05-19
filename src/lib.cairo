use starknet::ContractAddress;

#[starknet::interface]
trait IToyToken<TContractState> {
    fn get_total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
}

#[starknet::contract]
mod ToyToken {
    use starknet::{ContractAddress, get_caller_address, contract_address_const};
    use core::num::traits::Zero;
    
    // Explicitly import Map along with its implementation access traits to satisfy the plugin inference
    use starknet::storage::{
        Map, 
        StorageMapReadAccess, 
        StorageMapWriteAccess, 
        StoragePointerReadAccess, 
        StoragePointerWriteAccess
    };

    #[storage]
    struct Storage {
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
        allowances: Map<(ContractAddress, ContractAddress), u256>,
    }

    // Modern Starknet 2.8+ Event handling
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_supply: u256, recipient: ContractAddress) {
        assert(!recipient.is_zero(), 'Mint to the zero address');
        self.total_supply.write(initial_supply);
        self.balances.write(recipient, initial_supply);
        
        self.emit(Transfer { 
            from: contract_address_const::<0>(), 
            to: recipient, 
            value: initial_supply 
        });
    }

    #[abi(embed_v0)]
    impl ToyTokenImpl of super::IToyToken<ContractState> {
        fn get_total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let sender = get_caller_address();
            self.execute_transfer(sender, recipient, amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let owner = get_caller_address();
            assert(!spender.is_zero(), 'Approve to zero address');

            self.allowances.write((owner, spender), amount);
            self.emit(Approval { owner, spender, value: amount });
            true
        }

        fn transfer_from(
            ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
        ) -> bool {
            let spender = get_caller_address();
            let current_allowance = self.allowances.read((sender, spender));
            assert(current_allowance >= amount, 'Insufficient allowance');

            self.allowances.write((sender, spender), current_allowance - amount);
            self.execute_transfer(sender, recipient, amount);
            true
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn execute_transfer(
            ref self: ContractState, 
            sender: ContractAddress, 
            recipient: ContractAddress, 
            amount: u256
        ) {
            assert(!recipient.is_zero(), 'Transfer to zero address');
            
            let sender_balance = self.balances.read(sender);
            assert(sender_balance >= amount, 'Insufficient balance');

            self.balances.write(sender, sender_balance - amount);
            let recipient_balance = self.balances.read(recipient);
            self.balances.write(recipient, recipient_balance + amount);

            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }
    }
}

