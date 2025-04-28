# Specification - Spend - Pot

## Parameter

- `oracle_nft`: The policy id of `OracleNFT`

## User Action

1. Spend - Redeemer `Withdraw`

   - There is exactly 1 input from the `oracle_nft` policy.
   - The oraclue datum is valid.
     - `OracleDatum` `count`, `start_slot`, `slot_increase`, `winner`
   - The transaction is signed by the `winner`.
   - The transaction is valid after calculated `end_of_game` slot.
     - `end_of_game` = `start_slot + count * slot_increase`
