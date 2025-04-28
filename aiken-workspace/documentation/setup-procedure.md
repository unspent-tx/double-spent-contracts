# Setup Procedure

## Prerequisites

- Firebase: Realtime Database, Firestore, Service Worker (admin), Functions
- Blockfrost API Key
- Next.js

## Start Game

Run Aiken Build

1. In [`game-config.ts`](../../utils/game-config.ts)

   - Turn `startNewGame` to `true` // Fresh oracle
   - Turn `startNewAddressBook` to `true` // Fresh Blockfrost cache layer

2. Visit url [`http://localhost:3000/double-spent`](http://localhost:3000/double-spent)

   - Click `start game` to copy `paramUtxo`
   - This will copy the utxo to clipboard (🕹️)
   - Paste and save `paramUtxo` into `game-config.ts`
   - Decline Transaction

3. Refresh url [`http://localhost:3000/double-spent`](http://localhost:3000/double-spent)

   - Click `start game`,
   - Check the console.logged utxo is the same as stored in config. If mismatch, refresh until the param UTxO being spent is the same one being
   - If correct, sign the transaction

4. In [`game-config.ts`](../../utils/game-config.ts)

   - Turn `startNewGame` to `false`

5. Refresh url [`http://localhost:3000/double-spent`](http://localhost:3000/double-spent)

   - This will copy the address book to clipboard (💎)

6. In [`functions/src/config.ts`](../../functions/src/config.ts)

   - Paste and save new address book
   - Paste same address book into `utils/game-config.ts`
   - In the terminal, `cd functions` && `npm run deploy`

7. In [`game-config.ts`](../../utils/game-config.ts)

   - Paste and save new address book
   - Turn `startNewAddressBook` to `false`
