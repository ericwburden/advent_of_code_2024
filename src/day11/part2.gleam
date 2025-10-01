import day11/day11.{type Input, type Output}
import day11/parse
import day11/part1.{add_to_count, blink_n}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result

/// It's exactly the same as part 1, just bigger! It's a good thing we went
/// with population counts in part 1, because there's no way we'd be able to 
/// track all the individual stones through 75 whole blinks.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)

  let init_count = fn(counts, stone) { add_to_count(counts, stone, 1) }

  // Exactly the same as before, just with more blinks!
  let counts =
    input
    |> list.fold(dict.new(), init_count)
    |> blink_n(75)
    |> dict.values
    |> int.sum

  Ok(counts)
}

pub fn main() {
  day11.input_path
  |> parse.read_input
  |> solve
  |> echo
}
