# Param Dependency Graph - Example

1. First layer

   - `utxo_ref` in `oracle_nft`

2. Second layer

   - `oracle_nft` in `plutus_nft`
   - `oracle_nft` in `pot_withdraw`
   - `oracle_nft` in `treasury`

3. Third layer

   - `plutus_nft` in `treasury`
   - `pot_withdraw` in `pot_spend`
