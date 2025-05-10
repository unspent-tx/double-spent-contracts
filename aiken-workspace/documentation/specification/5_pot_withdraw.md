# Withdraw - [Pot Withdraw 🪺](../../validators/pot_withdraw.ak)

## Parameter

| Field        | Type     | Description                |
| ------------ | -------- | -------------------------- |
| `oracle_nft` | PolicyId | The policy id of OracleNFT |

## Redeemer

| Action     | Description        |
| ---------- | ------------------ |
| `Withdraw` | Withdraw pot funds |

## User Actions

| Action   | Description                                                          |
| -------- | -------------------------------------------------------------------- |
| Withdraw | When redeemer is `Withdraw`                                          |
|          | When 1 input with `oracle_nft` with `OracleDatum` is present         |
|          | When `winner` is signing the transaction                             |
|          | When transaction is valid after `slot_start + count * slot_increase` |
