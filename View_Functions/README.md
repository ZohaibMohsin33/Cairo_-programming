# View Functions
### by Syed Muhammad Ahmer | BSCS23167
This README explains how view functions are used in Cairo smart contracts. It includes examples of storage reading, write operations, and the contract data model.

## Read vs Write Functions

| Feature | View Function | External Write Function |
|---|---|---|
| Can read storage | Yes | Yes |
| Can modify storage | No | Yes |
| Uses immutable access | Yes | No |
| Uses mutable access | No | Yes |
| Main purpose | Fetch data | Update data |

## Mutable vs Immutable Access

### Mutable Access
- Used when modifying contract storage.
- Example:
```rust
ref self: ContractState
```
- This is used inside write functions.

### Immutable Access
- Used when only reading storage.
- Example:
```rust
self: @ContractState
```
- This is used inside view functions.

## Storage Variables

The contract contains:
- `counter`
- `owner_name`
- `student`

### Student structure
```rust
struct Student {
    id: u32,
    age: u32,
    marks: u32,
}
```
This structure stores student information.

## Function Summary

- `set_counter()` — Updates the counter value.
- `increment_counter()` — Reads the current counter and increases it by 1.
- `get_counter()` — A view function that returns the current counter value.
- `get_owner_name()` — Returns the stored owner name.
- `get_student()` — Returns the complete student structure.
- `get_student_marks()` — Returns only the student's marks.
- `is_student_passed()` — Checks if marks are greater than or equal to 50.
  - Returns `true` → pass
  - Returns `false` → fail

## Examples

### Storage read
```rust
self.counter.read()
```
Reads a value from storage.

### Storage write
```rust
self.counter.write(value)
```
Writes a value into storage.

## Concepts Learned

This assignment demonstrates:
- Cairo smart contracts
- View functions
- External write functions
- Storage management
- Structures
- Immutable references
- Mutable references
- Boolean logic
- Returning data from contracts

## Advantages of View Functions

- Safe because they do not modify blockchain state
- Useful for frontend applications
- Efficient for reading data
- Improve smart contract usability

## Real World Usage

View functions are used in:
- Wallet applications
- NFT marketplaces
- Voting systems
- Banking applications
- DeFi dashboards
- Blockchain explorers

## How to Run the Project

```bash
scarb build
```

```bash
scarb test
```

## Expected Output Examples

### Example 1
Counter value:
```text
5
```

### Example 2
Student structure:
```text
Student {
    id: 1,
    age: 20,
    marks: 95
}
```

## Conclusion

This assignment explains how view functions work in Cairo smart contracts. The project demonstrates how to store blockchain data, read data safely, return structures, and create efficient smart contract interfaces.

View functions are one of the most important concepts in smart contract development because blockchain applications constantly need to read data from contracts.
