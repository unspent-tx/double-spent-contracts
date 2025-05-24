// 🖲️ one time minting policy to initiate state thread

// originally forked from the plutus-nft contract written by @https://github.com/HinsonSIDAN Apache 2.0 license
// https://github.com/MeshJS/mesh/blob/main/packages/mesh-contract/src/plutus-nft/aiken-workspace/validators/oracle_nft.ak

use aiken/collection/list
use cardano/assets.{PolicyId, from_lovelace}
use cardano/transaction.{Input, OutputReference, Transaction, placeholder}
use mocktail.{
  complete, mint, mock_policy_id, mock_pub_key_address, mock_tx_hash,
  mock_utxo_ref, mocktail_tx, tx_in,
}

pub type MintPolarity {
  RMint
}

validator oracle_nft(utxo_ref: OutputReference) {
  mint(redeemer: MintPolarity, _policy_id: PolicyId, tx: Transaction) {
    let RMint = redeemer
      // find the hash of the param utxo
    let hash_equal =
      fn(input: Input) {
        let hash = input.output_reference
        utxo_ref == hash
      }
    // check if we spend it
    let target_input_exist = list.find(tx.inputs, hash_equal)
    when target_input_exist is {
      Some(_) -> True
      None -> False
    }
  }

  else(_) {
    fail
  }
}

test success_mint_oracle() {
  let redeemer = RMint
  let input_utxo = mock_utxo_ref(0, 1)
  let policy_id: PolicyId =
    #"1c1b7afe8affbee1505cf3ec5a58bd2734d4ffdfcc9b9f059625bd76"

  let tx =
    mocktail_tx()
      |> mint(True, 1, policy_id, "")
      |> tx_in(
          True,
          mock_tx_hash(0),
          1,
          from_lovelace(1000000),
          mock_pub_key_address(0, None),
        )
      |> complete()

  oracle_nft.mint(input_utxo, redeemer, policy_id, tx)
}

test fail_mint_oracle_no_utxo_ref_supply() {
  let redeemer = RMint
  let policy_id = mock_policy_id(0)

  !oracle_nft.mint(mock_utxo_ref(0, 0), redeemer, policy_id, placeholder)
}
