# Specification - Spend - Marketplace

## Parameter

| Field                        | Type    | Description                                     |
| ---------------------------- | ------- | ----------------------------------------------- |
| `owner`                      | Address | The address that receives marketplace fees      |
| `fee_percentage_basis_point` | Int     | Fee percentage in basis points (e.g., 100 = 1%) |

## Datum

| Field       | Type      | Description                          | Changes |
| ----------- | --------- | ------------------------------------ | ------- |
| `seller`    | Address   | The address of the NFT seller        | No      |
| `price`     | Int       | The price in lovelace for the NFT    | No      |
| `policy`    | ByteArray | The policy ID of the NFT being sold  | No      |
| `tokenName` | ByteArray | The token name of the NFT being sold | No      |

## Redeemer

| Action  | Description                     |
| ------- | ------------------------------- |
| `Buy`   | Purchase the listed NFT         |
| `Close` | Remove the NFT from marketplace |

## User Actions

| Action | Description                                                                 |
| ------ | --------------------------------------------------------------------------- |
| Spend  | When there is some datum                                                    |
|        | When redeemer is `Buy`                                                      |
|        | When 1 input from the marketplace script is present                         |
|        | When `seller` receives `price` + input value                                |
|        | When `owner` receives fee (`price` \* `fee_percentage_basis_point` / 10000) |
| Spend  | When there is some datum                                                    |
|        | When redeemer is `Close`                                                    |
|        | When transaction is signed by the `seller`                                  |
