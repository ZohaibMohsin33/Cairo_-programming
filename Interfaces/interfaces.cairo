// =====================================================
// Cairo Interfaces Assignment
// Student: Ahmed Nadeem
// Topic: Traits and Interfaces in Cairo / Starknet
// =====================================================
//
// WHAT THIS FILE DEMONSTRATES:
// How to define an interface using traits in Cairo  
// and how to implement that interface in a smart contract.
//
// We are building a simple Counter Contract that anyone
// can read from and write to on the Starknet blockchain.
// =====================================================


// -------------------------------------------------------
// STEP 1: DEFINE THE INTERFACE
// -------------------------------------------------------
// This is our trait — the interface/promise our contract must keep.
// Anyone interacting with our contract will use these function signatures.
// They do not need to know HOW we implement them, just WHAT they do.
//
// TContractState is a generic type — it represents the contract's state.
// We use generics here so this interface can work with any contract.
// -------------------------------------------------------

#[starknet::interface]
trait ICounter<TContractState> {

    // Read-only function — just returns the current count
    // Uses @TContractState which means "do not modify anything, just read"
    fn get_count(self: @TContractState) -> u32;

    // Write function — increases the count by 1
    // Uses ref TContractState which means "you are allowed to change state"
    fn increment(ref self: TContractState);

    // Write function — resets the counter back to zero
    // Also uses ref because we are modifying storage
    fn reset(ref self: TContractState);
}


// -------------------------------------------------------
// STEP 2: IMPLEMENT THE CONTRACT
// -------------------------------------------------------
// This is the actual contract that FULFILLS our interface.
// It must implement every single function defined in ICounter.
// If even one function is missing, Scarb will throw a compile error.
// -------------------------------------------------------

#[starknet::contract]
mod CounterContract {

    // -------------------------------------------------------
    // STORAGE
    // -------------------------------------------------------
    // This is where our data lives permanently on the blockchain.
    // Every time someone calls increment(), this number changes
    // and that change is saved forever on Starknet.
    // -------------------------------------------------------
    #[storage]
    struct Storage {
        count: u32,   // our single piece of state — the counter value
    }


    // -------------------------------------------------------
    // IMPLEMENTATION
    // -------------------------------------------------------
    // Here we fulfill the promise made by ICounter.
    // The #[abi(embed_v0)] attribute makes these functions
    // publicly callable from outside the contract (by users, frontends, etc.)
    // -------------------------------------------------------
    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {

        // GET COUNT
        // Simply reads the current value from storage and returns it
        // Does not cost gas because it is a view function (read-only)
        fn get_count(self: @ContractState) -> u32 {
            self.count.read()
        }

        // INCREMENT
        // Reads the current count, adds 1 to it, then writes it back
        // This costs gas because we are writing to the blockchain
        fn increment(ref self: ContractState) {
            let current_count = self.count.read();   // read current value
            self.count.write(current_count + 1);     // write new value
        }

        // RESET
        // Sets the count back to zero
        // Useful if the contract owner wants to start fresh
        // Also costs gas because it is a write operation
        fn reset(ref self: ContractState) {
            self.count.write(0);
        }
    }
}


// =====================================================
// SUMMARY OF WHAT HAPPENED HERE:
//
// 1. We defined a trait (ICounter) — this is our interface
//    It lists 3 functions: get_count, increment, reset
//
// 2. We created a contract (CounterContract) with storage
//    Storage holds one value: count (a u32 number)
//
// 3. We implemented the trait on our contract
//    Every function from the interface is now fully working
//
// 4. The interface separates DEFINITION from IMPLEMENTATION
//    Other contracts can interact with ours using just the interface
//    They do not need to know our internal logic at all
//
// This pattern is used in EVERY serious Starknet project.
// ERC20 tokens, NFTs, DeFi vaults — all use traits as interfaces.
// =====================================================
