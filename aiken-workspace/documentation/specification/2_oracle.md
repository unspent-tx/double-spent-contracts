# Specification - Spend - Oracle

## Parameter

## Datum

- `count`: **updates** The number of NFTs minted in a collection.
- `treasury_address`: _static_ The script address to collect fees and payout NFT burning.
- `pot_address`: _static_ The script address to collect fees and payout last minter.
- `fee_address`: _static_ The wallet address to pay developer.
- `winner`: **updates** The public key hash of the last minter.
- `lock_price`: _static_ The lovelace going to the treasury during a mint.
- `pot_price`: _static_ The lovelace going to the pot during a mint.
- `fee_price`: _static_ The lovelace going to the developer during a mint.
- `start_slot`: _static_ The slot of oracle deployment plus offset used to start timer.
- `slot_increase`: _static_ The amount of slots to increase timer for each mint.

## User Action

1. Mint Plutus NFT - Redeemer `MintPlutusNFT`

   - Only 1 input from and output to own address
   - The output datum is updated `count` of +1, and the output value = input value
     - The winner is also updated but without validation.
   - The current address output value doesn't contain other irrelevant tokens
   - Fee is paid to fee collector address
   - Fee is paid to treasury script address
   - Fee is paid to pot script address
