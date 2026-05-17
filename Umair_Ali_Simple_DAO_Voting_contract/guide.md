# Simple DAO Voting Contract

**Author:** Umair Ali  
**Language:** Cairo 2.18.0  
**Platform:** Starknet  

## What is a DAO

A Decentralised Autonomous Organisation is an organisation governed by smart contract code instead of a central authority. All decisions are made through on-chain voting by registered members.

## What This Contract Does

This contract implements a basic DAO voting system where a designated owner manages membership, members create and vote on proposals, and results are recorded permanently on the blockchain.

## Functions

### add_member
Adds a new address as a DAO member. Only the owner can call this function. Panics if caller is not owner or address is already a member.

### create_proposal
Creates a new proposal with a title and description. Only registered members can call this. Returns the proposal id starting from zero.

### vote
Casts a YES or NO vote on an open proposal. Only members can vote. Each member can vote only once per proposal. Panics if already voted or proposal is closed.

### close_proposal
Closes a proposal and records whether it passed. Can be called by anyone. If YES votes are greater than NO votes the proposal passes.

### get_proposal
Returns proposal data as a tuple: title, description, yes votes, no votes, and passed status.

### get_proposal_count
Returns the total number of proposals created.

### is_member
Returns true if the given address is a registered member.

### has_voted
Returns true if the given address has voted on the given proposal.

## Events

| Event | Trigger |
|---|---|
| MemberAdded | A new member is registered |
| ProposalCreated | A new proposal is opened |
| VoteCast | A member casts a vote |
| ProposalClosed | A proposal is closed with result |

## Security

- Only the owner can add members
- Only members can create proposals and vote
- Double voting is prevented using the voted map
- Voting on a closed proposal is rejected
- All checks use assert statements that revert the transaction on failure

## Tests

| Test | What it Checks |
|---|---|
| test_owner_is_member | Owner is automatically a member after deploy |
| test_add_member | Owner can successfully add a new member |
| test_non_owner_cannot_add_member | Non-owner is rejected when adding member |
| test_create_proposal | Member can create a proposal and id starts at zero |
| test_non_member_cannot_propose | Stranger cannot create a proposal |
| test_full_voting_flow | Full flow from create to close with correct result |
| test_no_double_vote | Second vote from same address is rejected |
| test_cannot_vote_on_closed | Vote on closed proposal is rejected |
| test_proposal_fails | Proposal with more NO than YES is marked failed |
| test_has_voted_check | has_voted returns correct value before and after voting |

## Key Cairo Concepts

| Concept | Description |
|---|---|
| #[starknet::contract] | Marks the module as a deployable contract |
| #[storage] | Declares all persistent on-chain state |
| #[event] | Defines events that are logged to the blockchain |
| Map<K, V> | Key-value storage, equivalent to Solidity mapping |
| get_caller_address() | Returns the address sending the transaction |
| assert() | Reverts transaction if condition is false |
| #[constructor] | Runs once when the contract is deployed |

## References

- Cairo Book: https://book.cairo-lang.org
- Starknet Foundry: https://foundry-rs.github.io/starknet-foundry
- Scarb Docs: https://docs.swmansion.com/scarb
- Starknet Docs: https://docs.starknet.io
