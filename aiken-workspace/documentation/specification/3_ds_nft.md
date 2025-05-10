# Mint - [DSNFT 🫀](aiken-workspace/validators/ds_nft.ak)

## Parameter

| Field        | Type     | Description                |
| ------------ | -------- | -------------------------- |
| `oracle_nft` | PolicyId | The policy id of OracleNFT |

## Redeemer

| Action  | Description      |
| ------- | ---------------- |
| `RMint` | Mint a new DSNFT |
| `RBurn` | Burn a DSNFT     |

## User Actions

| Action | Description                                                   |
| ------ | ------------------------------------------------------------- |
| Mint   | When redeemer is `RMint`                                      |
|        | When 1 input with `oracle_nft` with `OracleDatum` is present  |
|        | When 1 token is minted with token name `${count}`             |
| Burn   | When redeemer is `RBurn`                                      |
|        | When policy id has negative minting value in transaction body |
