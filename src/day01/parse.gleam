import day01/day01.{type Input}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Parse a line of the input into a tuple of integers
/// 
/// The input file contains lines like "123   456". This function splits that line
/// on the three spaces in between the numbers, parses the left and right sides into
/// numbers, and returns the two numbers as a tuple. If any issues arise, return an 
/// error string describing the error.
pub fn parse_line(line: String) -> Result(#(Int, Int), String) {
  // Attempt to split the line on three spaces
  let split_result =
    string.split_once(line, "   ")
    |> result.replace_error("Could not split: " <> line)

  // The `use` syntax is a _bit_ wonky, but essentially this is how Gleam lets you
  // short-circuit the rest of the function when encountering an error. It's not 
  // _really_ returning early (I don't think), it's just syntax sugar to avoid
  // excessive indentation with match statements.
  use #(s1, s2) <- result.try(split_result)

  // Parse the left and right numbers, or provide an informative error message if
  // either can't be parsed.
  let left_number_result =
    int.parse(s1) |> result.replace_error("Could not parse an Int from: " <> s1)
  let right_number_result =
    int.parse(s2) |> result.replace_error("Could not parse an Int from: " <> s2)

  // Here's that `use` syntax again. Note the `result.map` instead of the `result.try`
  // in the last fallible operation. This is needed to avoid returning an explicit
  // "Ok(#(left_number, right_number))", although that would work, too.
  use left_number <- result.try(left_number_result)
  use right_number <- result.map(right_number_result)
  #(left_number, right_number)
}

/// Read the input file from disk and parse the lines
/// 
/// Parses the entire input file into a list of #(Int, Int) tuples or provides an
/// error message if that fails.
pub fn read_input(input_path) -> Input {
  // Attempt to read the input file from disk, providing an error message if that
  // fails.
  let try_read_file =
    simplifile.read(input_path)
    |> result.map(string.trim_end)
    |> result.replace_error("Could not read file at: " <> input_path)
  use contents <- result.try(try_read_file)

  // Parse each line into the format needed for today's puzzles. Because the parsing
  // operation can return an error, we use `result.all` at the end to convert a
  // List(Result(#(Int, Int), String)) to a Result(List(#(Int, Int)), String).
  string.split(contents, on: "\n")
  |> list.map(parse_line)
  |> result.all
}
