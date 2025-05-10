# Specification - Spend - Oracle

## Datum

| Field              | Type      | Description                                                    | Changes |
| ------------------ | --------- | -------------------------------------------------------------- | ------- |
| `count`            | Int       | The number of NFTs minted in a collection.                     | Yes     |
| `treasury_address` | Address   | The script address to collect fees and payout NFT burning.     | No      |
| `pot_address`      | Address   | The script address to collect fees and payout last minter.     | No      |
| `fee_address`      | Address   | The wallet address to pay developer.                           | No      |
| `winner`           | ByteArray | The public key hash of the last minter.                        | Yes     |
| `treasury_price`   | Int       | The lovelace going to the treasury during a mint.              | No      |
| `pot_price`        | Int       | The lovelace going to the pot during a mint.                   | No      |
| `fee_price`        | Int       | The lovelace going to the developer during a mint.             | No      |
| `slot_start`       | Int       | The slot of oracle deployment plus offset used to start timer. | No      |
| `slot_increase`    | Int       | The amount of slots to increase timer for each mint.           | No      |
| `divisor`          | Int       | The divisor for the burn threshold and the unlockable value.   | No      |

## Redeemer

| Action      | Parameters | Type      | Description                                   |
| ----------- | ---------- | --------- | --------------------------------------------- |
| `MintDsNFT` | `winner`   | ByteArray | Public key hash of the current NFT purchaser. |

## User Actions

| Action | Description                                                    |
| ------ | -------------------------------------------------------------- |
| Spend  | When own input with `oracle_nft` with `OracleDatum` is present |
|        | When redeemer is `MintDsNFT{winner}`                           |
|        | When 1 input with `oracle_nft` is spent                        |
|        | When 1 output with `oracle_nft` is sent to own address         |
|        | When output `oracle_nft` has only value of 1 nft and lovelace  |
|        | When output datum `count` is updated with `count + 1`          |
|        | When output datum `winner` is updated with redeemer's `winner` |
|        | When all other output datum remains the same                   |
|        | When `treasury_price` is paid to `treasury_address` address    |
|        | When `pot_price` is paid to `pot_address` address              |
|        | When `fee_price` is paid to `fee_address` address              |
