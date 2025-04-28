use aiken_design_patterns/stake_validator
use cardano/assets.{ from_asset, from_lovelace}
use cardano/transaction.{ Transaction, OutputReference, Withdraw}
use aiken/crypto.{ScriptHash}
use mocktail.{mock_script_address,mock_script_hash, mock_pub_key_hash, mock_pub_key_address, mock_tx_hash, mock_utxo_ref, mocktail_tx, mock_policy_id, required_signer_hash, ref_tx_in, ref_tx_in_inline_datum, tx_in, tx_out, complete, invalid_before, script_withdrawal}
use oracle.{OracleDatum}

pub type PotRedeemer {
  Withdraw
}

validator pot_spend(withdraw_script_hash: ScriptHash) {
  spend(_datum_opt: Option<Data>, redeemer: PotRedeemer, _input: OutputReference, tx: Transaction) {
    let Withdraw = redeemer
    stake_validator.spend(
          withdraw_script_hash: withdraw_script_hash,
          withdraw_redeemer_validator: fn(_r_data, qty) { qty == 0 },
          tx: tx,
        )
  }
  else(_) {
    fail
  }
}


const winner = mock_pub_key_hash(2)
// const not_winner = mock_pub_key_hash(22)
const oracle_nft = mock_policy_id(1)
const pot_script_address = mock_script_address(0, None)
const treasury_script_address = mock_script_address(1, None)
const oracle_script_address = mock_script_address(2, None)
const user_address = mock_pub_key_address(3, None)
const fee_address = mock_pub_key_address(4, None)
const pot_withdraw_script_hash = mock_script_hash(1)

test success_withdraw_pot() {
  let oracle_input_value = from_asset(oracle_nft, "", 1)
  let redeemer = Withdraw

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
    |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
    |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
    |> ref_tx_in(True, mock_tx_hash(3), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True,
        OracleDatum {
          count: 1,
          treasury_address: treasury_script_address,
          pot_address: pot_script_address,
          fee_address: fee_address,
          winner,
          lock_price: 100_000_000,
          pot_price: 6_000_000,
          fee_price: 5_000_000,
          start_slot: 0,
          slot_increase: 1200,
        }
    )
    |> tx_out(True, user_address, from_lovelace(300_000_000))
    |> script_withdrawal(True, pot_withdraw_script_hash, 0) // Zero-amount withdrawal with correct script hash
    |> required_signer_hash(True, winner)
    |> invalid_before(True, 3700) // After game end (1200)
    |> complete()

  let spend_result = pot_spend.spend( pot_withdraw_script_hash, None, redeemer, mock_utxo_ref(0, 0), tx)
  spend_result
}

