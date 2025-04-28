# List of Smart Contracts - Double Spent

1. OracleNFT - [specification](./specification/1_oracle_nft.md)

   - The one time minting policy, minting the NFT to be reference token locking in `OracleValidator`. It is used for serving static app information.

2. Oracle - [specification](./specification/2_oracle.md)

   - The validator locking `OracleNFT`, for serving app information such as fee collecting information, collection count, and protecting information integrity.

3. PlutusNFT - [specification](./specification/3_plutus_nft.md)

   - The minting policy of the actual NFT collection.

4. PotSpend - [specification](./specification/4_pot_spend.md)

   - The validator locking funds and paying out `winner`.

5. PotWithdraw - [specification](./specification/5_pot_withdraw.md)

   - The withdraw zero trick for validating `PotSpend` logic.

6. Treasury - [specification](./specification/6_treasury.md)

   - The validator locking funds and paying out NFT burn
