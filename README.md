# GreenTrack - Carbon Credit Management System with NFT Integration

A transparent, blockchain-based platform for tracking and trading carbon credits as NFTs on the Stacks blockchain with automated oracle data integration.

## Overview

GreenTrack enables organizations to issue, verify, trade, and retire carbon credits with full transparency and immutability. Built on Stacks blockchain using Clarity smart contracts and implementing the SIP-009 NFT standard, it provides a trustless system for environmental impact tracking with enhanced ownership, marketplace integration, and automated credit generation through IoT sensors and environmental data oracles.

## ✨ Latest Features

### Oracle Integration 🌐
- **IoT Sensor Connectivity**: Automated credit generation from environmental sensors
- **Data Oracle Support**: Integration with external environmental data providers
- **Real-time Processing**: Automatic validation and credit issuance based on sensor data
- **Threshold Management**: Configurable minimum carbon offset requirements
- **Data Freshness Validation**: Time-based validation of oracle data
- **Multi-source Support**: Multiple oracle and sensor data sources per project

### NFT Integration
- **SIP-009 Compliance**: Carbon credits are now fully compliant NFTs
- **Enhanced Ownership**: Clear, verifiable ownership through blockchain standards
- **Marketplace Ready**: Built-in marketplace functions for listing and trading
- **Metadata Support**: Rich metadata with unique URIs for each credit
- **Collection Management**: Proper NFT collection with name and symbol

## Features

- **Credit Issuance**: Issue carbon credits as NFTs with project type and amount
- **Oracle-Generated Credits**: Automated credit generation from verified sensor data
- **Verification System**: Admin verification for credit authenticity
- **NFT Trading Platform**: Transfer credits between users as standard NFTs
- **Marketplace Integration**: List credits for sale and purchase directly
- **Retirement Tracking**: Permanent retirement of credits (NFT burning) to prevent double counting
- **Project Registry**: Register and track environmental projects with oracle integration
- **Balance Management**: Real-time balance and NFT count tracking for all users
- **Batch Operations**: Retire multiple credits in a single transaction
- **Metadata Support**: Dynamic metadata generation for each carbon credit NFT
- **Oracle Management**: Authorize and manage environmental data oracles
- **Data Source Validation**: Ensure data integrity from multiple sources

## Smart Contract Functions

### SIP-009 NFT Standard Functions
- `get-last-token-id()` - Get the last minted token ID
- `get-token-uri(token-id)` - Get metadata URI for a token
- `get-owner(token-id)` - Get current owner of an NFT
- `transfer(token-id, sender, recipient)` - Transfer NFT ownership
- `get-balance(owner)` - Get NFT count for an owner

### Read-Only Functions
- `get-credit-info(credit-id)` - Retrieve credit details including oracle information
- `get-user-balance(user)` - Get user's total credit balance
- `get-project-info(project-id)` - Get project details including oracle configuration
- `get-contract-stats()` - Get overall contract statistics including oracle-generated credits
- `get-market-listing(nft-id)` - Get marketplace listing details
- `get-oracle-info(oracle)` - Get oracle authorization and status information
- `get-environmental-data(data-id)` - Get environmental sensor/oracle data
- `is-oracle-authorized(oracle)` - Check if an oracle is authorized

### Public Functions
- `register-project(name, location, project-type)` - Register a new environmental project
- `issue-credit(amount, project-type, project-id-opt)` - Issue new carbon credits as NFTs
- `verify-credit(credit-id)` - Verify credit authenticity (admin only)
- `transfer-credit(credit-id, recipient)` - Transfer credit to another user
- `retire-credit(credit-id)` - Permanently retire a credit (burn NFT)
- `batch-retire-credits(credit-ids)` - Retire multiple credits at once

### Oracle Management Functions
- `authorize-oracle(oracle, data-source)` - Authorize a new environmental data oracle
- `revoke-oracle(oracle)` - Revoke oracle authorization
- `enable-project-oracle(project-id, data-source)` - Enable oracle data for a project
- `submit-environmental-data(project-id, carbon-offset, data-source)` - Submit sensor/oracle data
- `process-environmental-data(data-id, recipient)` - Process oracle data and generate credits

### NFT Marketplace Functions
- `list-for-sale(nft-id, price)` - List an NFT for sale
- `unlist-from-sale(nft-id)` - Remove NFT from marketplace
- `buy-listed-nft(nft-id)` - Purchase a listed NFT

## Oracle Integration Architecture

### Data Flow
1. **IoT Sensors/Environmental Monitors** collect real-time data (CO2 absorption, renewable energy generation, etc.)
2. **Authorized Oracles** validate and submit data to the blockchain
3. **Smart Contract** processes data against predefined thresholds
4. **Automated Credit Generation** creates verified NFT credits for qualifying projects
5. **Real-time Updates** to project totals and user balances

### Supported Data Sources
- **Renewable Energy Meters**: Solar, wind, hydro generation data
- **Carbon Sequestration Sensors**: Forest monitoring, soil carbon measurement
- **Emission Monitoring**: Industrial emission tracking and reduction
- **Environmental IoT**: Temperature, humidity, air quality sensors
- **Satellite Data**: Deforestation monitoring, land use changes

### Security Features
- **Oracle Authorization**: Only pre-approved oracles can submit data
- **Data Freshness**: Automatic rejection of outdated sensor readings
- **Threshold Validation**: Minimum carbon offset requirements prevent spam
- **Source Validation**: Data sources must match project configurations
- **Immutable Audit Trail**: All oracle submissions permanently recorded

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing
- Understanding of SIP-009 NFT standard
- Oracle/IoT sensor integration setup

