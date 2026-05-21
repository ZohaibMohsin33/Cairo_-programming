# Hash Verifier Frontend (Local Devnet)

This frontend is a bonus UI for the Cairo Hash Verifier contract. The core logic remains in Cairo. The UI connects to a local StarkNet devnet and lets you:

- Connect a wallet
- Store a hash for a user (admin only)
- Read stored hashes
- Verify an age against the stored hash

## Requirements

- Node.js 20.17 or newer
- A running local devnet (RPC at http://127.0.0.1:5050)
- A deployed Hash Verifier contract address

## Setup

Install dependencies:

```bash
npm install
```

Start the dev server:

```bash
npm run dev
```

## Devnet Commands (Quick Start)

Start devnet:

```bash
starknet-devnet
```

Build the Cairo contract:

```bash
cd ..
scarb build
```

Deploy (example with sncast):

```bash
sncast declare --contract-name HashVerifier --account devnet
sncast deploy --class-hash <CLASS_HASH> --account devnet --constructor-args <ADMIN_ADDRESS>
```

Use the deployed contract address in the frontend.

## Usage

1. Enter your RPC URL and contract address.
2. Connect your StarkNet wallet.
3. Load the admin address.
4. Store and verify hashes using the panels.

Note: If your wallet is not connected to the local devnet, transactions will fail. The Verify (Call) option still works for read-only checks.
