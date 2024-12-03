import day02/day02.{type Input, type Report}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Provides a slightly more helpful error message if any string fails to parse
/// an Int.
fn parse_with_err_msg(s: String) -> Result(Int, String) {
  int.parse(s)
  |> result.replace_error("Could not parse a number from " <> s <> "!")
}

/// Parse a single line from the input file into a [Report], which is really
/// just an alias for [List(Int)]. Each line consists of numbers separated by 
/// a single space, like "1 2 3 4 5 6".
fn parse_line(line: String) -> Result(Report, String) {
  line
  |> string.split(on: " ")
  |> list.map(parse_with_err_msg)
  |> result.all
}

/// Read one of the input files and parse the contents into the input format. For
/// today's puzzle, that's a list of lists of integers, where each inner list 
/// represents one report.
pub fn read_input(input_path) -> Input {
  let read_file_result =
    simplifile.read(input_path)
    |> result.replace_error("Could not read file at " <> input_path)
    |> result.map(string.trim)
  use contents <- result.try(read_file_result)
  string.split(contents, on: "\n") |> list.map(parse_line) |> result.all
}
