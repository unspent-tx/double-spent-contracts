# Specification - Mint - PlutusNFT

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`

## User Action

1. Mint - Redeemer `RMint`

   - There is 1 input with `oracle_nft`
   - There is 1 token minted from current transaction, with correct token name `${count}`

2. Burn - Redeemer `RBurn`

   - The current policy id only has negative minting value in transaction body.
