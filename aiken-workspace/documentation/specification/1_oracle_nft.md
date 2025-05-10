# Specification - Mint - OracleNFT

## Parameter

| Field      | Type            | Description                 |
| ---------- | --------------- | --------------------------- |
| `utxo_ref` | OutputReference | UTxO to be spent at minting |

## Redeemer

| Action  |
| ------- |
| `RMint` |

## User Action

| Action | Description                                            |
| ------ | ------------------------------------------------------ |
| Mint   | When redeemer is `RMint`                               |
|        | When parameter `utxo_ref` hash is an input being spent |
