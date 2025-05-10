# User Interactions

### Normal users can

### 1. Mint NFT

| Action | [Oracle](aiken-workspace/documentation/specification/2_oracle.md) | Action | [DS NFT](aiken-workspace/documentation/specification/3_ds_nft.md) |
| ------ | ----------------------------------------------------------------- | ------ | ----------------------------------------------------------------- |
| Spend  | When own input with `oracle_nft` with `OracleDatum` is present    | Mint   | When redeemer is `RMint`                                          |
|        | When redeemer is `MintDsNFT{winner}`                              |        | When 1 input with `oracle_nft` with `OracleDatum` is present      |
|        | When 1 input with `oracle_nft` is spent                           |        | When 1 token is minted with token name `${count}`                 |
|        | When 1 output with `oracle_nft` is sent to own address            |        |                                                                   |
|        | When output `oracle_nft` has only value of 1 nft and lovelace     |        |                                                                   |
|        | When output datum `count` is updated with `count + 1`             |        |                                                                   |
|        | When output datum `winner` is updated with redeemer's `winner`    |        |                                                                   |
|        | When all other output datum remains the same                      |        |                                                                   |
|        | When `treasury_price` is paid to `treasury_address` address       |        |                                                                   |
|        | When `pot_price` is paid to `pot_address` address                 |        |                                                                   |
|        | When `fee_price` is paid to `fee_address` address                 |        |                                                                   |

---

### 2. Burn NFT

| Action | [Treasury](aiken-workspace/documentation/specification/6_treasury.md)    | Action | [DS NFT ](aiken-workspace/documentation/specification/3_ds_nft.md) |
| ------ | ------------------------------------------------------------------------ | ------ | ------------------------------------------------------------------ |
| Spend  | When redeemer is `Withdraw{asset_name}`                                  | Burn   | When redeemer is `RBurn`                                           |
|        | When 1 reference input with `oracle_nft` with `OracleDatum` is present   |        | When policy id has negative minting value in transaction body      |
|        | When `asset_name` converts to an integer from utf8                       |
|        | When `asset_name` is only burnt token from `nft_policy`                  |
|        | When `asset_name` from utf8 is less than `count` divided by `divisor`    |
|        | When `divisor` is equal to length of inputs being spent from own address |

---

### 3. Withdraw from Pot

| Action   | [Pot Withdraw ](aiken-workspace/documentation/specification/6_pot_withdraw.md) | Action | [Pot Spend](aiken-workspace/documentation/specification/4_pot_spend.md) |
| -------- | ------------------------------------------------------------------------------ | ------ | ----------------------------------------------------------------------- |
| Withdraw | When redeemer is `Withdraw`                                                    | Spend  | When redeemer is `Withdraw`                                             |
|          | When 1 input with `oracle_nft` with `OracleDatum` is present                   |        | When withdraw of zero from `withdraw_script_hash`                       |
|          | When `winner` is signing the transaction                                       |
|          | When transaction is valid after `slot_start + count * slot_increase`           |

---

### 4. Buy on Marketplace

| Action | [Marketplace](aiken-workspace/documentation/specification/7_marketplace.md) |
| ------ | --------------------------------------------------------------------------- |
| Spend  | When there is some datum                                                    |
|        | When redeemer is `Buy`                                                      |
|        | When 1 input from the marketplace script is present                         |
|        | When `seller` receives price + input value                                  |
|        | When `owner` receives fee (`price` \* `fee_percentage_basis_point` / 10000) |

### 5. Cancel Listing on Marketplace

| Action | [Marketplace](aiken-workspace/documentation/specification/7_marketplace.md) |
| ------ | --------------------------------------------------------------------------- |
| Spend  | When there is some datum                                                    |
|        | When redeemer is `Close`                                                    |
|        | When transaction is signed by the `seller`                                  |

---

### Admin Users Only Setup

### 1. Mint Oracle NFT

| Action | Description                                            |
| ------ | ------------------------------------------------------ |
| Mint   | When redeemer is `RMint`                               |
|        | When parameter `utxo_ref` hash is an input being spent |

---
