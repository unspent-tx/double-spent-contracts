# Specification - Spend - Marketplace

## Parameter

- `owner`: The Dev Address to collect fees
- `fee_percentage_basis_point`: The basis point fee to charge for each sale

## User Action

1. Spend - Redeemer `Buy`

   - There is 1 input from its own address
   - There datum `price` fee is paid to the datum `seller`
   - The dev fee is paid to the `owner`

## Close

1. Spend - Redeemer `Close`

   - Signed by the datum `seller`
