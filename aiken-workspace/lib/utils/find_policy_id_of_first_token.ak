use aiken/collection/list
use cardano/assets.{PolicyId, flatten}
use cardano/transaction.{Input}

/// Extracts the first non-empty policy ID from an input's value.
/// This is useful for finding the policy ID of the first token in an input.
/// ```aiken
/// expect policy_id = extract_first_policy_id(input)
/// ```
pub fn find_policy_id_of_first_token(input: Input) -> PolicyId {
  expect [(policy_id, _, _)] =
    list.filter(flatten(input.output.value), fn(x) { x.1st != "" })
  policy_id
}
