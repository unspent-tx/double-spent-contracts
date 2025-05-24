// 🪺 be the winner and wait for timer to expire to withdraw the pot utxos

use aiken_design_patterns/stake_validator
use cardano/address.{Credential, Script}
use cardano/assets.{PolicyId, from_asset}
use cardano/transaction.{InlineDatum, Transaction, Withdraw}
use cocktail.{inputs_with_policy, key_signed, valid_after}
use mocktail.{
  complete, invalid_before, mock_policy_id, mock_pub_key_hash,
  mock_script_address, mock_script_hash, mock_tx_hash, mocktail_tx, ref_tx_in,
  ref_tx_in_inline_datum, required_signer_hash, script_withdrawal,
}
use oracle.{DatumTestCase, OracleDatum, datum_with_updates}

pub type PotRedeemer {
  Withdraw
}

validator pot_withdraw(oracle_nft: PolicyId) {
  withdraw(redeemer: PotRedeemer, own_credential: Credential, tx: Transaction) {
    stake_validator.withdraw(
      withdrawal_logic: fn(r, _own_validator, tx) {
        // withdraw logic
        when (r, inputs_with_policy(tx.reference_inputs, oracle_nft)) is {
          (
            // when redeemer is withdraw
            Withdraw,
            // when 1 oracle input ref is present
            [oracle_input_ref],
          ) ->
            when oracle_input_ref.output.datum is {
                // some datum is present
              InlineDatum(oracle_datum) -> {
                // oracle datum is valid
                expect OracleDatum {
                  count,
                  slot_start,
                  slot_increase,
                  winner,
                  ..
                } = oracle_datum
                let is_winner = key_signed(tx.extra_signatories, winner)
                let is_timer_expired =
                  valid_after(
                    tx.validity_range,
                    slot_start + count * slot_increase,
                  )
                is_winner? && is_timer_expired?
              }
              // final validation
              _ -> {
                trace @"Invalid oracle datum"
                False
              }
            }
          _ -> {
            trace @"Invalid redeemer or oracle reference"
            False
          }
        }
      },
      redeemer: redeemer,
      stake_cred: own_credential,
      tx: tx,
    )
  }

  else(_) {
    fail
  }
}

const oracle_nft = mock_policy_id(1)

const oracle_script_address = mock_script_address(2, None)

const pot_withdraw_script_hash = mock_script_hash(1)

const winner = mock_pub_key_hash(2)

const oracle_utxo_standard = from_asset(oracle_nft, "", 1)

const redeemer_standard = Withdraw

const datum_standard =
  datum_with_updates(
    DatumTestCase {
      count: None,
      treasury_address: None,
      pot_address: None,
      fee_address: None,
      winner: Some(winner),
      treasury_price: None,
      pot_price: None,
      fee_price: None,
      slot_start: Some(0),
      slot_increase: Some(1200),
      divisor: None,
    },
  )

test success_withdraw_pot() {
  let tx =
    mocktail_tx()
      |> ref_tx_in(
          True,
          mock_tx_hash(3),
          0,
          oracle_utxo_standard,
          oracle_script_address,
        )
      |> ref_tx_in_inline_datum(True, datum_standard)
      |> script_withdrawal(True, pot_withdraw_script_hash, 0)
      // Zero-amount withdrawal
      |> required_signer_hash(True, winner)
      |> invalid_before(True, 1201)
      // After game end 0 + 1 * 1200 = 1200
      |> complete()
  pot_withdraw.withdraw(
    oracle_nft,
    redeemer_standard,
    Script(pot_withdraw_script_hash),
    tx,
  )
}

test fail_withdraw_pot_not_winner() {
  let tx =
    mocktail_tx()
      |> ref_tx_in(
          True,
          mock_tx_hash(3),
          0,
          oracle_utxo_standard,
          oracle_script_address,
        )
      |> ref_tx_in_inline_datum(True, datum_standard)
      |> script_withdrawal(True, pot_withdraw_script_hash, 0)
      |> required_signer_hash(True, mock_pub_key_hash(4))
      // Not the winner
      |> invalid_before(True, 1201)
      |> complete()
  !pot_withdraw.withdraw(
    oracle_nft,
    redeemer_standard,
    Script(pot_withdraw_script_hash),
    tx,
  )
}

test fail_withdraw_pot_before_game_end() {
  let tx =
    mocktail_tx()
      |> ref_tx_in(
          True,
          mock_tx_hash(3),
          0,
          oracle_utxo_standard,
          oracle_script_address,
        )
      |> ref_tx_in_inline_datum(
          True,
          datum_with_updates(
            DatumTestCase {
              count: Some(20),
              // count 
              treasury_address: None,
              pot_address: None,
              fee_address: None,
              winner: Some(winner),
              // winner
              treasury_price: None,
              pot_price: None,
              fee_price: None,
              slot_start: Some(1000),
              // slot_start
              slot_increase: Some(1200),
              // slot_increase
              divisor: None,
            },
          ),
        )
      |> script_withdrawal(True, pot_withdraw_script_hash, 0)
      |> required_signer_hash(True, winner)
      |> invalid_before(True, 24999)
      // 1000 + 20 * 1200 = 25000
      |> complete()
  !pot_withdraw.withdraw(
    oracle_nft,
    redeemer_standard,
    Script(pot_withdraw_script_hash),
    tx,
  )
}

test fail_withdraw_pot_invalid_datum() {
  let tx =
    mocktail_tx()
      |> ref_tx_in(
          True,
          mock_tx_hash(3),
          0,
          oracle_utxo_standard,
          oracle_script_address,
        )
      |> ref_tx_in_inline_datum(False, datum_standard)
      // invalid datum
      |> script_withdrawal(True, pot_withdraw_script_hash, 0)
      |> required_signer_hash(True, winner)
      |> invalid_before(True, 1201)
      |> complete()
  !pot_withdraw.withdraw(
    oracle_nft,
    redeemer_standard,
    Script(pot_withdraw_script_hash),
    tx,
  )
}
