// ================================================================
// Toy Event Logger — Cairo Smart Contract
// Topic  : Events & Storage in Cairo / Starknet Smart Contracts
// Author : Syeda Ayesha Gillani
// ================================================================
//
// WHAT THIS CONTRACT DOES
// -----------------------
// A simple on-chain diary for toy-related events.
// Any wallet can call log_event() to record that something
// happened to a toy (played with, lost, broken, gifted ...).
// Each entry is stored in contract storage AND emitted as a
// Starknet event so off-chain indexers / block explorers can
// read the full history without scanning storage slots.
//
// KEY CONCEPTS DEMONSTRATED
// -------------------------
//  1. #[storage]              — persistent on-chain state
//  2. Map<K,V>                — key-value mapping in storage
//  3. #[event] / emit()       — Starknet event emission
//  4. Structs + #[derive]     — custom data types for storage
//  5. #[starknet::interface]  — ABI interface declaration
//  6. Constructor             — one-time initialisation on deploy
//  7. Access control          — owner-only reset with assert()
//  8. get_caller_address      — identify who is calling
//  9. get_block_timestamp     — record when an event happened
//
// BUILD: scarb build
// ================================================================

// ── Imports ─────────────────────────────────────────────────────
use starknet::ContractAddress; // Starknet account/contract address type

// ================================================================
// INTERFACE
// Declares every external function the contract exposes.
// Starknet reads this to generate the contract's ABI.
// TContractState is a generic parameter — the compiler fills it
// in with the real storage type when building the contract.
// ================================================================
#[starknet::interface]
trait IToyEventLogger<TContractState> {
    /// Record a new toy event in the on-chain log.
    /// Anyone can call this — no restriction on caller.
    ///
    /// # Parameters
    /// - toy_name   : felt252 — name of the toy, e.g. 'Lego', 'Teddy'
    /// - event_type : felt252 — category, e.g. 'played', 'lost', 'broken'
    /// - notes      : felt252 — short free-form note (max ~31 ASCII chars)
    fn log_event(ref self: TContractState, toy_name: felt252, event_type: felt252, notes: felt252);

    /// Return the total number of events ever logged.
    fn get_event_count(self: @TContractState) -> u64;

    /// Return a single event by its zero-based index.
    /// Panics with 'Index out of bounds' if index >= event_count.
    fn get_event(self: @TContractState, index: u64) -> ToyEvent;

    /// Return the most recent event submitted by a specific address.
    /// Panics with 'Address has never logged' if that address has no events.
    fn get_last_event_by(self: @TContractState, logger: ContractAddress) -> ToyEvent;

    /// Delete all logged events and reset the counter to zero.
    /// RESTRICTED — only the contract owner (deployer) may call this.
    fn reset_log(ref self: TContractState);
}

// ================================================================
// STRUCT — ToyEvent
// Represents one log entry. Each field is a felt252 or a native
// Starknet type, which keeps storage layout simple and cheap.
//
// #[derive] macros are compile-time code generation:
//   Drop            — value can be silently discarded (required by Cairo)
//   Serde           — serialise / deserialise for ABI calls
//   starknet::Store — can be written to and read from contract storage
//   Copy            — value can be duplicated without moving ownership
// ================================================================
#[derive(Drop, Serde, starknet::Store, Copy)]
struct ToyEvent {
    toy_name: felt252,          // e.g. 'Lego', 'Teddy Bear'
    event_type: felt252,        // e.g. 'played', 'broken', 'lost', 'found', 'gifted'
    notes: felt252,             // Short description, e.g. 'Left in garden'
    logged_by: ContractAddress, // The wallet address that submitted this entry
    timestamp: u64,             // Block timestamp (seconds since Unix epoch)
}

// ================================================================
// CONTRACT MODULE
// Everything inside mod ToyEventLogger { } is compiled into the
// actual on-chain contract bytecode.
// ================================================================
#[starknet::contract]
mod ToyEventLogger {
    use super::{ToyEvent, ContractAddress};

    // Cairo 2.6+ requires these storage traits imported explicitly.
    // Without them .read() and .write() are not found on storage fields.
    use starknet::storage::{
        StoragePointerReadAccess,   // enables .read() on plain fields
        StoragePointerWriteAccess,  // enables .write() on plain fields
        StorageMapReadAccess,       // enables .read(key) on Map fields
        StorageMapWriteAccess,      // enables .write(key, val) on Map fields
        Map,                        // the Map<K,V> type itself
    };
    use starknet::get_caller_address;  // Returns the address of the current caller
    use starknet::get_block_timestamp; // Returns the current block's Unix timestamp (u64)

    // ── Storage ─────────────────────────────────────────────────
    // #[storage] marks the single struct that holds ALL persistent
    // state for this contract. Every field here survives between
    // transactions. Reading costs gas; writing costs more gas.
    // ────────────────────────────────────────────────────────────
    #[storage]
    struct Storage {
        /// Running total of events ever logged.
        /// Used as the next insertion index (0-based).
        event_count: u64,

        /// The main log: maps an index (u64) to a ToyEvent.
        /// Think of it as a dynamic array backed by a hash map.
        events: Map<u64, ToyEvent>,

        /// Tracks the index of each address's most recent event.
        /// Lets us answer "what was the last thing X logged?"
        last_event_index_by: Map<ContractAddress, u64>,

        /// Boolean flag: true if an address has ever called log_event.
        /// Prevents reading last_event_index_by for unknown addresses.
        has_logged: Map<ContractAddress, bool>,

