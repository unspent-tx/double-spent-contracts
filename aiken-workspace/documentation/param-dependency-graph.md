# Param Dependency Graph

## DApp Parameters

| First Layer               | Second Layer                  | Third Layer                  |
| ------------------------- | ----------------------------- | ---------------------------- |
| `utxo_ref` → `oracle_nft` | `oracle_nft` → `ds_nft`       | `ds_nft` → `treasury`        |
|                           | `oracle_nft` → `pot_withdraw` | `pot_withdraw` → `pot_spend` |
|                           | `oracle_nft` → `treasury`     |                              |

## Marketplace Parameters

| First Layer                                  |
| -------------------------------------------- |
| `owner` → `marketplace`                      |
| `fee_percentage_basis_point` → `marketplace` |
