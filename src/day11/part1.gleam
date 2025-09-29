import common/fns
import day11/day11.{type Input, type Output}
import day11/parse
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result

/// For today's puzzle, we're going to keep track of the count of stones of a 
/// particular number by population. This puzzle is giving me lanternfish
/// vibes...
pub type StoneCounts =
  dict.Dict(Int, Int)

/// Given an integer, split it's digits cleanly in half if the number of 
/// digits is even. Otherwise, return an error.
fn split_number(n: Int) -> Result(#(Int, Int), Nil) {
  let digits = fns.n_digits(n)
  case int.is_even(digits) {
    True -> {
      let half = digits / 2
      let pow = fns.int_pow(10, half)
      Ok(#(n / pow, n % pow))
    }
    False -> Error(Nil)
  }
}

/// Handy helper function to update the count of a particular stone in our
/// listing of counts by stone. Given a `stone` and the `count` of that stone,
/// either insert that count into the listing if it doesn't exist, or add it to
/// the existing count if there are already stones of that number listed.
pub fn add_to_count(
  stone_counts: StoneCounts,
  stone: Int,
  count: Int,
) -> StoneCounts {
  dict.upsert(stone_counts, stone, fn(maybe_value) {
    case maybe_value {
      option.Some(value) -> value + count
      option.None -> count
    }
  })
}

/// Blink one time and produce a whole new generation of stones! Every blink,
/// all the stones will progress through the transformations indicated, 
/// producing a whole new listing of stone counts.
fn blink(stone_counts: StoneCounts) -> StoneCounts {
  // For each type of stone we're keeping track of...
  dict.fold(stone_counts, dict.new(), fn(acc, stone, count) {
    case stone {
      // For '0' stones, switch them to '1' stones.
      0 -> add_to_count(acc, 1, count)

      _ ->
        case split_number(stone) {
          // For stones with an odd number of digits, multiply their count
          // by 2024.
          Error(_) -> add_to_count(acc, stone * 2024, count)

          // For stones with an even number of digits, split the number and 
          // add stones with the leftmost and rightmost digits to the counts.
          Ok(#(left, right)) ->
            acc |> add_to_count(left, count) |> add_to_count(right, count)
        }
    }
  })
}

/// Blink once, shame on me, blink a whole bunch of times, shame on...you?
/// Ok, there's really no shame involved, just a recursive function that 
/// will blink multiple times in a row.
pub fn blink_n(stone_counts: StoneCounts, blinks: Int) -> StoneCounts {
  case blinks {
    0 -> stone_counts
    _ -> blink_n(blink(stone_counts), blinks - 1)
  }
}

/// To solve part 1 of today's puzzle, we create a listing of stone number and
/// the count of those stones (which will be 1 for every stone at the start).
/// Each time we blink, all the stones of a certain number will transform. It
/// would be wasteful to track each stone individually, since we don't care
/// about their relative positions, just the population counts. Blink 25 times
/// and see the result!
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  // The initial count of stones of each number is 1, so this helper function
  // adds a count of one to our [StoneCounts].
  let init_count = fn(counts, stone) { add_to_count(counts, stone, 1) }

  // Create the initial population count of stones, blink 25 times, then add
  // up the counts of all the kinds of stones to get the final result.
  let counts =
    input
    |> list.fold(dict.new(), init_count)
    |> blink_n(25)
    |> dict.values
    |> int.sum

  Ok(counts)
}

pub fn main() {
  day11.input_path
  |> parse.read_input
  |> solve
  |> io.debug
}
