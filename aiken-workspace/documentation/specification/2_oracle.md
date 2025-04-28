# Specification - Spend - Oracle

## Parameter

## Datum

- **updates** `count`: The number of NFTs minted in a collection.
- _static_ `treasury_address`: The script address to collect fees and payout NFT burning.
- _static_ `pot_address`: The script address to collect fees and payout last minter.
- _static_ `fee_address`: The wallet address to pay developer.
- **updates** `winner`: The public key hash of the last minter.
- _static_ `lock_price`: The lovelace going to the treasury during a mint.
- _static_ `pot_price`: The lovelace going to the pot during a mint.
- _static_ `fee_price`: The lovelace going to the developer during a mint.
- _static_ `start_slot`: The slot of oracle deployment plus offset used to start timer.
- _static_ `slot_increase`: The amount of slots to increase timer for each mint.

## User Action

1. Mint Plutus NFT - Redeemer `MintPlutusNFT`

   - Only 1 input from and output to own address
   - The output datum is updated `count` of +1, and the output value = input value
     - The winner is also updated but without validation.
   - The current address output value doesn't contain other irrelevant tokens
   - Fee is paid to fee collector address
   - Fee is paid to treasury script address
   - Fee is paid to pot script address
