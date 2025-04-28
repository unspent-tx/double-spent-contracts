// use aiken/collection/list
// use cardano/address.{Address}
// use cardano/assets.{from_lovelace, lovelace_of, add}
// use cardano/transaction.{OutputReference, Transaction, find_input, InlineDatum, Input,}
// // use vodka_address.{address_pub_key}
// // use vodka_extra_signatories.{key_signed}
// // use vodka_inputs.{inputs_at}
// use cocktail.{key_signed,inputs_at,get_all_value_to, value_geq, address_pub_key}







// use mocktail.{
//   add_input, complete, mocktail_tx, required_signer_hash, tx_in,
//   tx_in_inline_datum, tx_out_inline_datum, tx_out, mock_pub_key_address, mock_script_address,mock_policy_id, mock_pub_key_hash, mock_tx_hash, mock_utxo_ref, mock_script_output
// }



// pub type MarketplaceDatum {
//   MarketplaceDatum {
//     seller: Address,
//     price: Int,
//     policy: ByteArray,
//     tokenName: ByteArray,
//   }
// }

// pub type MarketplaceRedeemer {
//   Buy
//   Close
// }

// validator marketplace(owner: Address, fee_percentage_basis_point: Int) {
//   spend(
//     datum_opt: Option<MarketplaceDatum>,
//     redeemer: MarketplaceRedeemer,
//     input: OutputReference,
//     tx: Transaction,
//   ) {
//     expect Some(datum) = datum_opt
//     when redeemer is {
//       Buy -> {
//         expect Some(own_input) = find_input(tx.inputs, input)
//         let own_address = own_input.output.address


//     let user_outputs_restricted =
//       list.filter(
//         tx.outputs,
//         fn(output) {
//           when output.datum is {
//             InlineDatum(output_datum) ->
     
//               if output_datum is OutputReference {
//                 and {
//                   output.address == datum.seller,
//                   input == output_datum,
//                 }
//               } else {
//                 False
//               }
//             _ -> False
//           }
//         },
//       )


 

//         let is_proceed_paid =
//           get_all_value_to(user_outputs_restricted, datum.seller)
//             |> value_geq(
//                 from_lovelace(datum.price + lovelace_of(own_input.output.value)),
//               )
//         let is_fee_paid =
//           get_all_value_to(tx.outputs, owner)
//             |> value_geq(
//                 from_lovelace(datum.price * fee_percentage_basis_point / 10000),
//               )

//          is_fee_paid? && is_proceed_paid ?
//       }
//       Close -> {
//         expect Some(pub_key) = address_pub_key(datum.seller)
//         key_signed(tx.extra_signatories, pub_key)
//       }
//     }
//   }

//   else(_) {
//     fail
//   }
// }


// type CloseTestCase {
//   is_seller_signed: Bool,
// }

// fn mock_datum() -> MarketplaceDatum {
//   MarketplaceDatum {
//     seller: mock_pub_key_address(1, None),
//     price: 200_000_000,
//     policy: mock_policy_id(0),
//     tokenName: "Test Token",
//   }
// }

// fn get_close_test_tx(test_case: CloseTestCase) -> Transaction {
//   let CloseTestCase { is_seller_signed } = test_case

//   mocktail_tx()
//     |> tx_in(
//         True,
//         mock_tx_hash(0),
//         1,
//         from_lovelace(2_000_000),
//         mock_script_address(0, None),
//       )
//     |> tx_in_inline_datum(True, mock_datum())
//     |> required_signer_hash(is_seller_signed, mock_pub_key_hash(1))
//     |> complete()
// }

// test success_close() {
//   let redeemer = Close
//   let test_case = CloseTestCase { is_seller_signed: True }

//   let tx = get_close_test_tx(test_case)
//   marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference_1,
//     tx,
//   )
// }

// test fail_close_without_signature() {
//   let redeemer = Close
//   let test_case = CloseTestCase { is_seller_signed: False }

//   let tx = get_close_test_tx(test_case)
//   !marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference_1,
//     tx,
//   )
// }

