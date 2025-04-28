# Double-Spent

A collection of Aiken smart contracts for managing treasury, marketplace, and oracle operations on the Cardano blockchain.

Created by [@unspent-tx](https://github.com/unspent-tx)

## Overview

This project contains a suite of smart contracts written in Aiken for the Cardano blockchain. The contracts are designed to handle various operations including treasury management, marketplace functionality, and oracle services.

## Project Structure

```
aiken-workspace/
├── documentation/   # Project documentation
├── validators/      # Smart contract validators
├── lib/             # Shared library code
├── aiken.toml       # Project configuration
└── aiken.lock       # Dependency lock file
```

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

## Overview

| Name                       | Documentation                     |
| -------------------------- | --------------------------------- |
| Contracts Description      | [Link](contracts-description.md)  |
| Parameter Dependency Graph | [Link](param-dependency-graph.md) |
| User Actions               | [Link](user-actions.md)           |
| Setup Procedure            | [Link](setup-procedure.md)        |

## Dependencies

- Aiken Language: v1.1.13
- Plutus: v3
- Aiken Standard Library: v2.2.0
- Vodka: v0.1.11
- Aiken Fuzz: v2.1.0

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE.txt](LICENSE.txt) file for details.
