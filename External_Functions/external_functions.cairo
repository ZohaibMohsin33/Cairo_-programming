// Topic: External Functions in Cairo (Starknet Smart Contracts)
// Author: Muhammad Musadiq
// Description: This file demonstrates how external functions
//              work in Cairo smart contracts on Starknet.
//              External functions are callable from outside
//              the contract  by users or other contracts.

//  Trait Definition 
// Defines the interface (blueprint) of our contract's public API.
// Any contract implementing this trait must define these functions.
#[starknet::interface]
trait IExternalFunctionsDemo<TContractState> {
    // External function: stores a number on-chain
    fn set_number(ref self: TContractState, value: u128);

    // External function: reads the stored number (view only)
    fn get_number(self: @TContractState) -> u128;

    // External function: adds two numbers and stores the result
    fn add_and_store(ref self: TContractState, a: u128, b: u128);

    // External function: resets the stored number to zero
    fn reset(ref self: TContractState);

    // External function: returns a greeting message
    fn greet(self: @TContractState) -> felt252;
}

//  Contract Module 
// The actual smart contract implementation
#[starknet::contract]
mod ExternalFunctionsDemo {

    //  Storage 
    // Persistent on-chain data. This variable survives between transactions.
    #[storage]
    struct Storage {
        stored_number: u128,  // Holds the number stored by the user
    }

    //  Implementation of External Functions
    // #[abi(embed_v0)] makes these functions EXTERNAL 
    // meaning they are publicly accessible from outside the contract.
    #[abi(embed_v0)]
    impl ExternalFunctionsDemoImpl of super::IExternalFunctionsDemo<ContractState> {

        // set_number: Allows a caller to store any u128 value on-chain.
        // 'ref self' means this function MODIFIES the contract's state.
        fn set_number(ref self: ContractState, value: u128) {
            self.stored_number.write(value);  // Write value to storage
        }

        // get_number: Returns the currently stored number.
        // '@self' means this is a VIEW function it does NOT modify state.
        // View functions are free to call (no gas for reads off-chain).
        fn get_number(self: @ContractState) -> u128 {
            self.stored_number.read()  // Read value from storage
        }

        // add_and_store: Takes two numbers, adds them, and stores the result.
        // Demonstrates that external functions can contain logic, not just storage ops.
        fn add_and_store(ref self: ContractState, a: u128, b: u128) {
            let result = a + b;               // Perform addition
            self.stored_number.write(result); // Store the result
        }

        // reset: Sets the stored number back to zero.
        // Useful to clear state. Demonstrates default/reset patterns.
        fn reset(ref self: ContractState) {
            self.stored_number.write(0);  // Write 0 to storage
        }

        // greet: Returns a simple greeting as a felt252 value.
        // felt252 is Cairo's native type which can represent short strings.
        // This is a read-only (view) function with no storage interaction.
        fn greet(self: @ContractState) -> felt252 {
            'Hello from External Function!'  // Short string literal as felt252
        }
    }
}
