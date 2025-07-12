# GreenTrack - Carbon Credit Management System

A transparent, blockchain-based platform for tracking and trading carbon credits on the Stacks blockchain.

## Overview

GreenTrack enables organizations to issue, verify, trade, and retire carbon credits with full transparency and immutability. Built on Stacks blockchain using Clarity smart contracts, it provides a trustless system for environmental impact tracking.

## Features

- **Credit Issuance**: Issue carbon credits with project type and amount
- **Verification System**: Admin verification for credit authenticity
- **Trading Platform**: Transfer credits between users
- **Retirement Tracking**: Permanent retirement of credits to prevent double counting
- **Project Registry**: Register and track environmental projects
- **Balance Management**: Real-time balance tracking for all users
- **Batch Operations**: Retire multiple credits in a single transaction

## Smart Contract Functions

### Read-Only Functions
- `get-credit-info(credit-id)` - Retrieve credit details
- `get-user-balance(user)` - Get user's total credit balance
- `get-credit-owner(credit-id)` - Get current owner of a credit
- `get-project-info(project-id)` - Get project details
- `get-contract-stats()` - Get overall contract statistics

### Public Functions
- `register-project(name, location, project-type)` - Register a new environmental project
- `issue-credit(amount, project-type)` - Issue new carbon credits
- `verify-credit(credit-id)` - Verify credit authenticity (admin only)
- `transfer-credit(credit-id, recipient)` - Transfer credit to another user
- `retire-credit(credit-id)` - Permanently retire a credit
- `batch-retire-credits(credit-ids)` - Retire multiple credits at once

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing

### Installation
1. Clone the repository
2. Run `clarinet check` to verify contract syntax
3. Run `clarinet test` to execute test suite
4. Deploy to testnet using `clarinet deploy`

### Usage Example
```clarity
;; Register a new project
(contract-call? .greentrack register-project "Solar Farm Project" "California, USA" "renewable-energy")

;; Issue carbon credits
(contract-call? .greentrack issue-credit u1000 "renewable-energy")

;; Transfer credits
(contract-call? .greentrack transfer-credit u1 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK)

;; Retire credits
(contract-call? .greentrack retire-credit u1)
```

## Project Structure
```
greentrack/
├── contracts/
│   └── greentrack.clar
├── tests/
│   └── greentrack_test.ts
├── Clarinet.toml
└── README.md
```

## Real-World Impact

GreenTrack addresses critical issues in the carbon credit market:
- **Transparency**: All transactions are publicly verifiable
- **Double Counting Prevention**: Credits can only be retired once
- **Fraud Reduction**: Verification system prevents fake credits
- **Accessibility**: Enables smaller projects to participate in carbon markets
- **Trust**: Blockchain immutability ensures data integrity

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request
