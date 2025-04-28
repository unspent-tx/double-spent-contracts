
// use aiken_design_patterns/stake_validator
// use cardano/assets.{PolicyId, from_asset, from_lovelace}
// use cardano/transaction.{OutputReference, Transaction, InlineDatum, find_input, Withdraw}
// use cardano/address.{Address, Credential, Script}

// use cocktail.{inputs_with_policy, valid_after, key_signed}
// use mocktail.{mock_script_address,mock_script_hash, mock_pub_key_hash, mock_pub_key_address, mock_tx_hash, mock_utxo_ref, mocktail_tx, mock_policy_id, required_signer_hash, ref_tx_in, ref_tx_in_inline_datum, tx_in, tx_out, complete, invalid_before, script_withdrawal}
// use types/type_oracle_datum.{OracleDatum}

// pub type PotRedeemer {
//   Withdraw
// }

// validator pot_v2(oracle_nft: PolicyId) {
//   spend(_datum_opt: Option<Data>, redeemer: PotRedeemer, input: OutputReference, tx: Transaction) {
//     let Transaction { inputs, .. } = tx
//     when (redeemer, find_input(inputs, input)) is {
//       (Withdraw, Some(input_utxo)) -> {
//         // Get validator's ScriptHash from input UTxO
//         expect Script(own_withdrawal) = input_utxo.output.address.payment_credential
//         // Only require zero-amount withdrawal
//         stake_validator.spend(
//           withdraw_script_hash: own_withdrawal,
//           withdraw_redeemer_validator: fn(_r_data, qty) { qty == 0 },
//           tx: tx,
//         )
//       }
//       _ -> {
//         trace @"Invalid redeemer or input"
//         False
//       }
//     }
//   }

//   withdraw(redeemer: PotRedeemer, own_credential: Credential, tx: Transaction) {
//     stake_validator.withdraw(
//       withdrawal_logic: fn(r, _own_validator, tx) {
//         let Transaction { reference_inputs, validity_range, extra_signatories, .. } = tx
//         when (r, inputs_with_policy(reference_inputs, oracle_nft)) is {
//           (Withdraw, [oracle_input]) -> {
//             when oracle_input.output.datum is {
//               InlineDatum(oracle_datum) -> {
//                 expect OracleDatum { count, start_slot, slot_increase, winner, .. } = oracle_datum
//                 let end_of_game = start_slot + count * slot_increase
//                 key_signed(extra_signatories, winner) && valid_after(validity_range, end_of_game)
//               }
//               _ -> {
//                 trace @"Invalid oracle datum"
//                 False
//               }
//             }
//           }
//           _ -> {
//             trace @"Invalid redeemer or oracle reference"
//             False
//           }
//         }
//       },
//       redeemer: redeemer,
//       stake_cred: own_credential,
//       tx: tx,
//     )
//   }

//   else(_) {
//     fail
//   }
// }


// const winner = mock_pub_key_hash(2)
// const not_winner = mock_pub_key_hash(22)
// const oracle_nft = mock_policy_id(1)
// const pot_script_address = mock_script_address(0, None)
// const treasury_script_address = mock_script_address(1, None)
// const oracle_script_address = mock_script_address(2, None)
// const user_address = mock_pub_key_address(3, None)
// const fee_address = mock_pub_key_address(4, None)

// test success_withdraw_pot() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1)
//   let redeemer = Withdraw
//   let validator_hash = mock_script_hash(0) // Matches pot_script_address
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)

//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(3), 0, oracle_input_value, oracle_script_address)
//     |> ref_tx_in_inline_datum(
//         True,
//         OracleDatum {
//           count: 1,
//           treasury_address: treasury_script_address,
//           pot_address: pot_script_address,
//           fee_address: fee_address,
//           winner,
//           lock_price: 100_000_000,
//           pot_price: 6_000_000,
//           fee_price: 5_000_000,
//           start_slot: 0,
//           slot_increase: 1200,
//         }
//     )
//     |> tx_out(True, user_address, from_lovelace(300_000_000))
//     |> script_withdrawal(True, validator_hash, 0) // Zero-amount withdrawal

//     |> required_signer_hash(True, winner)
//     |> invalid_before(True, 3700) // After game end (1200)
//     |> complete()


//    let spend_result = pot_v2.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
//    let withdraw_result = pot_v2.withdraw(oracle_nft,redeemer, Script(validator_hash), tx)

//   spend_result && withdraw_result
// }

