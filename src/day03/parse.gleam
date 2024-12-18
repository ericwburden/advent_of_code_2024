import day03/day03.{type Input}
import gleam/result
import gleam/string
import simplifile

/// Today's challenge is really about parsing information from text, so we'll just
/// read in the lines from the file into a list of strings.
pub fn read_input(input_path) -> Input {
  simplifile.read(input_path)
  |> result.map(string.trim)
  |> result.replace_error("Could not read file at " <> input_path)
  |> result.map(fn(x) { string.split(x, "\n") })
}
