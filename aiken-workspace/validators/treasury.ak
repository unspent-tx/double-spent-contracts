use cardano/assets.{ PolicyId, from_lovelace, from_asset}
use cardano/transaction.{ Output, OutputReference, Transaction, InlineDatum, find_input}
use aiken/primitive/int.{ from_utf8 }
use aiken/builtin.{divide_integer, less_than_integer}
use cocktail.{inputs_with_policy, only_minted_token,inputs_at, }
use oracle.{OracleDatum}
use mocktail.{mint, tx_out, complete, ref_tx_in, ref_tx_in_inline_datum, tx_in, mock_script_address, mock_tx_hash, mock_policy_id, mocktail_tx, mock_utxo_ref, mock_pub_key_address, mock_pub_key_hash}

pub type TreasuryRedeemer {
  Withdraw { asset_name: ByteArray }
}

validator treasury(oracle_nft: PolicyId, nft_policy: PolicyId) {
  spend(
    _datum_opt: Option<Data>,
    redeemer: TreasuryRedeemer,
    input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction {mint, reference_inputs, inputs, .. } = tx
    when (
      redeemer,
      inputs_with_policy(reference_inputs, oracle_nft), 
      find_input(inputs, input),
    ) is {(
        Withdraw { asset_name }, 
        [oracle_input], 
        Some(own_input), 
        ) -> {
        when (
          oracle_input.output.datum, 
          inputs_at(inputs, own_input.output.address), 
          from_utf8(asset_name), 
        ) is {(
            InlineDatum(oracle_datum), 
            [_, _],
            Some(nft_index),
            ) -> {
            expect OracleDatum { count, .. } = oracle_datum
            let is_burned = only_minted_token(mint, nft_policy, asset_name, -1)
            let under_threshold = less_than_integer(nft_index, divide_integer(count, 2))
            under_threshold? && is_burned? 
          }
          _ -> {
            trace @"Invalid oracle datum, own inputs, nft name integer"
            False
          }
        }
      }
      _ -> {
        trace @"Invalid redeemer, oracle input, own inputs"
        False
      }
    }
  }
  else(_) {
    fail
  }
}

const oracle_nft = mock_policy_id(1)
const treasury_script_address = mock_script_address(0, None)
const oracle_script_address = mock_script_address(1, None)
const user_address = mock_pub_key_address(2, None)
const asset_name = #"31"
const policy_id = mock_policy_id(0)
const winner = mock_pub_key_hash(2)
const pot_script_address = mock_script_address(3, None)
const fee_address = mock_pub_key_address(4, None)

test success_withdraw() {
  let redeemer = Withdraw {  asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()

  |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
  |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
  |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
  |> ref_tx_in_inline_datum(
      True, 
      OracleDatum {
            count: 6,
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
  |> mint(True, -1, policy_id, asset_name)
  |> tx_out(True,user_address, from_lovelace(200_000_000))
  |> complete()

  treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}

test fail_withdraw_above_threshold() {
  let redeemer = Withdraw { asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 2, // Count is 2, so threshold is 1, but our token value is 31
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
    |> mint(True, -1, policy_id, asset_name)
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}
test fail_withdraw_equal_threshold() {
  let redeemer = Withdraw { asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 1, // Count is 1 to match asset name
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
    |> mint(True, -1, policy_id, asset_name)
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}

test fail_withdraw_without_burn() {
  let redeemer = Withdraw { asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 6,
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
    |> mint(False, -1, policy_id, asset_name) // NFT not burned
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}
test fail_withdraw_without_burn_redeemer_name_mix() {
  let redeemer = Withdraw { asset_name: #"32" }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 6,
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
    |> mint(True, -1, policy_id, asset_name) // NFT does not match redeemer
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}

test fail_withdraw_wrong_input_count_less_than_two() {
  let redeemer = Withdraw { asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 6,
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
    |> mint(True, -1, policy_id, asset_name)
    |> tx_out(True, user_address, from_lovelace(100_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}
test fail_withdraw_wrong_input_count_more_than_two() {
  let redeemer = Withdraw { asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 6,
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
    |> mint(True, -1, policy_id, asset_name)
    |> tx_out(True, user_address, from_lovelace(100_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}

test fail_withdraw_missing_oracle_reference() {
  let redeemer = Withdraw { asset_name }

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> mint(True, -1, policy_id, asset_name)
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}

test fail_withdraw_invalid_oracle_datum() {
  let redeemer = Withdraw { asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        False, // Invalid datum
        OracleDatum {
          count: 6,
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
    |> mint(True, -1, policy_id, asset_name)
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}

test fail_withdraw_invalid_nft_value() {
  let redeemer = Withdraw { asset_name: #"abcdef" } // Valid hex but not a number
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 6,
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
    |> mint(True, -1, policy_id, #"abcdef")
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}

test fail_withdraw_zero_count() {
  let redeemer = Withdraw { asset_name }
  let oracle_input_value = from_asset(oracle_nft, "", 1) 

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(100_000_000), treasury_script_address)
    |> ref_tx_in(True, mock_tx_hash(0), 0, oracle_input_value, oracle_script_address)
    |> ref_tx_in_inline_datum(
        True, 
        OracleDatum {
          count: 0, // Zero count edge case
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
    |> mint(True, -1, policy_id, asset_name)
    |> tx_out(True, user_address, from_lovelace(200_000_000))
    |> complete()

  !treasury.spend(oracle_nft, policy_id, None, redeemer, mock_utxo_ref(0,0), tx)
}