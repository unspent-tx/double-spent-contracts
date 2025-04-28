// // Double Spent — A perpetual NFT protocol.

// // Copyright (C) 2025 unspentTx @https://github.com/unspent-tx.

// // This file is part of Double Spent.

// // Double Spent is free software: you can redistribute it and/or modify
// // it under the terms of the GNU Affero General Public License as published
// // by the Free Software Foundation, version 3 of the License.

// // This program is distributed in the hope that it will be useful,
// // but WITHOUT ANY WARRANTY; without even the implied warranty of
// // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// // GNU Affero General Public License for more details.

// // If your software can interact with users remotely through a computer
// // network, you should also make sure that it provides a way for users to
// // get its source.  For example, if your program is a web application, its
// // interface could display a "Source" link that leads users to an archive
// // of the code.  There are many ways you could offer source, and different
// // solutions will be better for different programs; see section 13 for the
// // specific requirements.

// // see <https://www.gnu.org/licenses/>.


// use cardano/assets.{PolicyId, from_asset, from_lovelace}
// use cardano/transaction.{OutputReference, Transaction, InlineDatum, find_input}
// use cocktail.{inputs_with_policy, valid_after, key_signed}
// use mocktail.{mock_script_address, mock_pub_key_hash, mock_pub_key_address, mock_tx_hash, mock_utxo_ref, mocktail_tx, mock_policy_id, required_signer_hash, ref_tx_in, ref_tx_in_inline_datum, tx_in, tx_out, complete, invalid_before}
// use types/type_oracle_datum.{OracleDatum}

// pub type PotRedeemer {
//   Withdraw 
// }

// validator pot(oracle_nft: PolicyId,) {
//   spend(
//     _datum_opt: Option<Data>,
//     redeemer: PotRedeemer,
//     input: OutputReference,
//     tx: Transaction,
//   ) {
//     let Transaction { inputs, reference_inputs, validity_range, .. } = tx
//     when (
//       redeemer,
//       inputs_with_policy(reference_inputs, oracle_nft), 
//       find_input(inputs, input), 
//       ) is {
//       (
//         Withdraw,
//         [oracle_input], 
//         Some(_), 
//       ) -> { 
//         when oracle_input.output.datum is {
//           InlineDatum(oracle_datum) -> {
//             expect OracleDatum { count, winner, start_slot, slot_increase, .. } = oracle_datum
//             let end_of_game = start_slot + count * slot_increase
//             let time_passed = valid_after(validity_range, end_of_game)
//             let is_winner_signed = key_signed(tx.extra_signatories, winner)
//             time_passed? && is_winner_signed? 
//           }
//           _ -> {
//             trace @"Invalid inline datum"
//             False
//           }
//         }
//       }
//       _ -> {
//         trace @"Invalid inputs, oracle reference input, redeemer"
//         False
//       }
//     }
//   }

//   else(_) {
//     fail
//   }
// }


// const winner = mock_pub_key_hash(2)
// const oracle_nft = mock_policy_id(1)
// const pot_script_address = mock_script_address(0, None)
// const treasury_script_address = mock_script_address(1, None)
// const oracle_script_address = mock_script_address(2, None)
// const user_address = mock_pub_key_address(3, None)
// const fee_address = mock_pub_key_address(4, None)


// test success_withdraw_pot() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1) 
//   let redeemer = Withdraw 
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
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
//     |> required_signer_hash(True, winner)
//     |> invalid_before(True, 3700)
//     |> complete()

//   pot.spend(oracle_nft,None, redeemer, mock_utxo_ref(0, 0), tx)
// }

// test fail_withdraw_pot_before_time() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1) 
//   let redeemer = Withdraw 
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
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
//     |> required_signer_hash(True, winner)
//     |> invalid_before(True, 1000) // Before game end time
//     |> complete()

//   !pot.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
// }

// test fail_withdraw_pot_wrong_winner() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1) 
//   let redeemer = Withdraw  // Wrong winner
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
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
//     |> required_signer_hash(True, mock_pub_key_hash(3))
//     |> invalid_before(True, 3700)
//     |> complete()

//   !pot.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
// }

// test fail_withdraw_pot_unsigned() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1) 
//   let redeemer = Withdraw 
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
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
//     |> required_signer_hash(False, winner) // Not signed
//     |> invalid_before(True, 3700)
//     |> complete()

//   !pot.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
// }

// test fail_withdraw_pot_missing_oracle_reference() {
//   let redeemer = Withdraw 
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_out(True, user_address, from_lovelace(300_000_000))
//     |> required_signer_hash(True, winner)
//     |> invalid_before(True, 3700)
//     |> complete()

//   !pot.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
// }

// test fail_withdraw_pot_invalid_oracle_datum() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1) 
//   let redeemer = Withdraw 
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
//     |> ref_tx_in_inline_datum(
//         False, // Invalid datum
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
//     |> required_signer_hash(True, winner)
//     |> invalid_before(True, 3700)
//     |> complete()

//   !pot.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
// }

// test fail_withdraw_pot_at_exact_end_time() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1) 
//   let redeemer = Withdraw 
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
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
//     |> required_signer_hash(True, winner)
//     |> invalid_before(True, 1200) // Exactly at game end time (start_slot + count * slot_increase)
//     |> complete()

//   !pot.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
// }

// test fail_withdraw_pot_multiple_oracle_references() {
//   let oracle_input_value = from_asset(oracle_nft, "", 1) 
//   let redeemer = Withdraw
//   let tx = mocktail_tx()
//     |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(1), 0, from_lovelace(100_000_000), pot_script_address)
//     |> tx_in(True, mock_tx_hash(2), 0, from_lovelace(100_000_000), pot_script_address)
//     |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
//     |> ref_tx_in(True, mock_tx_hash(1), 0, oracle_input_value, oracle_script_address) // Second oracle reference
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
//     |> required_signer_hash(True, winner)
//     |> invalid_before(True, 3700)
//     |> complete()

//   !pot.spend(oracle_nft, None, redeemer, mock_utxo_ref(0, 0), tx)
// }