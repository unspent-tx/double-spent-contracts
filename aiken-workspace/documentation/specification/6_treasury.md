# Specification - Spend - Treasury

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`
- `nft_policy`: The policy id of `PlutusNFT`

## User Action

1. Spend - Redeemer ` Withdraw``{ asset_name } `

   - There is 1 reference input with `oracle_nft` with datum
   - There are 2 inputs from own_address.
   - The `asset_name` converts to an int
   - The `asset_name` is being burnt from `nft_policy`
   - The `asset_name` is less than `count` divided by 2.
