import common/grid2d.{type Index2D, Index2D}
import day12/day12.{type Input}
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Parse a single `line` from the input file, given a `row` index, returns
/// a list of entries for the final mapping of [Index2D] to plot label.
fn parse_line(line: String, row: Int) -> List(#(Index2D, UtfCodepoint)) {
  line
  |> string.to_utf_codepoints
  |> list.index_map(fn(ch, col) { #(Index2D(row, col), ch) })
}

/// Reads the input file line-by-line, producing a [Dict] containing a mapping
/// of plot locations to their labels.
pub fn read_input(input_path) -> Input {
  let read_file_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read input file!" })

  use contents <- result.try(read_file_result)

  // Parse the file one line at a time, including row and column indices
  let input =
    contents
    |> string.split("\n")
    |> list.index_map(parse_line)
    |> list.flatten
    |> dict.from_list

  Ok(input)
}

pub fn main() {
  day12.example1_path |> read_input |> io.debug
}
