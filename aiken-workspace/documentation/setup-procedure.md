# Setup Procedure for complete DApp

(Not useful for aiken workspace)

## Prerequisites

- Firebase: Realtime Database, Firestore, Service Worker (admin), Functions
- Blockfrost API Key
- Next.js
- Mesh SDK

## Start Game

Run Aiken Build

1. In [`game-config.ts`](../../utils/game-config.ts)

   - Turn `startNewGame` to `true` // Fresh oracle
   - Turn `startNewAddressBook` to `false` // Fresh Blockfrost cache layer

2. Visit url [`http://localhost:3000/double-spent`](http://localhost:3000/double-spent)

   - Click `start game`
   - This will copy the param utxo to clipboard 🕹️
   - Sign transaction in wallet

3. In [`game-config.ts`](../../utils/game-config.ts)

   - Paste to update `paramUtxo` 🕹️

4. Visit url [`http://localhost:3000/double-spent`](http://localhost:3000/double-spent)

   - Click `register stake`
   - Sign transaction in wallet
   - Turn `startNewGame` to `false`
   - Turn `startNewAddressBook` to `true`

5. Refresh url [`http://localhost:3000/double-spent`](http://localhost:3000/double-spent)

   - This will copy the address book to clipboard 💎

6. In [`game-config.ts`](../../utils/game-config.ts)

   - Paste to update address book 💎
   - Turn `startNewAddressBook` to `false`

7. In [`functions/src/config.ts`](../../functions/src/config.ts)

   - To update firebase cache - Paste same address book 💎
   - In the terminal, `cd functions` && `npm run deploy`
