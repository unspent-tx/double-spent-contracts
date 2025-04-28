# Double-Spent

A less than zero-sum game of musical chairs naively chasing theoretical legraunge points of equilibriums. Using a series of Aiken smart contracts for managing treasury, marketplace, oracle, nft minting and burning operations on the Cardano blockchain, this protocol is automatic, deterministic, transparent, and censorship resistant.

Created by [@unspent-tx](https://github.com/unspent-tx)

## Overview

The contracts are designed to encourage participation of buying NFTs by distributing costs to the community of NFT owners. Instead of small group of insiders only extracting value during a launch, here value is shuffled from later participants to the first 49% of NFT owners, while enticing the last to mint with a theorteically unobtainable but realistically claimable prize pool valued at ~4% of the protocol volume.

## Project Structure

```
aiken-workspace/
├── documentation/   # Project documentation
├── validators/      # Smart contract validators
├── lib/             # Shared library code
├── aiken.toml       # Project configuration
└── aiken.lock       # Dependency lock file
```

## Overview

| Name                       | Documentation                     |
| -------------------------- | --------------------------------- |
| Contracts Description      | [Read](contracts-description.md)  |
| Parameter Dependency Graph | [Read](param-dependency-graph.md) |
| User Actions               | [Read](user-actions.md)           |
| Setup Procedure            | [Read](setup-procedure.md)        |

## Documentation

| Contract     | Documentation                                    |
| ------------ | ------------------------------------------------ |
| Oracle NFT   | [Specification](specification/1_oracle_nft.md)   |
| Oracle       | [Specification](specification/2_oracle.md)       |
| Plutus NFT   | [Specification](specification/3_plutus_nft.md)   |
| Pot Spend    | [Specification](specification/4_pot_spend.md)    |
| Pot Withdraw | [Specification](specification/5_pot_withdraw.md) |
| Treasury     | [Specification](specification/6_treasury.md)     |
| Marketplace  | [Specification](specification/7_marketplace.md)  |

## Dependencies

- Aiken Language: v1.1.13
- Plutus: v3
- Aiken Standard Library: v2.2.0
- Vodka: v0.1.11
- Aiken Fuzz: v2.1.0

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE.txt](LICENSE.txt) file for details.
