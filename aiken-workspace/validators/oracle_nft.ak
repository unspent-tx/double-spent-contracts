// Originally forked from the plutus-nft contract written by @https://github.com/HinsonSIDAN Apache 2.0 license
// https://github.com/MeshJS/mesh/blob/main/packages/mesh-contract/src/plutus-nft/aiken-workspace/validators/oracle_nft.ak

use aiken/collection/list
use cardano/assets.{PolicyId, from_lovelace}
use cardano/transaction.{Input, OutputReference, Transaction, placeholder}
use mocktail.{complete, mint, mocktail_tx, tx_in}
use mocktail/virgin_address.{mock_pub_key_address}
use mocktail/virgin_key_hash.{mock_policy_id}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}

pub type MintPolarity {
  RMint
}

validator oracle_nft(utxo_ref: OutputReference) {
  mint(redeemer: MintPolarity, _policy_id: PolicyId, tx: Transaction) {
    let RMint = redeemer
    let Transaction { inputs, .. } = tx
    let hash_equal =
      fn(input: Input) {
        let hash = input.output_reference
        utxo_ref == hash
      }
    let target_input_exist = list.find(inputs, hash_equal)
    when target_input_exist is {
      Some(_) -> True
      None -> False
    }
  }
  else(_) {
    fail
  }
}

test success_mint() {
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

test fail_mint_no_utxo_ref_supply() {
  let redeemer = RMint
  let policy_id = mock_policy_id(0)

  !oracle_nft.mint(mock_utxo_ref(0, 0), redeemer, policy_id, placeholder)
}

