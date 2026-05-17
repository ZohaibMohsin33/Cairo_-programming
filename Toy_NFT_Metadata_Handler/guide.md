# Toy NFT Metadata Handler Smart Contract

This contract implements a metadata handler for unique Toy NFTs on Starknet using Cairo.

## Overview

The contract allows the owner to mint unique Toy NFTs and attach comprehensive metadata properties to them. The stored metadata properties are:
1. Name (ByteArray)
2. Description (ByteArray)
3. Image URI (ByteArray)
4. Rarity (ByteArray)
5. Power Level (u32)

Anyone can query the metadata properties using the view functions.

## Interface

The contract defines the following external functions:

### View Functions

* get_name(token_id: u256) returns ByteArray
  Retrieves the name of the Toy NFT.
* get_description(token_id: u256) returns ByteArray
  Retrieves the description of the Toy NFT.
* get_image_uri(token_id: u256) returns ByteArray
  Retrieves the image link of the Toy NFT.
* get_rarity(token_id: u256) returns ByteArray
  Retrieves the rarity of the Toy NFT.
* get_power_level(token_id: u256) returns u32
  Retrieves the power level of the Toy NFT.
* get_token_owner(token_id: u256) returns ContractAddress
  Retrieves the owner address of the Toy NFT.
* get_total_minted() returns u256
  Retrieves the count of minted Toy NFTs.
* get_owner() returns ContractAddress
  Retrieves the contract owner address.

### State Modifying Functions

* mint_toy_nft(to: ContractAddress, name: ByteArray, description: ByteArray, image_uri: ByteArray, rarity: ByteArray, power_level: u32) returns u256
  Mints a new Toy NFT with the specified metadata. This function is restricted to the contract owner.
* update_metadata(token_id: u256, name: ByteArray, description: ByteArray, image_uri: ByteArray, rarity: ByteArray, power_level: u32)
  Updates the metadata of an existing Toy NFT. This function is restricted to the contract owner.
* transfer_ownership(new_owner: ContractAddress)
  Transfers contract ownership to a new address. This function is restricted to the current owner.

## Key Technical Decisions

* We use ByteArray for strings (like name, description, image URI, and rarity). This is much better than using felt252 because it supports arbitrary length strings. This is perfect for storing long IPFS links or description paragraphs.
* The contract is fully secure and validates every input. Only the contract owner can mint or update metadata.
