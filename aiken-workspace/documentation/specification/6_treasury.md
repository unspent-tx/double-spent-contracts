# Specification - Spend - Treasury

## Parameter

| Field        | Type     | Description                |
| ------------ | -------- | -------------------------- |
| `oracle_nft` | PolicyId | The policy id of OracleNFT |
| `nft_policy` | PolicyId | The policy id of DSNFT     |

## Redeemer

| Action                 | Description                  |
| ---------------------- | ---------------------------- |
| `Withdraw{asset_name}` | Withdraw funds for burnt NFT |

## User Actions

| Action | Description                                                              |
| ------ | ------------------------------------------------------------------------ |
| Spend  | When redeemer is `Withdraw{asset_name}`                                  |
|        | When 1 reference input with `oracle_nft` with `OracleDatum` is present   |
|        | When `asset_name` converts to an integer from utf8                       |
|        | When `asset_name` is only burnt token from `nft_policy`                  |
|        | When `asset_name` from utf8 is less than `count` divided by `divisor`    |
|        | When `divisor` is equal to length of inputs being spent from own address |
