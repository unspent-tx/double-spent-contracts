// 🪺 store utxos for winner - spend logic offloaded to pot_withdraw validator

use aiken/crypto.{ScriptHash}
use aiken_design_patterns/stake_validator
use cardano/assets.{from_asset, from_lovelace}
use cardano/transaction.{OutputReference, Transaction, Withdraw}
use mocktail.{complete, invalid_before, mock_policy_id, mock_pub_key_address, mock_pub_key_hash, mock_script_address, mock_script_hash, mock_tx_hash, mock_utxo_ref, mocktail_tx, ref_tx_in, ref_tx_in_inline_datum, required_signer_hash, script_withdrawal, tx_in, tx_out}
use oracle.{datum_with_updates, DatumTestCase}

pub type PotRedeemer {
  Withdraw
}

validator pot_spend(withdraw_script_hash: ScriptHash) {
  spend(_datum_opt: Option<Data>, redeemer: PotRedeemer, _input: OutputReference, tx: Transaction) {
    let Withdraw = redeemer
    stake_validator.spend(                                     // withdraw zero trick offloads logic
          withdraw_script_hash: withdraw_script_hash,
          withdraw_redeemer_validator: fn(_r_data, qty) { qty == 0 },
          tx: tx,
        )
  }
  else(_) {
    fail
  }
}

const oracle_nft = mock_policy_id(1)
const oracle_script_address = mock_script_address(2, None)
const oracle_input_value = from_asset(oracle_nft, "", 1)
const winner = mock_pub_key_hash(2)
const winner_address = mock_pub_key_address(3, None)
const pot_spend_script_address = mock_script_address(0, None)
const pot_withdraw_script_hash = mock_script_hash(1)
const redeemer_standard = Withdraw
const datum_standard = 
  datum_with_updates(
    DatumTestCase {
      count: None,
      treasury_address: None,
      pot_address: Some(pot_spend_script_address),
      fee_address: None,
      winner: Some(winner),
      treasury_price: None,
      pot_price: None,
      fee_price: None,
      slot_start: None,
      slot_increase: None,
      divisor: None,
    }
  )

test success_spend_pot() {
  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_spend_script_address)
    |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_spend_script_address)
    |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_spend_script_address)    // arbitary amount of withdrawals from pot
    |> ref_tx_in(True, mock_tx_hash(3), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(True, datum_standard)
    |> tx_out(True, winner_address, from_lovelace(300_000_000))
    |> script_withdrawal(True, pot_withdraw_script_hash, 0)                                     // zero-amount withdrawal with correct script hash
    |> required_signer_hash(True, winner)
    |> invalid_before(True, 3700)                                                               // after game end (1200)
    |> complete()
pot_spend.spend(pot_withdraw_script_hash, None, redeemer_standard, mock_utxo_ref(0, 0), tx)

}
test fail_spend_pot_with_wrong_script_hash() {
  let pot_withdraw_script_hash_wrong = mock_script_hash(2)                                      // script hash 
  let tx = mocktail_tx()
  |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_spend_script_address)
    |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_spend_script_address)
    |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_spend_script_address)   
    |> ref_tx_in(True, mock_tx_hash(3), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(True, datum_standard)
    |> tx_out(True, winner_address, from_lovelace(300_000_000))
    |> script_withdrawal(True, pot_withdraw_script_hash_wrong, 0)                               // wrong script hash withdrawal
    |> script_withdrawal(True, pot_withdraw_script_hash, 1)                                     // add correct script hash withdrawal
    |> required_signer_hash(True, winner)
    |> invalid_before(True, 3700)                                                               
    |> complete()
  !pot_spend.spend(pot_withdraw_script_hash, None, redeemer_standard, mock_utxo_ref(0, 0), tx) // correct script hash
  
}

