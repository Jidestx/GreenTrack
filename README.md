# GreenTrack - Carbon Credit Management System with NFT Integration

A transparent, blockchain-based platform for tracking and trading carbon credits as NFTs on the Stacks blockchain.

## Overview

GreenTrack enables organizations to issue, verify, trade, and retire carbon credits with full transparency and immutability. Built on Stacks blockchain using Clarity smart contracts and implementing the SIP-009 NFT standard, it provides a trustless system for environmental impact tracking with enhanced ownership and marketplace integration.

## ✨ New Features

### NFT Integration
- **SIP-009 Compliance**: Carbon credits are now fully compliant NFTs
- **Enhanced Ownership**: Clear, verifiable ownership through blockchain standards
- **Marketplace Ready**: Built-in marketplace functions for listing and trading
- **Metadata Support**: Rich metadata with unique URIs for each credit
- **Collection Management**: Proper NFT collection with name and symbol

## Features

- **Credit Issuance**: Issue carbon credits as NFTs with project type and amount
- **Verification System**: Admin verification for credit authenticity
- **NFT Trading Platform**: Transfer credits between users as standard NFTs
- **Marketplace Integration**: List credits for sale and purchase directly
- **Retirement Tracking**: Permanent retirement of credits (NFT burning) to prevent double counting
- **Project Registry**: Register and track environmental projects with credit linking
- **Balance Management**: Real-time balance and NFT count tracking for all users
- **Batch Operations**: Retire multiple credits in a single transaction
- **Metadata Support**: Dynamic metadata generation for each carbon credit NFT

## Smart Contract Functions

### SIP-009 NFT Standard Functions
- `get-last-token-id()` - Get the last minted token ID
- `get-token-uri(token-id)` - Get metadata URI for a token
- `get-owner(token-id)` - Get current owner of an NFT
- `transfer(token-id, sender, recipient)` - Transfer NFT ownership
- `get-balance(owner)` - Get NFT count for an owner

### Read-Only Functions
- `get-credit-info(credit-id)` - Retrieve credit details
- `get-user-balance(user)` - Get user's total credit balance
- `get-project-info(project-id)` - Get project details
- `get-contract-stats()` - Get overall contract statistics including NFT count
- `get-market-listing(nft-id)` - Get marketplace listing details

### Public Functions
- `register-project(name, location, project-type)` - Register a new environmental project
- `issue-credit(amount, project-type, project-id-opt)` - Issue new carbon credits as NFTs
- `verify-credit(credit-id)` - Verify credit authenticity (admin only)
- `transfer-credit(credit-id, recipient)` - Transfer credit to another user
- `retire-credit(credit-id)` - Permanently retire a credit (burn NFT)
- `batch-retire-credits(credit-ids)` - Retire multiple credits at once

### NFT Marketplace Functions
- `list-for-sale(nft-id, price)` - List an NFT for sale
- `unlist-from-sale(nft-id)` - Remove NFT from marketplace
- `buy-listed-nft(nft-id)` - Purchase a listed NFT

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing
- Understanding of SIP-009 NFT standard

### Installation
1. Clone the repository
2. Run `clarinet check` to verify contract syntax
3. Run `clarinet test` to execute test suite
4. Deploy to testnet using `clarinet deploy`

### Usage Example
```clarity
;; Register a new project
(contract-call? .greentrack register-project "Solar Farm Project" "California, USA" "renewable-energy")

;; Issue carbon credits as NFTs
(contract-call? .greentrack issue-credit u1000 "renewable-energy" (some u1))

;; Transfer credits (NFT transfer)
(contract-call? .greentrack transfer-credit u1 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK)

;; List NFT for sale
(contract-call? .greentrack list-for-sale u1 u500)

;; Buy listed NFT
(contract-call? .greentrack buy-listed-nft u1)

;; Retire credits (burn NFT)
(contract-call? .greentrack retire-credit u1)
```

## NFT Metadata

Each carbon credit NFT includes rich metadata accessible via the `get-token-uri` function:
- Credit amount and type
- Project information
- Verification status
- Creation timestamp
- Environmental impact data

Metadata format: `https://greentrack.io/api/metadata/{token-id}`

## Project Structure
```
greentrack/
├── contracts/
│   └── greentrack.clar
├── tests/
│   └── greentrack_test.ts
├── metadata/
│   └── token_metadata.json
├── Clarinet.toml
└── README.md
```

## Real-World Impact

GreenTrack addresses critical issues in the carbon credit market:
- **Transparency**: All transactions are publicly verifiable on blockchain
- **Double Counting Prevention**: Credits can only be retired once through NFT burning
- **Fraud Reduction**: Verification system prevents fake credits
- **Enhanced Liquidity**: NFT standard enables integration with existing marketplaces
- **Ownership Clarity**: Clear ownership through blockchain-native standards
- **Interoperability**: Compatible with existing NFT infrastructure and wallets
- **Accessibility**: Enables smaller projects to participate in global carbon markets
- **Trust**: Blockchain immutability ensures data integrity

## NFT Benefits

### For Credit Holders
- **Wallet Integration**: View credits in any SIP-009 compatible wallet
- **Marketplace Access**: Trade on existing NFT marketplaces
- **Provable Ownership**: Cryptographic proof of ownership
- **Rich Metadata**: Detailed information about environmental impact

### For Developers
- **Standard Compliance**: Built on established NFT standards
- **Easy Integration**: Compatible with existing NFT tools and services
- **Extensible**: Can be extended with additional NFT functionality
- **Marketplace Ready**: Built-in trading capabilities

## Technical Specifications

- **Blockchain**: Stacks
- **Standard**: SIP-009 NFT Trait
- **Language**: Clarity
- **Collection Name**: "GreenTrack Carbon Credits"
- **Symbol**: "GTCC"

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure NFT standard compliance
6. Submit a pull request
