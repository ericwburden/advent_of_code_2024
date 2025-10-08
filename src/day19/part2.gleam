import day19/day19.{type Input, type Output}
import day19/parse
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

/// Compute how many distinct concatenations of `towels` can recreate
/// `arrangement`, caching partial counts along the way.
fn count_arrangement_ways(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case dict.get(memo, arrangement) {
    // Previously-calculated count; return it immediately.
    Ok(existing) -> #(existing, memo)
    // Unseen suffix, so compute the count and store it.
    Error(Nil) -> evaluate_arrangement(towels, arrangement, memo)
  }
}

/// Handle empty arrangements and write results back into the memo table.
fn evaluate_arrangement(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case string.length(arrangement) == 0 {
    // Only one way to build an empty suffix: stop.
    True -> {
      let updated = dict.insert(memo, arrangement, 1)
      #(1, updated)
    }
    // Sum up the ways contributed by each towel prefix.
    False -> {
      let #(count, updated_memo) =
        sum_towel_prefixes(towels, arrangement, memo)
      let memo_with_result = dict.insert(updated_memo, arrangement, count)
      #(count, memo_with_result)
    }
  }
}

/// Accumulate the total number of compositions each towel contributes.
fn sum_towel_prefixes(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  list.fold(towels, #(0, memo), fn(acc, towel) {
    let #(running_total, current_memo) = acc
    let #(count, next_memo) =
      attempt_with_towel(towels, arrangement, towel, current_memo)
    #(running_total + count, next_memo)
  })
}

/// Attempt to apply `towel` to the front of `arrangement`, returning the count
/// of completions arising from that choice.
fn attempt_with_towel(
  towels: List(String),
  arrangement: String,
  towel: String,
  memo: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case string.starts_with(arrangement, towel) {
    // No match; this towel contributes zero additional arrangements.
    False -> #(0, memo)
    // Matching prefix; recurse on the remaining suffix.
    True -> {
      let remainder = string.drop_start(arrangement, string.length(towel))
      count_arrangement_ways(towels, remainder, memo)
    }
  }
}

/// Sum the number of valid compositions for every arrangement in the input.
pub fn solve(input: Input) -> Output {
  use #(towels, arrangements) <- result.try(input)
  let usable_towels =
    towels
    |> list.map(string.trim)
    |> list.filter(fn(towel) { string.length(towel) > 0 })

  arrangements
  |> list.map(string.trim)
  |> list.filter(fn(arrangement) { string.length(arrangement) > 0 })
  |> list.map(fn(arrangement) {
    let #(count, _) =
      count_arrangement_ways(usable_towels, arrangement, dict.new())
    count
  })
  |> list.fold(0, fn(acc, count) { acc + count })
  |> Ok
}

/// Default entry point wired up to the shared runner expectations.
pub fn main() -> Output {
  day19.input_path |> parse.read_input |> solve |> echo
}
