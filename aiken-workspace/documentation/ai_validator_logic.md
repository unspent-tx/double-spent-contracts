# Validator Logic and Interactions

## 1.1 Contract Description

There are in total 5 scripts for the MVP game to work. Below provide description and pointers to a more detailed specs.

**OracleNFT** - specification
The one time minting policy, minting the NFT to be reference token locking in OracleValidator. It is used for serving static app information.

**Oracle** - specification
The validator locking OracleNFT, for serving app information such as game state, winner information, and protecting information integrity.

**PlutusNFT** - specification
The minting policy of the actual NFT collection, enforcing correct naming and minting conditions.

**Treasury** - specification
The validator managing treasury withdrawals, enforcing NFT value thresholds and burning requirements.

**Pot** - specification
The validator managing pot withdrawals, enforcing time-based and winner-based restrictions.

## 1.2 Param Dependency Tree

### First layer

- utxo_ref in oracle_nft

### Second layer

- oracle_nft in plutus_nft
- oracle_nft in treasury
- oracle_nft in pot

### Third layer

- plutus_nft in treasury

## 1.3 Minting Policy Specification

### OracleNFT - specification

**Parameter**

- utxo_ref: UTxO to be spent at minting

**User Action**

- Mint - Redeemer RMint
  - Transaction hash as parameterized is included in input
- Burn - Redeemer RBurn
  - The current policy id only has negative minting value in transaction body

### PlutusNFT - specification

**Parameter**

- oracle_nft: The policy id of OracleNFT

**User Action**

- Mint - Redeemer RMint
  - There is 1 input with oracle_nft
  - There is exactly 1 token minted from current transaction
  - Token name matches the current count from oracle
- Burn - Redeemer RBurn
  - The current policy id only has negative minting value in transaction body

## 1.4 Spending Validator Specification

### Oracle - specification

**Parameter**

- None (uses oracle_nft for reference)

**Datum**

```aiken
OracleDatum {
  count: Int,
  treasury_address: Address,
  pot_address: Address,
  fee_address: Address,
  winner: ByteArray,
  lock_price: Int,
  pot_price: Int,
  fee_price: Int,
  start_slot: Int,
  slot_increase: Int
}
```

**User Action**

- Mint Plutus NFT - Redeemer MintPlutusNFT
  - Only 1 input from and output to current address
  - Output datum has updated count (+1) and new winner
  - Output value equals input value
  - Fee is paid to fee collector address
  - Treasury payment is made
  - Pot payment is made
- Stop Oracle - Redeemer StopOracle
  - Currently disabled (returns False)

### Treasury - specification

**Parameter**

- oracle_nft: The policy id of OracleNFT
- nft_policy: The policy id of PlutusNFT

**User Action**

- Withdraw - Redeemer Withdraw
  - Exactly one oracle reference input
  - NFT value is below threshold (count/2)
  - NFT is burned
  - Exactly two inputs from script address

### Pot - specification

**Parameter**

- oracle_nft: The policy id of OracleNFT

**User Action**

- Withdraw - Redeemer Withdraw
  - Exactly one oracle reference input
  - Transaction is after game end time
  - Winner is signed
  - Winner matches oracle datum

## 1.5 User Actions Documentation

### Normal Users

1. Mint NFT
   - Validation: 1.3, 1.4
2. Withdraw from Treasury
   - Validation: 1.4
3. Withdraw from Pot
   - Validation: 1.4

### Admin

1. Stop Game
   - Validation: 1.4 (StopOracle)

## 1.6 Application Setup Documentation

### Setup

There are 3 steps to setting up the application:

1. Mint oracle_nft

   - One time minting policy with empty token name
   - Quantity of 1
   - Validation: 1.3

2. Initialize Oracle

   - Send oracle_nft to oracle
   - Set initial count to 0
   - Configure addresses and prices
   - Set start_slot and slot_increase
   - Validation: N/A

3. Deploy Other Validators
   - Deploy treasury with oracle_nft and nft_policy
   - Deploy pot with oracle_nft
   - Validation: N/A

## Overview

This document describes the logic and interactions between five validators in the system:

1. Oracle Validator (`oracle.ak`)
2. Pot Validator (`pot.ak`)
3. Treasury Validator (`treasury.ak`)
4. Plutus NFT Validator (`plutus_nft.ak`)
5. Oracle NFT Validator (`oracle_nft.ak`)

## Individual Validator Logic

### 1. Oracle Validator

**Purpose**: Manages the game state and NFT minting process

**Data Types**:

```aiken
OracleDatum {
  count: Int,
  treasury_address: Address,
  pot_address: Address,
  fee_address: Address,
  winner: ByteArray,
  lock_price: Int,
  pot_price: Int,
  fee_price: Int,
  start_slot: Int,
  slot_increase: Int
}

OracleRedeemer {
  MintPlutusNFT { winner: ByteArray }
  StopOracle // will be removed
}
```

**Checks**:

- Validates oracle NFT presence
- Ensures clean output value
- Verifies count update
- Validates fee payment
- Validates treasury payment
- Validates pot payment

### 2. Pot Validator

**Purpose**: Manages the pot withdrawal process

**Data Types**:

```aiken
PotRedeemer {
  Withdraw { pub_key_hash: ByteArray }
}
```

**Checks**:

- Validates oracle reference input
- Verifies oracle datum
- Checks game end time
- Validates winner signature
- Verifies winner identity

### 3. Treasury Validator

**Purpose**: Manages treasury withdrawals

**Data Types**:

```aiken
TreasuryRedeemer {
  Withdraw { asset_name: ByteArray }
}
```

**Checks**:

- Validates oracle reference input
- Verifies oracle datum
- Checks NFT value against threshold
- Validates NFT burning
- Ensures exactly two inputs from script
- Validates NFT name format

### 4. Plutus NFT Validator

**Purpose**: Controls NFT minting and burning

**Data Types**:

```aiken
MintPolarity {
  RMint
  RBurn
}
```

**Checks**:

- For minting:
  - Validates oracle input
  - Verifies oracle datum
  - Ensures correct asset name
  - Validates single mint
- For burning:
  - Ensures only burning occurs

### 5. Oracle NFT Validator

**Purpose**: Controls oracle NFT minting and burning

**Data Types**:

```aiken
MintPolarity {
  RMint
  RBurn
}
```

**Checks**:

- For minting:
  - Validates UTxO reference
- For burning:
  - Ensures only burning occurs

## User Actions and Validator Interactions

### 1. Mint Plutus NFT

**Validators Involved**:

- Oracle Validator
- Plutus NFT Validator
- Oracle NFT Validator

**Flow**:

1. User initiates mint
2. Oracle NFT Validator checks UTxO reference
3. Plutus NFT Validator:
   - Validates oracle input
   - Generates correct asset name
   - Ensures single mint
4. Oracle Validator:
   - Updates count
   - Validates payments (fee, treasury, pot)
   - Updates winner

### 2. Withdraw from Pot

**Validators Involved**:

- Pot Validator
- Oracle Validator

**Flow**:

1. User initiates withdrawal
2. Pot Validator:
   - Checks oracle reference
   - Validates game end time
   - Verifies winner identity
   - Checks winner signature
3. Oracle Validator provides game state

### 3. Withdraw from Treasury

**Validators Involved**:

- Treasury Validator
- Oracle Validator
- Plutus NFT Validator

**Flow**:

1. User initiates withdrawal
2. Treasury Validator:
   - Checks oracle reference
   - Validates NFT value against threshold
   - Ensures NFT burning
   - Verifies input count
3. Plutus NFT Validator:
   - Validates NFT burning
4. Oracle Validator provides game state

### 4. Burn NFT

**Validators Involved**:

- Plutus NFT Validator
- Oracle NFT Validator

**Flow**:

1. User initiates burn
2. Validator checks:
   - Only burning occurs
   - No mixed mint/burn
   - Correct policy ID

## Security Considerations

### Oracle Validator

- Prevents unauthorized state changes
- Ensures correct payment distribution
- Validates NFT minting conditions

### Pot Validator

- Enforces time-based withdrawals
- Prevents unauthorized withdrawals
- Ensures winner verification

### Treasury Validator

- Enforces NFT value thresholds
- Prevents unauthorized withdrawals
- Ensures NFT burning

### Plutus NFT Validator

- Controls NFT minting
- Ensures correct asset naming
- Prevents unauthorized burns

### Oracle NFT Validator

- Controls oracle NFT lifecycle
- Prevents unauthorized minting
- Ensures proper burning

## Edge Cases and Error Handling

### Oracle Validator

- Handles invalid payments
- Manages state updates
- Validates output cleanliness

### Pot Validator

- Handles missing oracle references
- Manages time-based restrictions
- Validates winner signatures

### Treasury Validator

- Handles invalid NFT values
- Manages input count requirements
- Validates threshold conditions

### Plutus NFT Validator

- Handles incorrect asset names
- Manages mint/burn operations
- Validates oracle state

### Oracle NFT Validator

- Handles missing UTxO references
- Manages mint/burn operations
- Validates policy ID