### Installation
1. Clone the repository
2. Run `clarinet check` to verify contract syntax
3. Run `clarinet test` to execute test suite
4. Deploy to testnet using `clarinet deploy`

### Usage Example
```clarity
;; Register a new project with oracle support
(contract-call? .greentrack register-project "Solar Farm Project" "California, USA" "renewable-energy")

;; Enable oracle data for the project
(contract-call? .greentrack enable-project-oracle u1 "solar-meter-sensor-001")

;; Authorize an environmental data oracle
(contract-call? .greentrack authorize-oracle 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE "solar-meter-sensor-001")

;; Oracle submits environmental data (automated by IoT sensors)
(contract-call? .greentrack submit-environmental-data u1 u1500 "solar-meter-sensor-001")

;; Process oracle data and generate credits automatically
(contract-call? .greentrack process-environmental-data u1 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK)

;; Issue manual carbon credits as NFTs
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

## Oracle Configuration

### Setting Up IoT Integration
1. **Register Environmental Project** with location and type
2. **Configure Data Source** identifier for sensors/oracles
3. **Authorize Oracle Addresses** that can submit data
4. **Set Minimum Thresholds** for automatic credit generation
5. **Enable Real-time Processing** for continuous monitoring

### Data Validation Rules
- **Freshness Check**: Data must be submitted within 24 hours (144 blocks)
- **Threshold Validation**: Minimum 100 units of carbon offset required
- **Source Matching**: Data source must match project configuration
- **Oracle Authorization**: Only authorized principals can submit data
- **Duplicate Prevention**: Each data submission is uniquely identified

## NFT Metadata

Each carbon credit NFT includes rich metadata accessible via the `get-token-uri` function:
- Credit amount and type
- Project information
- Verification status
- Creation timestamp
- Environmental impact data
- **Oracle Information**: Data source, sensor ID, generation method
- **Automation Status**: Whether credit was oracle-generated or manual

Metadata format: `https://greentrack.io/api/metadata/{token-id}`

## Project Structure
```
greentrack/
├── contracts/
│   └── greentrack.clar
├── tests/
│   └── greentrack_test.ts
├── oracle-integration/
│   ├── iot-connector.js
│   └── data-validator.js
├── metadata/
│   └── token_metadata.json
├── Clarinet.toml
└── README.md
```

## Real-World Impact

GreenTrack with Oracle Integration addresses critical issues in the carbon credit market:
- **Transparency**: All transactions are publicly verifiable on blockchain
- **Automation**: Real-time credit generation from verified environmental data
- **Double Counting Prevention**: Credits can only be retired once through NFT burning
- **Fraud Reduction**: Verification system and oracle validation prevent fake credits
- **Enhanced Liquidity**: NFT standard enables integration with existing marketplaces
- **Data Integrity**: IoT sensor integration ensures accurate environmental measurements
- **Ownership Clarity**: Clear ownership through blockchain-native standards
- **Interoperability**: Compatible with existing NFT infrastructure and wallets
- **Scalability**: Automated processing reduces manual verification overhead
- **Accessibility**: Enables smaller projects to participate through IoT monitoring
- **Trust**: Blockchain immutability ensures data integrity
- **Real-time Tracking**: Continuous monitoring of environmental impact

## Oracle Benefits

### For Project Developers
- **Automated Credit Generation**: Continuous creation based on real performance
- **Reduced Administrative Overhead**: Less manual reporting and verification
- **Real-time Validation**: Immediate feedback on environmental impact
- **Data Transparency**: Public visibility of all sensor data and calculations

### For Credit Buyers
- **Verified Performance**: Credits backed by real sensor data
- **Real-time Tracking**: Monitor project performance continuously
- **Enhanced Trust**: Automated validation reduces human error and fraud
- **Detailed Provenance**: Complete audit trail from sensor to credit

### For Oracles/IoT Providers
- **Revenue Opportunities**: Earn fees for providing validated environmental data
- **Standardized Integration**: Simple API for data submission
- **Reputation System**: Build trust through consistent, accurate data delivery
- **Scalable Architecture**: Support multiple projects and data types

## Technical Specifications

- **Blockchain**: Stacks
- **Standard**: SIP-009 NFT Trait
- **Language**: Clarity
- **Collection Name**: "GreenTrack Carbon Credits"
- **Symbol**: "GTCC"
- **Oracle Data Freshness**: 24 hours (144 blocks)
- **Minimum Carbon Threshold**: 100 units
- **Supported Data Sources**: IoT sensors, satellite data, environmental monitors

## Supported Oracle Types

### Environmental IoT Sensors
- Solar irradiance and energy generation meters
- Wind speed and turbine output sensors
- Hydroelectric flow and generation monitors
- Carbon sequestration measurement devices
- Soil carbon content analyzers
- Forest biomass monitoring systems

### Satellite and Remote Sensing
- Deforestation detection systems
- Land use change monitoring
- Vegetation health indices
- Carbon sink capacity assessments

### Industrial Monitoring
- Emission reduction verification systems
- Energy efficiency monitors
- Waste reduction tracking sensors
- Industrial process optimization data

## Security Considerations

- **Oracle Authorization**: Multi-signature approval for oracle registration
- **Data Source Validation**: Cryptographic verification of sensor data
- **Threshold Management**: Dynamic adjustment of minimum requirements
- **Rate Limiting**: Prevention of data spam and manipulation
- **Audit Trail**: Complete history of all oracle interactions
- **Emergency Controls**: Admin override capabilities for security incidents

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure NFT standard compliance
6. Test oracle integration endpoints
7. Submit a pull request
