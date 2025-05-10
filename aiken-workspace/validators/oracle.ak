// 🖲️ store and spend the state thread game logic

// originally forked from the plutus-nft contract open sourced by @https://github.com/HinsonSIDAN
// https://github.com/MeshJS/mesh/blob/main/packages/mesh-contract/src/plutus-nft/aiken-workspace/validators/oracle.ak

use aiken/collection/list
use cardano/address.{Address}
use cardano/assets.{add, flatten, from_asset, from_lovelace}
use cardano/transaction.{find_input, InlineDatum, Input, Output, OutputReference, Transaction}
use cocktail.{get_all_value_to, inputs_at_with_policy, outputs_at_with_policy, value_geq}
use mocktail.{complete, mint, mock_policy_id, mock_pub_key_address, mock_pub_key_hash, mock_script_address, mock_tx_hash, mock_utxo_ref, mocktail_tx, tx_in, tx_in_inline_datum, tx_out, tx_out_inline_datum}
use utils/find_policy_id_of_first_token.{find_policy_id_of_first_token}

pub type OracleDatum {
  count: Int,                 // collection count, gets incremented each mint
  treasury_address: Address,  // treasury address
  pot_address: Address,       // pot address
  fee_address: Address,       // developer's wallet
  winner: ByteArray,          // pub key hash of last nft purchaser, the wallet who can claim the prize pool
  treasury_price: Int,        // lovelace to lock in treasury upon mint
  pot_price: Int,             // lovelace to lock in the pot upon mint
  fee_price: Int,             // lovelace that leaves the protocol upon mint and pays devs
  slot_start: Int,            // timer: slot of oracle deployment ( includes arbitrary offset like + 6 months  )
  slot_increase: Int,         // timer: slot increase for each new mint
  divisor: Int,               // divisor for the burn threshold and the unlockable value
}
                              // the cost of the NFT is derived from ( treasury_price + pot_price + fee_price )
                              // the unlockable value for burning is derived from ( lock_price * divisor )
                              // the burn threshold is derived from ( count / divisor )
                              // the timer is derived from ( count * slot_increase + start_slot )
                              //

pub type OracleRedeemer {
  MintDsNFT { winner: ByteArray }
}

