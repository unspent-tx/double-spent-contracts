# Double Spent

<img src="https://www.unspenttx.com/logo.png" alt="Double Spent Logo" width="200"/>

## A less than zero-sum game chasing 49% of infinity.

Participation is encouraged both early and late in lifecycle. The first % to mint can burn for profit ADA, while the last to mint is enticed with a growing pot of ADA.

Using a series of Aiken smart contracts for managing treasury, marketplace, oracle, NFT minting and burning operations on the Cardano blockchain, this protocol is simple, automatic, deterministic, transparent, and censorship resistant.

Created by [@unspent-tx](https://github.com/unspent-tx)

## Overview

| Read                                                            | Name                       | Description                                                                                                                                           |
| --------------------------------------------------------------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Read](aiken-workspace/documentation/user-actions.md)           | User Actions               | Overview of how multiple contracts are used together. Quickly scan complete validation logic.                                                         |
| [Read](aiken-workspace/documentation/param-dependency-graph.md) | Parameter Dependency Graph | Visual representation of how contract parameters depend on each other across the waterfall.                                                           |
| [Read](aiken-workspace/documentation/setup-procedure.md)        | Offchain Setup Procedure   | Step-by-step guide for initializing the offchain protocol with mesh, including contract deployment, parameter configuration, and initial state setup. |

## Contracts

| Docs                                                                 | Contract     | Description                                                                                                                                                   |
| -------------------------------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Doc](aiken-workspace/documentation/specification/1_oracle_nft.md)   | Oracle NFT   | One-time minting policy creating a state thread token for game state.                                                                                         |
| [Doc](aiken-workspace/documentation/specification/2_oracle.md)       | Oracle       | Core validator that manages game state and DS minting logic. Collection count increments, where fees get distributed to, how much things cost or unlock, etc. |
| [Doc](aiken-workspace/documentation/specification/3_ds_nft.md)       | DS NFT       | Minting policy for numbered NFTs using collection count as asset name.                                                                                        |
| [Doc](aiken-workspace/documentation/specification/4_pot_spend.md)    | Pot Spend    | Locks utxos for winner and defers spend logic to Pot Withdraw.                                                                                                |
| [Doc](aiken-workspace/documentation/specification/5_pot_withdraw.md) | Pot Withdraw | Zero-withdrawal trick enforcing winner payout rules based on Oracle state and time-based calculations.                                                        |
| [Doc](aiken-workspace/documentation/specification/6_treasury.md)     | Treasury     | Locks utxos for DS burns and manages spending based on Oracle state.                                                                                          |
| [Doc](aiken-workspace/documentation/specification/7_marketplace.md)  | Marketplace  | Facilitates NFT trading with automated fee distribution and secure asset transfers between buyers and sellers.                                                |

## Run Tests

```bash
aiken check -m mint
aiken check -m burn
aiken check -m spend
aiken check -m withdraw

aiken check -m ds
aiken check -m oracle
aiken check -m treasury
aiken check -m pot

aiken check -m marketplace
```

## Dependencies

- Aiken Fuzz: v2.1.0
- Aiken Language: v1.1.13
- Aiken Standard Library: v2.2.0
- Plutus: v3
- Vodka: v0.1.11

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE.txt](aiken-workspace/LICENSE.txt) file for details.
