# Counter Program in Cairo

## What is a Counter Program

A counter program is one of the simplest smart contracts you can write. It stores a number on the blockchain and lets you change that number by calling different functions. You can increase it, decrease it, reset it back to zero, or set it to any value you want.

The reason this is taught first is because it covers all the basic building blocks of a smart contract. Once you understand how a counter works, you can understand almost any other contract.

Think of it like a physical tally counter that a person uses to count people entering a room. The difference is that this one lives on the blockchain, so the number is stored permanently, anyone can see it, and no one can secretly change it.

---

## What is Cairo

Cairo is a programming language made by a company called StarkWare. It is designed specifically for writing smart contracts on Starknet, which is a blockchain that runs on top of Ethereum.

What makes Cairo different from other languages is that it uses something called Zero Knowledge Proofs. This means when your contract runs, it generates a mathematical proof that proves the code ran correctly. This proof is then verified on Ethereum. So the results are trustworthy without needing to re-run the code.

---

## What is Starknet

Starknet is a Layer 2 blockchain. Layer 2 means it sits on top of Ethereum and makes transactions faster and cheaper. Instead of running every transaction on Ethereum directly, Starknet processes them in batches and sends a single proof to Ethereum.

Cairo smart contracts are deployed on Starknet. When you call a function in your contract, the transaction is processed on Starknet and a proof is generated to confirm it happened correctly.

---

## What is Scarb

Scarb is the package manager and build tool for Cairo. It works the same way pip works for Python or npm works for JavaScript. You use it to create projects, add dependencies, build your code, and run tests.

To build a Cairo project you run scarb build. To run tests you run scarb test.

---

## How the Counter Contract is Structured

The contract is divided into a few main parts. Each part has a specific job.

### Interface

The interface is like a menu. It lists all the functions that the contract has and what they return. Other contracts or users can look at the interface to know what they can call.

In Cairo, interfaces are written using the trait keyword. Every function that users can call from outside is listed here.

### Storage

Storage is the memory of the contract. Whatever you store here is saved permanently on the blockchain. Unlike a regular variable in a program that disappears when the program closes, storage variables stay forever.

In this contract, three things are stored. The first is the counter value itself. The second is a count of how many times the counter was incremented. The third is a count of how many times it was decremented. The last two are bonus features that make the contract more useful.

To read a value from storage you use .read(). To save a value you use .write().

### Events

Events are notifications that get recorded on the blockchain whenever something important happens. Every time the counter changes, an event is emitted. This creates a permanent history of every change that was ever made.

Events are useful because a website or app can listen for them and update automatically. They are also useful for checking the history of what happened in a contract.

This contract has four events. One fires when the counter is incremented, one when it is decremented, one when it is reset, and one when it is set to a custom value.

### Constructor

The constructor is a special function that runs only once, at the moment the contract is deployed. It never runs again after that.

In this contract, the constructor takes a starting value and writes it to storage. It also sets both tracker variables to zero. This means when you deploy the contract, you can choose what number the counter starts at.

### Functions

The contract has seven functions in total.

get_count reads the current value of the counter and returns it. It does not change anything, so it is free to call.

increment reads the current value, adds one to it, saves the new value, updates the increment tracker, and emits an event.

decrement checks if the counter is above zero first. If it is, it subtracts one, saves the result, updates the decrement tracker, and emits an event. If the counter is already at zero, it does nothing. This check is important because the counter uses a type called u32 which cannot hold negative numbers. Without this check, trying to subtract from zero would crash the contract.

reset sets the counter directly to zero and emits an event.

set_count lets you set the counter to any number you want. It writes the value directly and emits an event.

get_increment_count returns the total number of times increment was called since the contract was deployed.

get_decrement_count returns the total number of times decrement was called since the contract was deployed.

---

## The u32 Type

The counter uses a type called u32. This stands for unsigned 32-bit integer. Unsigned means it can only hold zero and positive numbers, never negative. 32-bit means it can hold values from zero up to about 4.2 billion.

This type was chosen because a counter should never be negative, and 4.2 billion is more than enough range for any practical use.

The fact that u32 cannot go negative is why the decrement function has a safety check. Without it, subtracting from zero would cause the program to panic and stop.

---

## The Difference Between Read and Write Functions

In Cairo, there are two kinds of functions. Functions that only read data use @ContractState as their parameter. These are free to call because they do not change anything on the blockchain.

Functions that change data use ref self: ContractState as their parameter. These cost gas because writing new data to the blockchain requires the network to process and store it.

get_count, get_increment_count, and get_decrement_count are read-only functions. increment, decrement, reset, and set_count are functions that change state.

---

## Tests

The contract includes ten tests that verify every function works correctly. Tests in Cairo are written in a separate module marked with cfg(test). They only run when you use scarb test and are not included in the deployed contract.

Each test deploys a fresh copy of the contract and then calls functions on it to check the results. If the result does not match what is expected, the test fails.

The tests cover the following cases. Starting value is zero. Custom starting value works. Increment adds one correctly. Decrement subtracts one correctly. Decrement does not go below zero. Reset brings the counter back to zero. Set count jumps to any value. The increment tracker counts correctly. The decrement tracker counts correctly. A full real-world simulation where multiple functions are called in sequence.

All ten tests pass successfully.

---

## Real World Uses of a Counter

A counter pattern is used in many real blockchain applications. In NFT projects, a counter tracks how many tokens have been minted. In voting systems, counters track how many votes each option has received. In DAOs, counters track yes and no votes on proposals. In token contracts, counters track supply. In games, counters track scores or levels.

The counter is simple but it is the foundation that almost every other contract builds on.

---

## What I Learned

Working on this assignment taught me how smart contracts store data permanently using storage variables. I learned how to define an interface and implement it. I learned the difference between read-only functions and functions that change state. I learned how events work and why they are important for tracking history. I learned how to write tests and run them with Scarb. I also learned about type safety and why the u32 type requires an underflow check in the decrement function.

The counter contract is small, but understanding every part of it gives you a strong foundation for writing more advanced contracts in Cairo.
