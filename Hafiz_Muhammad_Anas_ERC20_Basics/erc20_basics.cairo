use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, amount: u256);
}

#[starknet::contract]
mod ERC20 {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    #[storage]
    struct Storage {
        name:         felt252,
        symbol:       felt252,
        decimals:     u8,
        total_supply: u256,
        balances:     Map<ContractAddress, u256>,
        allowances:   Map<(ContractAddress, ContractAddress), u256>,
        owner:        ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key] from:  ContractAddress,
        #[key] to:    ContractAddress,
        value: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key] owner:   ContractAddress,
        #[key] spender: ContractAddress,
        value: u256,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name:           felt252,
        symbol:         felt252,
        initial_supply: u256,
        recipient:      ContractAddress,
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(18_u8);
        self.owner.write(recipient);
        self._mint(recipient, initial_supply);
    }

    #[abi(embed_v0)]
    impl ERC20Impl of super::IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }
        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }
        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }
        fn total_supply(self: @ContractState) -> u256 {
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
            self._transfer(sender, recipient, amount);
            true
        }
        fn transfer_from(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            let current_allowance = self.allowances.read((sender, caller));
            assert(current_allowance >= amount, 'ERC20: insufficient allowance');
            self.allowances.write((sender, caller), current_allowance - amount);
            self.emit(Event::Approval(Approval { owner: sender, spender: caller, value: current_allowance - amount }));
            self._transfer(sender, recipient, amount);
            true
        }
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let owner = get_caller_address();
            self.allowances.write((owner, spender), amount);
            self.emit(Event::Approval(Approval { owner, spender, value: amount }));
            true
        }
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'ERC20: caller is not owner');
            self._mint(recipient, amount);
        }
        fn burn(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();
            self._burn(caller, amount);
        }
    }

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        fn _transfer(
            ref self:  ContractState,
            sender:    ContractAddress,
            recipient: ContractAddress,
            amount:    u256,
        ) {
            let sender_balance = self.balances.read(sender);
            assert(sender_balance >= amount, 'ERC20: insufficient balance');
            self.balances.write(sender,    sender_balance - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Event::Transfer(Transfer { from: sender, to: recipient, value: amount }));
        }

        fn _mint(
            ref self:  ContractState,
            recipient: ContractAddress,
            amount:    u256,
        ) {
            self.total_supply.write(self.total_supply.read() + amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            let zero: ContractAddress = 0.try_into().unwrap();
            self.emit(Event::Transfer(Transfer { from: zero, to: recipient, value: amount }));
        }

        fn _burn(
            ref self: ContractState,
            account:  ContractAddress,
            amount:   u256,
        ) {
            let balance = self.balances.read(account);
            assert(balance >= amount, 'ERC20: burn exceeds balance');
            self.balances.write(account, balance - amount);
            self.total_supply.write(self.total_supply.read() - amount);
            let zero: ContractAddress = 0.try_into().unwrap();
            self.emit(Event::Transfer(Transfer { from: account, to: zero, value: amount }));
        }
    }
}

use ERC20::InternalTrait;

fn main() -> u256 {
    let alice:   ContractAddress = 1.try_into().unwrap();
    let bob:     ContractAddress = 2.try_into().unwrap();
    let charlie: ContractAddress = 3.try_into().unwrap();

    let mut state = ERC20::contract_state_for_testing();
    ERC20::constructor(ref state, 'MyToken', 'MTK', 1000_u256, alice);

    // balance_of
    assert(state.balance_of(alice) == 1000_u256, 'wrong initial balance');

    // transfer: Alice → Bob 300
    state._transfer(alice, bob, 300_u256);
    assert(state.balance_of(alice) == 700_u256, 'alice after transfer');
    assert(state.balance_of(bob)   == 300_u256, 'bob after transfer');

    // allowance setup: Alice approves Bob for 200
    state.allowances.write((alice, bob), 200_u256);
    assert(state.allowance(alice, bob) == 200_u256, 'wrong allowance');

    // transfer_from simulation: Alice → Charlie 150 via Bob
    state._transfer(alice, charlie, 150_u256);
    state.allowances.write((alice, bob), 50_u256);
    assert(state.balance_of(alice)     == 550_u256, 'alice after tfrom');
    assert(state.balance_of(charlie)   == 150_u256, 'charlie after tfrom');
    assert(state.allowance(alice, bob) ==  50_u256, 'allowance reduced');

    // mint: +500 to Bob  →  total_supply 1000 → 1500
    state._mint(bob, 500_u256);
    assert(state.balance_of(bob) == 800_u256,  'bob after mint');
    assert(state.total_supply()  == 1500_u256, 'supply after mint');

    // burn: -100 from Bob  →  total_supply 1500 → 1400
    state._burn(bob, 100_u256);
    assert(state.balance_of(bob) == 700_u256,  'bob after burn');
    assert(state.total_supply()  == 1400_u256, 'supply after burn');

    state.total_supply() // returns 1400
}