// type BuyTestCase {
//   is_only_one_input_from_script: Bool,
//   is_fee_paid: Bool,
//   is_proceed_paid: Bool,
//   is_output_reference_datum: Bool,
// }
// const output_reference_1 = mock_utxo_ref(0, 1)
// const output_hash_1 = mock_tx_hash(0)
// const output_index_1 = 1
// const output_reference_2 = mock_utxo_ref(0, 2)
// const output_hash_2 = mock_tx_hash(0)
// const output_index_2 = 2
// fn get_buy_test_tx(test_case: BuyTestCase) -> Transaction {
//   let BuyTestCase {
//     is_only_one_input_from_script,
//     is_fee_paid,
//     is_proceed_paid,
//     is_output_reference_datum,
//   } = test_case

//   let input_value =
//     from_lovelace(2_000_000) |> add(mock_policy_id(0), "Test Token", 1)
  

//   mocktail_tx()
//     |> tx_out(
//         True,
//         mock_pub_key_address(0, None),
//         if is_fee_paid {
//           from_lovelace(2_000_000)
//         } else {
//           from_lovelace(1_000_000)
//         },
//       )
//     |> tx_out(
//         True,
//         mock_pub_key_address(1, None),
//         if is_proceed_paid {
//           from_lovelace(202_000_000)
//         } else {
//           from_lovelace(200_000_000)
//         },
//       )
//     |> tx_out_inline_datum(
//         is_output_reference_datum,
//         output_reference_1,
//       )
//     |> tx_in(True, output_hash_1, output_index_1, input_value, mock_script_address(0, None))
//     |> tx_in(!is_only_one_input_from_script, output_hash_2, output_index_2, input_value, mock_script_address(0, None))
//     |> tx_out(
//         !is_only_one_input_from_script,
//         mock_pub_key_address(1, None),
//         if is_proceed_paid {
//           from_lovelace(202_000_000)
//         } else {
//           from_lovelace(200_000_000)
//         },
//       )
//     |> tx_out_inline_datum(
//         !is_only_one_input_from_script,
//         output_reference_2,
//       )
//     |> complete()

    
    
// }

// test success_buy() {
//   let redeemer = Buy
//   let test_case =
//     BuyTestCase {
//       is_only_one_input_from_script: True,
//       is_fee_paid: True,
//       is_proceed_paid: True,
//       is_output_reference_datum: True,
//     }

//   let tx = get_buy_test_tx(test_case)
//   marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference_1,
//     tx,
//   ) 
// }
// test success_buy_multiple() {
//   let redeemer = Buy
//   let test_case =
//     BuyTestCase {
//       is_only_one_input_from_script: False,
//       is_fee_paid: True,
//       is_proceed_paid: True,
//       is_output_reference_datum: True,
//     }

//   let tx = get_buy_test_tx(test_case)
//   marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference_1,
//     tx,
//   ) && marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference_2,
//     tx,
//   )
// }

// test fail_buy_with_multiple_script_inputs() {
//   let output_reference = mock_utxo_ref(0, 1)
//   let redeemer = Buy
//   let test_case =
//     BuyTestCase {
//       is_only_one_input_from_script: False,
//       is_fee_paid: True,
//       is_proceed_paid: True,
//       is_output_reference_datum: True,
//     }

//   let tx = get_buy_test_tx(test_case)
//   !marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference,
//     tx,
//   )
// }

// test fail_buy_without_fee_paid() {
//   let output_reference = mock_utxo_ref(0, 1)
//   let redeemer = Buy
//   let test_case =
//     BuyTestCase {
//       is_only_one_input_from_script: True,
//       is_fee_paid: False,
//       is_proceed_paid: True,
//       is_output_reference_datum: True,
//     }

//   let tx = get_buy_test_tx(test_case)
//   !marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference,
//     tx,
//   )
// }

// test fail_buy_without_proceed_paid() {
//   let output_reference = mock_utxo_ref(0, 1)
//   let redeemer = Buy
//   let test_case =
//     BuyTestCase {
//       is_only_one_input_from_script: True,
//       is_fee_paid: True,
//       is_proceed_paid: False,
//       is_output_reference_datum: True,
//     }

//   let tx = get_buy_test_tx(test_case)
//   !marketplace.spend(
//     mock_pub_key_address(0, None),
//     100,
//     Some(mock_datum()),
//     redeemer,
//     output_reference,
//     tx,
//   )
// }