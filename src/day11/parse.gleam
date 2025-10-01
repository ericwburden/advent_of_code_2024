import day11/day11.{type Input}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// The input file for Day 11 is a space-separate list of integers, so we just
/// need to read the file, split on spaces, and convert each string to an Int.
/// Most of the code in this parsing function is there to provide nicer error
/// handling.
pub fn read_input(input_path) -> Input {
  let read_file_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read input file!" })
  use contents <- result.try(read_file_result)

  // Trim to drop the trailing newline, then split on spaces and parse each
  // string as a integer. Fails on any strings that don't parse cleanly.
  contents
  |> string.trim
  |> string.split(" ")
  |> list.fold(Ok([]), fn(acc, n) {
    use nums <- result.try(acc)
    case int.parse(n) {
      Ok(v) -> Ok([v, ..nums])
      Error(_) -> Error("Could not parse " <> n <> " to Int!")
    }
  })
  |> result.map(list.reverse)
}

pub fn main() {
  day11.example1_path |> read_input |> echo
}
