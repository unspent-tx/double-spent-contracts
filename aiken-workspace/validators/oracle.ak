// Originally forked from the plutus-nft contract open sourced by @https://github.com/HinsonSIDAN 
// https://github.com/MeshJS/mesh/blob/main/packages/mesh-contract/src/plutus-nft/aiken-workspace/validators/oracle.ak

use aiken/collection/list
use cardano/address.{Address}
use cardano/assets.{add, flatten, from_asset, from_lovelace}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction, find_input,
}
use mocktail.{
  complete, mint, mocktail_tx, tx_in, tx_in_inline_datum,
  tx_out, tx_out_inline_datum,
}
use mocktail/virgin_address.{mock_pub_key_address, mock_script_address}
use mocktail/virgin_key_hash.{mock_policy_id, mock_pub_key_hash}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}
use cocktail.{
  inputs_at_with_policy,
  outputs_at_with_policy,
  get_all_value_to,
  value_geq,
}




pub type OracleDatum {
  count: Int,
  treasury_address: Address, 
  pot_address: Address,
  fee_address: Address, 
  winner: ByteArray, // Pub key hash of last nft purchaser
  lock_price: Int, // Treasury lock price
  pot_price: Int, // Prize Pool lock price
  fee_price: Int, // Developer fee
  start_slot: Int, // Timer: Slot of oracle deployment (includes offset)
  slot_increase: Int, // Timer: Slot increase for each mint
}

pub type OracleRedeemer {
  MintPlutusNFT { winner: ByteArray }
}

validator oracle {
  spend(
    datum_opt: Option<OracleDatum>,
    redeemer: OracleRedeemer,
    input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction {  inputs, outputs, .. } = tx
    expect Some(OracleDatum { count, treasury_address, pot_address, fee_address, winner:_winner, lock_price, pot_price, fee_price, start_slot, slot_increase }) = datum_opt
    expect Some(own_input) = find_input(inputs, input)
    expect [(oracle_nft_policy, _, _)] =
      list.filter(flatten(own_input.output.value), fn(x) { x.1st != "" })
    let own_address = own_input.output.address
    when (
        redeemer,
        inputs_at_with_policy(inputs, own_address, oracle_nft_policy),
        outputs_at_with_policy(outputs, own_address, oracle_nft_policy),
      ) is {(
        MintPlutusNFT { winner: new_winner }, 
        [_], 
        [only_output]) -> {
        let is_output_value_clean = list.length(flatten(only_output.value)) == 2
        let is_count_updated =
          only_output.datum == InlineDatum(
            OracleDatum { count: count + 1, treasury_address, pot_address, fee_address, winner: new_winner, lock_price, pot_price, fee_price, start_slot, slot_increase },
          )
        let is_fee_paid =
          get_all_value_to(outputs, fee_address)
            |> value_geq(from_lovelace(fee_price))
        let is_treasury_paid =
          get_all_value_to(outputs, treasury_address)
            |> value_geq(from_lovelace(lock_price))
        let is_pot_paid =
          get_all_value_to(outputs, pot_address)
            |> value_geq(from_lovelace(pot_price))

        is_output_value_clean? && is_count_updated? && is_fee_paid? && is_treasury_paid? && is_pot_paid?
      }
        
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

type MintTestCase {
  is_oracle_output_clean: Bool,
  is_fee_paid: Bool,
  is_count_updated: Bool,
  is_treasury_paid: Bool,
  is_pot_paid: Bool,
}

fn mock_mint_tx(test_case: MintTestCase) -> Transaction {
  let MintTestCase { is_oracle_output_clean, is_fee_paid, is_count_updated, is_treasury_paid, is_pot_paid } =
    test_case

  let input_value =
    from_asset(mock_policy_id(0), "", 1) |> add("", "", 2_000_000)

    

  mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, input_value, mock_script_address(0, None))
    |> tx_in_inline_datum(
        True,
        OracleDatum {
          count: 0,
          treasury_address: mock_script_address(0, None),
          pot_address: mock_script_address(1, None),
          fee_address: mock_pub_key_address(2, None),
          winner: mock_pub_key_hash(3),
          lock_price: 100_000_000,
          pot_price: 6_000_000,
          fee_price: 5_000_000,
          start_slot: 0,
          slot_increase: 1200,
        },
      )
    |> tx_out(is_oracle_output_clean, mock_script_address(0, None), input_value)
    |> tx_out(
        !is_oracle_output_clean,
        mock_script_address(0, None),
        input_value |> add(mock_policy_id(1), "", 1),
      )
    |> tx_out_inline_datum(
        True,
        OracleDatum {
          count: if is_count_updated {
            1
          } else {
            0
          },
          treasury_address: mock_script_address(0, None),
          pot_address: mock_script_address(1, None),
          fee_address: mock_pub_key_address(2, None),
          winner: mock_pub_key_hash(3),
          lock_price: 100_000_000,
          pot_price: 6_000_000,
          fee_price: 5_000_000,
          start_slot: 0,
          slot_increase: 1200,
        },
      )
    |> mint(True, 1, mock_policy_id(1), "collection (0)")
    |> tx_out(is_fee_paid, mock_pub_key_address(2, None), from_lovelace(5_000_000))
    |> tx_out(is_treasury_paid, mock_script_address(0, None), from_lovelace(100_000_000))
    |> tx_out(is_pot_paid, mock_script_address(1, None), from_lovelace(6_000_000))
    |> complete()
}

test success_mint() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000,
      start_slot: 0,
      slot_increase: 1200,
    }
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }
  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: True,
        is_count_updated: True,
        is_treasury_paid: True,
        is_pot_paid: True,
      },
    )

  oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}

