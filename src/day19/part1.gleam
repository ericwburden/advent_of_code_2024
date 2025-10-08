import day19/day19.{type Input, type Output}
import day19/parse
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

/// Decide whether a single arrangement string can be built from the available
/// towel patterns, trimming away any blank entries first.
fn can_compose_arrangement(towels: List(String), arrangement: String) -> Bool {
  let usable_towels =
    towels
    |> list.map(string.trim)
    |> list.filter(fn(towel) { string.length(towel) > 0 })

  let normalized_arrangement = string.trim(arrangement)

  let #(result, _) =
    can_compose_arrangement_go(
      usable_towels,
      normalized_arrangement,
      dict.new(),
    )
  result
}

/// Memoised recursive worker that checks whether `arrangement` is composable.
fn can_compose_arrangement_go(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  case dict.get(memo, arrangement) {
    // Found a cached answer; reuse it immediately.
    Ok(result) -> #(result, memo)
    // Not cached yet, so evaluate the arrangement from scratch.
    Error(Nil) -> evaluate_arrangement(towels, arrangement, memo)
  }
}

/// Handle base-case empty strings and update the memo after exploring towels.
fn evaluate_arrangement(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  case string.length(arrangement) == 0 {
    // Empty string means we've matched everything successfully.
    True -> {
      let updated = dict.insert(memo, arrangement, True)
      #(True, updated)
    }
    // Otherwise, test every towel prefix in search of a match.
    False -> {
      let #(success, search_memo) =
        try_towel_prefixes(towels, arrangement, memo)
      let final_memo = dict.insert(search_memo, arrangement, success)
      #(success, final_memo)
    }
  }
}

/// Iterate through the towels until one successfully matches as a prefix.
fn try_towel_prefixes(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Bool),
) -> #(Bool, dict.Dict(String, Bool)) {
  list.fold(towels, #(False, memo), fn(acc, towel) {
    let #(already_found, current_memo) = acc

    case already_found {
      // Bail out early once a successful prefix has been found.
      True -> #(True, current_memo)
      // Keep searching with the remaining towels.
      False -> attempt_with_towel(towels, arrangement, towel, current_memo)
    }
  })
}

/// Attempt to consume `arrangement` using `towel` as the current prefix.
fn attempt_with_towel(
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
      can_compose_arrangement_go(towels, remainder, memo)
    }
  }
}

/// Count how many arrangements can be constructed from the available towels.
pub fn solve(input: Input) -> Output {
  use #(towels, arrangements) <- result.try(input)

  arrangements
  |> list.filter(fn(arrangement) {
    can_compose_arrangement(towels, arrangement)
  })
  |> list.length
  |> Ok
}

/// Default entry point wired up to the shared runner expectations.
pub fn main() -> Output {
  day19.input_path |> parse.read_input |> solve |> echo
}
