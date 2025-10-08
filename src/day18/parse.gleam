import common/grid2d
import day18/day18.{type Input}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Parse a decimal string into an `Int`, returning a friendly error instead of
/// panicking on bad input.
fn parse_number(text: String) -> Result(Int, String) {
  case int.parse(text) {
    // Parsed successfully, so forward the numeric value.
    Ok(value) -> Ok(value)
    // Parsing failed; surface a descriptive error message.
    Error(_) -> Error("Could not parse an Int from: " <> text)
  }
}

/// Decode a single `"x,y"` line into an `Index2D`. The first number is treated
/// as the column (x), the second as the row (y).
fn parse_coordinate(line: String) -> Result(grid2d.Index2D, String) {
  let trimmed = string.trim(line)
  let error_message = "Could not parse coordinate line: " <> trimmed

  case string.split(trimmed, on: ",") {
    // Exactly two components; parse them as column and row.
    [col_text, row_text] -> {
      use col <- result.try(parse_number(string.trim(col_text)))
      use row <- result.try(parse_number(string.trim(row_text)))
      Ok(grid2d.Index2D(row: row, col: col))
    }
    // Any other shape indicates malformed input.
    _ -> Error(error_message)
  }
}

/// Parse the full contents of the input file into a list of coordinate indices.
fn parse_contents(contents: String) -> Result(List(grid2d.Index2D), String) {
  contents
  |> string.trim
  |> string.split(on: "\n")
  |> list.filter(fn(line) { string.length(string.trim(line)) > 0 })
  |> list.map(parse_coordinate)
  |> result.all
}

/// Read and parse the Day 18 input file from disk. Each line from the input
/// file is parsed into an [Index2D] that corresponds to the X,Y coordinate
/// given by that line. 
pub fn read_input(input_path) -> Input {
  simplifile.read(input_path)
  |> result.map(string.trim)
  |> result.replace_error("Could not read file at " <> input_path)
  |> result.try(parse_contents)
}

/// Small manual entry point used while developing the parser.
pub fn main() {
  day18.example1_path |> read_input |> echo
}