test fail_mint_with_unclean_output() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000, 
      start_slot: 0,
      slot_increase: 1200,
    }
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }

  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: False,
        is_fee_paid: True,
        is_count_updated: True,
        is_treasury_paid: True,
        is_pot_paid: True,
      },
    )

  !oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}

test fail_mint_without_fee_paid() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000,
      start_slot: 0,
      slot_increase: 1200,
    }
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }

  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: False,
        is_count_updated: True,
        is_treasury_paid: True,
        is_pot_paid: True,
      },
    )

  !oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}

test fail_mint_without_count_updated() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000,
      start_slot: 0,
      slot_increase: 1200,
    } 
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }

  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: True,
        is_count_updated: False,
        is_treasury_paid: True,
        is_pot_paid: True,
      },
    )

  !oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}

test fail_mint_without_treasury_paid() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000,
      start_slot: 0,
      slot_increase: 1200,
    }
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }

  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: True,
        is_count_updated: True,
        is_treasury_paid: False, // Treasury not paid
        is_pot_paid: True,
      },
    )

  !oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}

test fail_mint_without_pot_paid() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000,
      start_slot: 0,
      slot_increase: 1200,
    }
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }

  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: True,
        is_count_updated: True,
        is_treasury_paid: True,
        is_pot_paid: False, // Pot not paid
      },
    )

  !oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}

test fail_mint_with_insufficient_treasury_payment() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000,
      start_slot: 0,
      slot_increase: 1200,
    }
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_asset(mock_policy_id(0), "", 1) |> add("", "", 2_000_000), mock_script_address(0, None))
    |> tx_in_inline_datum(
        True,
        OracleDatum {
          count: 0,
          treasury_address: mock_script_address(0, None),
          pot_address: mock_script_address(1, None),
          fee_address: mock_pub_key_address(2, None),
          winner: mock_pub_key_hash(3),
          lock_price: 100_000_000,
          pot_price: 6_000_000,
          fee_price: 5_000_000,
          start_slot: 0,
          slot_increase: 1200,
        },
      )
    |> tx_out(True, mock_script_address(0, None), from_asset(mock_policy_id(0), "", 1) |> add("", "", 2_000_000))
    |> tx_out_inline_datum(
        True,
        OracleDatum {
          count: 1,
          treasury_address: mock_script_address(0, None),
          pot_address: mock_script_address(1, None),
          fee_address: mock_pub_key_address(2, None),
          winner: mock_pub_key_hash(3),
          lock_price: 100_000_000,
          pot_price: 6_000_000,
          fee_price: 5_000_000,
          start_slot: 0,
          slot_increase: 1200,
        },
      )
    |> mint(True, 1, mock_policy_id(1), "collection (0)")
    |> tx_out(True, mock_pub_key_address(2, None), from_lovelace(5_000_000)) // Fee paid
    |> tx_out(True, mock_script_address(0, None), from_lovelace(50_000_000)) // Insufficient treasury payment
    |> tx_out(True, mock_script_address(1, None), from_lovelace(6_000_000)) // Pot paid
    |> complete()

  !oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}

test fail_mint_with_insufficient_pot_payment() {
  let datum =
    OracleDatum {
      count: 0,
      treasury_address: mock_script_address(0, None),
      pot_address: mock_script_address(1, None),
      fee_address: mock_pub_key_address(2, None),
      winner: mock_pub_key_hash(3),
      lock_price: 100_000_000,
      pot_price: 6_000_000,
      fee_price: 5_000_000,
      start_slot: 0,
      slot_increase: 1200,
    }
  let redeemer = MintPlutusNFT { winner: mock_pub_key_hash(3) }

  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, from_asset(mock_policy_id(0), "", 1) |> add("", "", 2_000_000), mock_script_address(0, None))
    |> tx_in_inline_datum(
        True,
        OracleDatum {
          count: 0,
          treasury_address: mock_script_address(0, None),
          pot_address: mock_script_address(1, None),
          fee_address: mock_pub_key_address(2, None),
          winner: mock_pub_key_hash(3),
          lock_price: 100_000_000,
          pot_price: 6_000_000,
          fee_price: 5_000_000,
          start_slot: 0,
          slot_increase: 1200,
        },
      )
    |> tx_out(True, mock_script_address(0, None), from_asset(mock_policy_id(0), "", 1) |> add("", "", 2_000_000))
    |> tx_out_inline_datum(
        True,
        OracleDatum {
          count: 1,
          treasury_address: mock_script_address(0, None),
          pot_address: mock_script_address(1, None),
          fee_address: mock_pub_key_address(2, None),
          winner: mock_pub_key_hash(3),
          lock_price: 100_000_000,
          pot_price: 6_000_000,
          fee_price: 5_000_000,
          start_slot: 0,
          slot_increase: 1200,
        },
      )
    |> mint(True, 1, mock_policy_id(1), "collection (0)")
    |> tx_out(True, mock_pub_key_address(2, None), from_lovelace(5_000_000)) // Fee paid
    |> tx_out(True, mock_script_address(0, None), from_lovelace(100_000_000)) // Treasury paid
    |> tx_out(True, mock_script_address(1, None), from_lovelace(3_000_000)) // Insufficient pot payment
    |> complete()

  !oracle.spend(Some(datum), redeemer, mock_utxo_ref(0, 0), tx)
}
