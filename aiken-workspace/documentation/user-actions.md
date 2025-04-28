# User Actions Documentation

## Normal Users

1. Mint NFT from the collection of `plutus-nft`

   - Validation: 2.1, 3.1
     - 2.1 Mint Plutus NFT - Redeemer `MintPlutusNFT`
       - Only 1 input from and output to own address
       - The output datum is updated `count` of +1, and the output value = input value
         - The winner is also updated but without validation.
       - The current address output value doesn't contain other irrelevant tokens
       - Fee is paid to fee collector address
       - Fee is paid to treasury script address
       - Fee is paid to pot script address
     - 3.1 Mint - Redeemer `RMint`
       - There is 1 input with `oracle_nft`
       - There is 1 token minted from current transaction, with correct token name `${count}`

2. Burn NFT from collection of `plutus_nft`. Spend from the `treasury`

   - Validation: 6.1, 3.2
     - 6.1 Spend - Redeemer ` Withdraw``{ asset_name }`
       - There is 1 reference input with `oracle_nft` with datum
       - There are 2 inputs from own_address
       - The `asset_name` converts to an int
       - The `asset_name` is being burnt from `nft_policy`
       - The `asset_name` is less than `count` divided by 2
     - 3.2 Burn - Redeemer `RBurn`
       - The current policy id only has negative minting value in transaction body

3. Spend from `pot_spend`. Withdraw from `pot_withdraw`

   - Validation: 4.1, 5.1
     - 4.1 Spend - Redeemer `Withdraw`
       - There is a withdraw of zero from `withdraw_script_hash`
     - 5.1 Withdraw - Redeemer `Withdraw`
       - There is exactly 1 input from the `oracle_nft` policy.
       - The oraclue datum is valid.
         - `OracleDatum` `count`, `start_slot`, `slot_increase`, `winner`
       - The transaction is signed by the `winner`.
       - The transaction is valid after calculated `end_of_game` slot.
         - `end_of_game` = `start_slot + count * slot_increase`

## Admin

1. Mint `OracleNFT`

   - Validation: 1.1
     - 1.1 Mint - Redeemer `RMint`
       - Transaction hash as parameterized is included in input
