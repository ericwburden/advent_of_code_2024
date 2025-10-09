import day19/day19.{type Input, type Output}
import day19/parse
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

/// Decide whether a single arrangement string can be built from the available
/// towel patterns, trimming away any blank entries first. This is the entry
/// point to a multi-step recursive depth-first search. Each major step was 
/// broken out into an individual function for improved readability.
fn can_compose_arrangement(towels: List(String), arrangement: String) -> Bool {
  let #(result, _) =
    can_compose_arrangement_go_step1(towels, arrangement, dict.new())
  result
}

/// Step 1 of the recursive depth-first search. The `memo` dictionary contains
/// a list of prefixes tried and whether or not that prefix has already been
/// evaluated to be a part of the total arrangment. This handles situations
/// like:
/// 
///   - towels = ["ab", "a", "b"]
///   - arrangment = "abab"
/// 
/// In this case, "ab" is tried first and the recursive algorithm tries every
/// combination that is prefixed with "ab". Thus, when "a" then "b" are tried
/// in future steps, the memo already contains the answer for what will happen
/// with that "ab" prefix.
fn can_compose_arrangement_go_step1(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  case dict.get(memo, arrangement) {
    Ok(result) -> #(result, memo)
    Error(Nil) -> can_compose_arrangement_go_step2(towels, arrangement, memo)
  }
}

/// Step 2 of the recursive depth-first search. This step checks the remaining
/// parts of the arrangement (the full arrangement on the first layer, the 
/// remainder of the arrangment minus the tested prefix on subsequent layers).
/// If the remaining arrangment is empty, that means we've totally matched that
/// string and we can end the search with a success.
fn can_compose_arrangement_go_step2(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  case arrangement {
    // Empty string means we've matched everything successfully. This
    // branch short-circuits the rest of the algorithm and exits, 
    // reporting success.
    "" -> #(True, memo)

    // Otherwise, test every towel prefix against the remaining arrangment for
    // matches.
    _ -> {
      let #(success, next_memo) =
        can_compose_arrangment_go_step3(towels, arrangement, memo)
      let final_memo = dict.insert(next_memo, arrangement, success)
      #(success, final_memo)
    }
  }
}

/// Step 3 of the recursive depth-first search. In this step, we try every
/// towel to see if it has been found to be on the path to successfully 
/// filling out the remaining `arrangment`. If we can tell from the `memo`
/// that we can finish the arrangment with that prefix, we can short-circuit
/// with a positive result.
fn can_compose_arrangment_go_step3(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  list.fold(towels, #(False, memo), fn(acc, towel) {
    case acc {
      // Bail out early once a prefix has been found that we know can be used
      // to successfully fill out the arrangment.
      #(True, current_memo) -> #(True, current_memo)
      // Keep searching with the remaining towels.
      #(False, current_memo) ->
        can_compose_arrangment_go_step4(
          towels,
          arrangement,
          towel,
          current_memo,
        )
    }
  })
}

/// Step 4, the final step of the depth-first recursive search. This step
/// performs the individual checks from Step 3. If the `towel` being checked
/// isn't actually a prefix for the remaining `arrangment`, then we already
/// know it can't contribute to the final arrangment and we can stop there and
/// move on to the next towel. Otherwise, we subtract that prefix from the 
/// current arrangment and recurse on the rest of the arrangment.
fn can_compose_arrangment_go_step4(
  towels: List(String),
  arrangement: String,
  towel: String,
  memo: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  case string.starts_with(arrangement, towel) {
    // Towel does not apply, so it contributes no success.
    False -> #(False, memo)
    // Prefix matches; recurse on the remaining suffix.
    True -> {
      let remainder = string.drop_start(arrangement, string.length(towel))
      can_compose_arrangement_go_step1(towels, remainder, memo)
    }
  }
}

/// In Part 1, we check each towel `arrangement` to see if it can be composed
/// from the collection of `towels`. We report the number of arrangments that
/// can be composed.
pub fn solve(input: Input) -> Output {
  use #(towels, arrangements) <- result.try(input)

  let arrangment_is_possible = fn(arrangement) {
    can_compose_arrangement(towels, arrangement)
  }

  arrangements
  |> list.filter(arrangment_is_possible)
  |> list.length
  |> Ok
}

/// Default entry point wired up to the shared runner expectations.
pub fn main() -> Output {
  day19.input_path |> parse.read_input |> solve |> echo
}