validator oracle {
  spend(
    datum_opt: Option<OracleDatum>,
    redeemer: OracleRedeemer,
    input: OutputReference,
    tx: Transaction,
  ) {
    expect Some(own_input) = find_input(tx.inputs, input)                         // find the input being spent
    let oracle_nft_policy = find_policy_id_of_first_token(own_input)              // custom helper function to find the oracle nft policy ID from its own input
    let own_address = own_input.output.address                                    // find the address of the input being spent
    expect Some(OracleDatum {count, treasury_address, pot_address, fee_address, winner:_winner, treasury_price, pot_price, fee_price, slot_start, slot_increase, divisor }) = datum_opt // destructure input datum
    when (redeemer, inputs_at_with_policy(tx.inputs, own_address, oracle_nft_policy), outputs_at_with_policy(tx.outputs, own_address, oracle_nft_policy)) is {
      (
        MintDsNFT { winner: new_winner },                                         // when the redeemer includes a new_winenr
        [_],                                                                      // when 1 input with oracle nft is present
        [only_output]                                                             // when 1 output with oracle nft is present
      ) -> {          
        let is_output_value_clean = list.length(flatten(only_output.value)) == 2  // oracle utxo output is comprised of only 1 NFT and it's lovelace
        let is_datum_updated =                                                    // compare output datum with input datum
          only_output.datum == InlineDatum(
            OracleDatum { 
              count: count + 1,                                                   // update count by 1
              treasury_address,
              pot_address,
              fee_address,
              winner: new_winner,                                                 // update winner to new_winner
              treasury_price,                                                     // the rest of the fields are checked to make sure they are not updated
              pot_price,
              fee_price,
              slot_start,
              slot_increase,
              divisor 
            }
          ) 
        let is_treasury_paid = get_all_value_to(tx.outputs, treasury_address) |> value_geq(from_lovelace(treasury_price))   // pay treasury
        let is_pot_paid = get_all_value_to(tx.outputs, pot_address)           |> value_geq(from_lovelace(pot_price))        // pay pot
        let is_fee_paid = get_all_value_to(tx.outputs, fee_address)           |> value_geq(from_lovelace(fee_price))        // pay fee
        is_output_value_clean? && is_datum_updated? && is_treasury_paid? && is_pot_paid? && is_fee_paid?                    // final validation
      }
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

//  tests

const count_standard = 0                                                   // standard game logic
const treasury_address_standard = mock_script_address(0, None)
const pot_address_standard = mock_script_address(1, None)
const fee_address_standard = mock_pub_key_address(2, None)
const winner_standard = mock_pub_key_hash(3)
const treasury_price_standard = 100_000_000
const pot_price_standard = 4_000_000
const fee_price_standard = 2_000_000
const slot_start_standard = 0
const slot_increase_standard = 1200
const divisor_standard = 2

pub type DatumTestCase {                                                   //  type for datum_with_updates
  count: Option<Int>,
  treasury_address: Option<Address>,
  pot_address: Option<Address>,
  fee_address: Option<Address>,
  winner: Option<ByteArray>,
  treasury_price: Option<Int>,
  pot_price: Option<Int>,
  fee_price: Option<Int>,
  slot_start: Option<Int>,
  slot_increase: Option<Int>,
  divisor: Option<Int>,
}

pub fn datum_with_updates(test_case: DatumTestCase) -> OracleDatum {      // reuseable helper function to create a datum with updates or use a standard value by passing None
  let DatumTestCase { count, treasury_address, pot_address, fee_address, winner, treasury_price, pot_price, fee_price, slot_start, slot_increase, divisor } = test_case  
  OracleDatum {
    count: when count is {
      Some(x) -> x                                                        // if count is provided, use it
      None -> count_standard                                              // else use a standard value
    },
    treasury_address: when treasury_address is {
      Some(x) -> x                                                        // if treasury address is provided, use it
      None -> treasury_address_standard                                   // else use a standard value
    },      
    pot_address: when pot_address is {
      Some(x) -> x                                                        // etc
      None -> pot_address_standard
    },
    fee_address: when fee_address is {
      Some(x) -> x
      None -> fee_address_standard
    },
    winner: when winner is {
      Some(x) -> x
      None -> winner_standard
    },
    treasury_price: when treasury_price is {
      Some(x) -> x
      None -> treasury_price_standard
    },
    pot_price: when pot_price is {
      Some(x) -> x
      None -> pot_price_standard
    },
    fee_price: when fee_price is {
      Some(x) -> x
      None -> fee_price_standard
    },
    slot_start: when slot_start is {
      Some(x) -> x
      None -> slot_start_standard
    },
    slot_increase: when slot_increase is {
      Some(x) -> x
      None -> slot_increase_standard
    },
    divisor: when divisor is {
      Some(x) -> x
      None -> divisor_standard
    },
  }
}

const oracle_utxo_input_standard = from_asset(mock_policy_id(0), "", 1) |> add("", "", 2_000_000)  // standard oracle utxo input
const redeemer_standard = MintDsNFT { winner: mock_pub_key_hash(3) }                               // standard redeemer to reuse
const datum_standard = 
  datum_with_updates(
    DatumTestCase {                                                       // standard input datum to resuse
      count: None,
      treasury_address: None,
      pot_address: None,
      fee_address: None,
      winner: None,
      treasury_price: None,
      pot_price: None,
      fee_price: None,
      slot_start: None,
      slot_increase: None,
      divisor: None,
    }
  )
const datum_standard_output = 
  datum_with_updates(
    DatumTestCase {                                                      // standard output datum to resuse with count + 1 and new winner
      count: Some(1),                                                    // count + 1
      treasury_address: None,
      pot_address: None,
      fee_address: None,
      winner: Some(mock_pub_key_hash(3)),                                // new winner
      treasury_price: None,
      pot_price: None,
      fee_price: None,
      slot_start: None,
      slot_increase: None,
      divisor: None,
    }
  )

type MintTestCase {                                                      // type for mock_mint_tx
  is_oracle_output_clean: Bool,
  is_fee_paid: Bool,
  is_count_updated: Bool,
  is_treasury_paid: Bool,
  is_pot_paid: Bool,
}

fn mock_mint_tx(test_case: MintTestCase) -> Transaction {                                                // main reuseable tx return function
  let MintTestCase { 
      is_oracle_output_clean,
      is_fee_paid,
      is_count_updated,
      is_treasury_paid,
      is_pot_paid 
    } = test_case
  mocktail_tx()                                                                                          // return a tx
    |> tx_in(True, mock_tx_hash(0), 0, oracle_utxo_input_standard, mock_script_address(0, None))         // oracle nft input
    |> tx_in_inline_datum(True, datum_standard)                                                          // oracle input datum
    |> tx_out(is_oracle_output_clean, mock_script_address(0, None), oracle_utxo_input_standard)          // oracle nft output
    |> tx_out(                                                                                           // optional additional (malicious) oracle nft output adding mock 1
        !is_oracle_output_clean,                                                                        
        mock_script_address(0, None), 
        oracle_utxo_input_standard |> add(mock_policy_id(1), "", 1))             
    |> tx_out_inline_datum(is_count_updated,datum_standard_output)                                       // standard output datum with count + 1 and new winner 
    |> tx_out_inline_datum(                                                                              // optional additional (malicious) output datum with count + 10 
        !is_count_updated,
        datum_with_updates(
          DatumTestCase { 
            count: Some(10),                                                                             // count + 10
            treasury_address: None,
            pot_address: None,
            fee_address: None,
            winner: None,
            treasury_price: None,
            pot_price: None,
            fee_price: None,
            slot_start: None,
            slot_increase: None,
            divisor: None,
          }
        )
      )
    |> mint(True, 1, mock_policy_id(1), "0")
    |> tx_out(is_treasury_paid, mock_script_address(0, None), from_lovelace(treasury_price_standard))    // pay treasury
    |> tx_out(is_pot_paid, mock_script_address(1, None), from_lovelace(pot_price_standard))              // pay pot
    |> tx_out(is_fee_paid, mock_pub_key_address(2, None), from_lovelace(fee_price_standard))             // pay fee
    |> complete()
}

test success_spend_oracle() {
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
  oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_with_unclean_output() {
  let tx = 
    mock_mint_tx(
      MintTestCase {    
        is_oracle_output_clean: False,      // oracle output is not clean
        is_fee_paid: True,
        is_count_updated: True,
        is_treasury_paid: True,
        is_pot_paid: True,
      })
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_without_fee_paid() {
  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: False,                 // fee not paid
        is_count_updated: True,
        is_treasury_paid: True,
        is_pot_paid: True,
      },
    )
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_without_count_updated() {
  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: True,
        is_count_updated: False,          // count not updated
        is_treasury_paid: True,
        is_pot_paid: True,
      },
    )
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_without_treasury_paid() {
  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: True,
        is_count_updated: True,
        is_treasury_paid: False,          // treasury not paid
        is_pot_paid: True,
      },
    )
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_without_pot_paid() {
  let tx =
    mock_mint_tx(
      MintTestCase {
        is_oracle_output_clean: True,
        is_fee_paid: True,
        is_count_updated: True,
        is_treasury_paid: True,
        is_pot_paid: False,               // pot not paid
      },
    )
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

                                          // we are no longer using mock_mint_tx, instead showing more granular examples 
test fail_spend_oracle_with_not_enough_treasury_payment() {
  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, oracle_utxo_input_standard, mock_script_address(0, None)) 
    |> tx_in_inline_datum(True, datum_standard)
    |> tx_out(True, mock_script_address(0, None), oracle_utxo_input_standard)
    |> tx_out_inline_datum(True, datum_standard_output)
    |> mint(True, 1, mock_policy_id(1), "0")
    |> tx_out(True, mock_pub_key_address(2, None), from_lovelace(fee_price_standard))       
    |> tx_out(True, mock_script_address(0, None), from_lovelace(50_000_000))                // Insufficient treasury payment
    |> tx_out(True, mock_script_address(1, None), from_lovelace(pot_price_standard))        
    |> complete()
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_with_not_enough_pot_payment() {
  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, oracle_utxo_input_standard, mock_script_address(0, None)) 
    |> tx_in_inline_datum(True, datum_standard)
    |> tx_out(True, mock_script_address(0, None), oracle_utxo_input_standard)
    |> tx_out_inline_datum(True, datum_standard_output)
    |> mint(True, 1, mock_policy_id(1), "0")
    |> tx_out(True, mock_pub_key_address(2, None), from_lovelace(fee_price_standard))       
    |> tx_out(True, mock_script_address(0, None), from_lovelace(treasury_price_standard))   
    |> tx_out(True, mock_script_address(1, None), from_lovelace(3_000_000))                 // Insufficient pot payment
    |> complete()
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_with_malicious_output_datum() {
  let malicious_output_datum = 
    datum_with_updates(
      DatumTestCase {                                                                       // create a bad output datum by changing any of the fields 
        count: Some(1),
        treasury_address: None,
        pot_address: Some(mock_script_address(13, None)),                                   // example changing the pot address to mock 13
        fee_address: None,
        winner: None,
        treasury_price: None,
        pot_price: None,
        fee_price: None,
        slot_start: None,
        slot_increase: None,
        divisor: None,
      }
    )
  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, oracle_utxo_input_standard, mock_script_address(0, None))   
    |> tx_in_inline_datum(True, datum_standard)                                             // normal datum input
    |> tx_out(True, mock_script_address(0, None), oracle_utxo_input_standard)               
    |> tx_out_inline_datum(True, malicious_output_datum)                                    // malicious datum output
    |> mint(True, 1, mock_policy_id(1), "0")
    |> tx_out(True, mock_pub_key_address(2, None), from_lovelace(fee_price_standard))
    |> tx_out(True, mock_script_address(0, None), from_lovelace(treasury_price_standard))
    |> tx_out(True, mock_script_address(1, None), from_lovelace(pot_price_standard))
    |> complete()
  !oracle.spend(Some(datum_standard), redeemer_standard, mock_utxo_ref(0, 0), tx)
}

test fail_spend_oracle_with_wrong_redeemer() {
  let redeemer_wrong = MintDsNFT { winner: mock_pub_key_hash(14) }
  let tx = mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, oracle_utxo_input_standard, mock_script_address(0, None))
    |> tx_in_inline_datum(True, datum_standard)
    |> tx_out(True, mock_script_address(0, None), oracle_utxo_input_standard)
    |> tx_out_inline_datum(True, datum_with_updates(DatumTestCase{
      count: Some(1),
      treasury_address: None,
      pot_address: None,
      fee_address: None,
      winner: Some(mock_pub_key_hash(4)),                                                     // winner               
      treasury_price: None,
      pot_price: None,
      fee_price: None,
      slot_start: None,
      slot_increase: None,
      divisor: None,
    }))
    |> mint(True, 1, mock_policy_id(1), "0")
    |> tx_out(True, mock_pub_key_address(2, None), from_lovelace(fee_price_standard)) 
    |> tx_out(True, mock_script_address(0, None), from_lovelace(treasury_price_standard)) 
    |> tx_out(True, mock_script_address(1, None), from_lovelace(pot_price_standard))  
    |> complete()
  !oracle.spend(Some(datum_standard), redeemer_wrong, mock_utxo_ref(0, 0), tx)               // wrong redeemer
}