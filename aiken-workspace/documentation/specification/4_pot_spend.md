# Specification - Spend - Pot

## Parameter

| Field                  | Type       | Description                    |
| ---------------------- | ---------- | ------------------------------ |
| `withdraw_script_hash` | ScriptHash | The script hash of PotWithdraw |

## Redeemer

| Action     | Description        |
| ---------- | ------------------ |
| `Withdraw` | Withdraw pot funds |

## User Actions

| Action | Description                                       |
| ------ | ------------------------------------------------- |
| Spend  | When redeemer is `Withdraw`                       |
|        | When withdraw of zero from `withdraw_script_hash` |