        /// The deployer's address. Set once in the constructor.
        /// Used to restrict reset_log() to the owner only.
        owner: ContractAddress,
    }

    // ── Events ──────────────────────────────────────────────────
    // Starknet events are NOT stored in contract storage.
    // They are written into the transaction receipt and picked up
    // by off-chain services (block explorers, indexers like Apibara).
    //
    // #[key] fields are indexed — callers can filter events by them
    // cheaply without scanning every receipt.
    // ────────────────────────────────────────────────────────────
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ToyEventLogged: ToyEventLogged, // Fired on every successful log_event call
        LogReset: LogReset,             // Fired when the owner wipes the log
    }

    /// Emitted each time a new toy event is recorded.
    #[derive(Drop, starknet::Event)]
    struct ToyEventLogged {
        #[key]
        index: u64,                 // Position in the log (filterable)
        #[key]
        logged_by: ContractAddress, // Caller address (filterable)
        toy_name: felt252,
        event_type: felt252,
        timestamp: u64,
    }

    /// Emitted when the owner resets the entire log.
    #[derive(Drop, starknet::Event)]
    struct LogReset {
        reset_by: ContractAddress, // Must be owner
        previous_count: u64,       // How many events existed before the wipe
    }

    // ── Constructor ──────────────────────────────────────────────
    // Runs exactly ONCE when the contract is deployed to Starknet.
    // Sets up initial state that can't be changed afterwards (owner).
    // ────────────────────────────────────────────────────────────
    #[constructor]
    fn constructor(ref self: ContractState) {
        // get_caller_address() here returns the deploying account
        self.owner.write(get_caller_address());
        // Initialise the counter explicitly to 0
        self.event_count.write(0);
    }

    // ── Interface Implementation ─────────────────────────────────
    // #[abi(embed_v0)] tells Starknet to expose these functions
    // publicly so external callers and frontends can invoke them.
    // ────────────────────────────────────────────────────────────
    #[abi(embed_v0)]
    impl ToyEventLoggerImpl of super::IToyEventLogger<ContractState> {

        // --------------------------------------------------------
        // log_event — PUBLIC, any caller
        // Records a new toy event and emits ToyEventLogged.
        // --------------------------------------------------------
        fn log_event(
            ref self: ContractState,
            toy_name: felt252,
            event_type: felt252,
            notes: felt252,
        ) {
            // Capture who is calling and when
            let caller: ContractAddress = get_caller_address();
            let timestamp: u64 = get_block_timestamp();

            // Read the current counter — this becomes the new event's index
            let index: u64 = self.event_count.read();

            // Construct the ToyEvent struct from the call parameters
            let new_event = ToyEvent {
                toy_name,      // shorthand for toy_name: toy_name
                event_type,
                notes,
                logged_by: caller,
                timestamp,
            };

            // Write the struct into storage at position `index`
            self.events.write(index, new_event);

            // Remember this address's latest event index
            self.last_event_index_by.write(caller, index);
            // Mark that this address has logged at least once
            self.has_logged.write(caller, true);

            // Increment the counter so the next event gets a fresh index
            self.event_count.write(index + 1);

            // Emit the Starknet event (visible in transaction receipts)
            self.emit(Event::ToyEventLogged(ToyEventLogged {
                index,
                logged_by: caller,
                toy_name,
                event_type,
                timestamp,
            }));
        }

        // --------------------------------------------------------
        // get_event_count — READ-ONLY (free, no gas)
        // --------------------------------------------------------
        fn get_event_count(self: @ContractState) -> u64 {
            self.event_count.read()
        }

        // --------------------------------------------------------
        // get_event — READ-ONLY (free, no gas)
        // Returns the ToyEvent stored at a given index.
        // --------------------------------------------------------
        fn get_event(self: @ContractState, index: u64) -> ToyEvent {
            let count = self.event_count.read();
            // assert panics (reverts) if the condition is false
            assert(index < count, 'Index out of bounds');
            self.events.read(index)
        }

        // --------------------------------------------------------
        // get_last_event_by — READ-ONLY (free, no gas)
        // Looks up the most recent event from a given address.
        // --------------------------------------------------------
        fn get_last_event_by(self: @ContractState, logger: ContractAddress) -> ToyEvent {
            // Guard: the address must have logged at least once
            let logged: bool = self.has_logged.read(logger);
            assert(logged, 'Address has never logged');

            // Retrieve their last event index, then fetch the event
            let idx: u64 = self.last_event_index_by.read(logger);
            self.events.read(idx)
        }

        // --------------------------------------------------------
        // reset_log — OWNER ONLY (costs gas, changes state)
        // Wipes the event counter so all previous indices are
        // effectively unreachable (storage slots stay but the
        // counter won't point to them again).
        // --------------------------------------------------------
        fn reset_log(ref self: ContractState) {
            let caller: ContractAddress = get_caller_address();
            let owner: ContractAddress = self.owner.read();

            // Access control: revert if caller is not the owner
            assert(caller == owner, 'Only owner can reset');

            // Save current count for the emitted event
            let previous_count: u64 = self.event_count.read();

            // Reset counter — old events now unreachable via get_event
            self.event_count.write(0);

            // Emit so off-chain systems know the log was wiped
            self.emit(Event::LogReset(LogReset {
                reset_by: caller,
                previous_count,
            }));
        }
    }
}
