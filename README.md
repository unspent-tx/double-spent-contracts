# Double Spent

<img src="https://www.unspenttx.com/logo.png" alt="Double Spent Logo" width="200"/>

## Chasing 49% of infinity.

Participation is encouraged both early and late in lifecycle. The first % to mint can burn for profit ADA, while the last to mint is enticed with a growing pot of ADA locked behind a timer.

Using a series of Aiken smart contracts for managing treasury, marketplace, oracle, NFT minting and burning operations on the Cardano blockchain, this protocol is simple, automatic, deterministic, transparent, and censorship resistant.

Created by [@unspent-tx](https://github.com/unspent-tx)

## Overview

| Name                                                                                 | Description                                                                                   |
| ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| [🎮 User Actions](aiken-workspace/documentation/user-actions.md)                     | Overview of how multiple contracts are used together. Quickly scan complete validation logic. |
| [🕸️ Parameter Dependencies](aiken-workspace/documentation/param-dependency-graph.md) | Visual representation of how contract parameters depend on each other across the waterfall.   |

## Validators

| Name                                                         |                                                                      | Description                                                                                                                               |
| ------------------------------------------------------------ | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| [🖲️ Oracle NFT](aiken-workspace/validators/oracle_nft.ak)    | [⚙️ ](aiken-workspace/documentation/specification/1_oracle_nft.md)   | One-time minting policy creating a state thread token for game state.                                                                     |
| [🖲️ Oracle](aiken-workspace/validators/oracle.ak)            | [⚙️ ](aiken-workspace/documentation/specification/2_oracle.md)       | Manages game state and DS minting logic. Collection count increments, where fees get distributed to, how much things cost or unlock, etc. |
| [🫀 DS NFT](aiken-workspace/validators/ds_nft.ak)            | [⚙️ ](aiken-workspace/documentation/specification/3_ds_nft.md)       | Minting policy for numbered NFTs using collection count as asset name.                                                                    |
| [🪺 Pot Spend](aiken-workspace/validators/pot_spend.ak)       | [⚙️ ](aiken-workspace/documentation/specification/4_pot_spend.md)    | Locks utxos for winner after timer.                                                                                                       |
| [🪺 Pot Withdraw](aiken-workspace/validators/pot_withdraw.ak) | [⚙️ ](aiken-workspace/documentation/specification/5_pot_withdraw.md) | Enforces winner payout rules.                                                                                                             |
| [💰 Treasury](aiken-workspace/validators/treasury.ak)        | [⚙️ ](aiken-workspace/documentation/specification/6_treasury.md)     | Locks utxos for DS burns.                                                                                                                 |
| [🔀 Marketplace](aiken-workspace/validators/marketplace.ak)  | [⚙️ ](aiken-workspace/documentation/specification/7_marketplace.md)  | Facilitates peer-to-peer DS trading.                                                                                                      |

<!-- 🪺 🪤 🫀 🔀 -->

## Run Tests

```bash
cd aiken-workspace

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

This project is licensed under the AGPL-3.0 License - see the [LICENSE.txt](LICENSE.txt) file for details.
