import day19/day19.{type Input, type Output}
import day19/parse
import gleam/dict
import gleam/list
import gleam/result
import gleam/string

/// Compute how many distinct arrangements of `towels` can be used to produce a
/// given `arrangement`, caching the known partial counts in `memo` for speed!
/// This algorithm mirrors the one used in Part 1, with the distinction that
/// now we're evaluating all possible combinations from `towels` and returning
/// the count instead of just verifying that one exists.
fn count_arrangement_ways(towels: List(String), arrangement: String) -> Int {
  let #(result, _) =
    count_arrangement_ways_go_step1(towels, arrangement, dict.new())
  result
}

/// Step 1 of the recursive depth-first search. The `memo` dictionary contains
/// a list of prefixes tried and how many times that prefix has already been
/// evaluated to be a part of the total arrangement. This handles situations
/// like:
/// 
///   - towels = ["ab", "a", "b"]
///   - arrangement = "abab"
/// 
/// In this case, "ab" is tried first and the recursive algorithm tries every
/// combination that is prefixed with "ab", finding that "ab" + "a" + "b" will
/// produce the arrangement, adding ("ab" -> 1), ("aba" -> 1), and ("abab" -> 1)
/// to the `memo`. When "a" and then "b" are tried, we already see the results
/// and update the memo to contain ("a" -> 1), ("ab" -> 2), ("aba" -> 2), and 
/// ("abab" -> 2).
fn count_arrangement_ways_go_step1(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case dict.get(memo, arrangement) {
    // Previously-calculated count for the remaining `arrangement`; return it.
    Ok(existing) -> #(existing, memo)
    // Unseen suffix, so compute the count and store it.
    Error(Nil) -> count_arrangement_ways_go_step2(towels, arrangement, memo)
  }
}

/// Handle empty arrangements and write results back into the memo table.
/// /// Step 2 of the recursive depth-first search. This step checks the 
/// remaining parts of the arrangement (the full arrangement on the first 
/// layer, the remainder of the arrangement minus the tested prefix on 
/// subsequent layers). If the remaining arrangement is empty, that means we've 
/// totally matched that string and we can end the search with a success, which 
/// will add one to all the cumulative prefixes that led to that success.
fn count_arrangement_ways_go_step2(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case arrangement {
    // Only one way to build an empty suffix: stop recursing and return.
    "" -> #(1, memo)

    // We've not exhausted the arrangement yet, so keep checking `towels` as
    // prefixes against the currently remaining `arrangement`.
    _ -> {
      let #(count, updated_memo) =
        count_arrangement_ways_go_step3(towels, arrangement, memo)
      let memo_with_result = dict.insert(updated_memo, arrangement, count)
      #(count, memo_with_result)
    }
  }
}

/// Step 3 of the recursive depth-first search. In this step, we try every
/// towel to see if it can be used to finish filling out the `arrangement`.
/// We keep a running total of the number of ways we've found to fill out
/// the arrangement and return it, along with the updated `memo`.
fn count_arrangement_ways_go_step3(
  towels: List(String),
  arrangement: String,
  memo: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  list.fold(towels, #(0, memo), fn(acc, towel) {
    let #(running_total, current_memo) = acc

    // Gets the count of all the ways we can finish filling out the 
    // `arrangement` starting with `towel`, along with an updated `memo`.
    let #(count, next_memo) =
      count_arrangement_ways_go_step4(towels, arrangement, towel, current_memo)

    #(running_total + count, next_memo)
  })
}

/// Step 4, the final step of the depth-first recursive search. This step
/// performs the individual checks from Step 3. If the `towel` being checked
/// isn't actually a prefix for the remaining `arrangement`, then it won't
/// contribute anything to the count of ways the `arrangement` can be made.
/// If it _is_ a valid prefix for the arrangement we're checking, we trim it
/// from the front of `arrangement` and recurse on the remaining suffix.
fn count_arrangement_ways_go_step4(
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
      count_arrangement_ways_go_step1(towels, remainder, memo)
    }
  }
}

/// In Part 2, we check each towel `arrangement` to count how many different
/// ways it can be composed from the available `towels` and return that
/// cumulative count.
pub fn solve(input: Input) -> Output {
  use #(towels, arrangements) <- result.try(input)

  arrangements
  |> list.map(fn(a) { count_arrangement_ways(towels, a) })
  |> list.fold(0, fn(acc, count) { acc + count })
  |> Ok
}

/// Default entry point wired up to the shared runner expectations.
pub fn main() -> Output {
  day19.input_path |> parse.read_input |> solve |> echo
}
