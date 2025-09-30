import common/grid2d
import day12/day12.{type Input}
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_line(line: String, row: Int) -> List(#(grid2d.Index2D, UtfCodepoint)) {
  line
  |> string.to_utf_codepoints
  |> list.index_map(fn(ch, col) { #(grid2d.Index2D(row, col), ch) })
}

pub fn read_input(input_path) -> Input {
  let read_file_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read input file!" })

  use contents <- result.try(read_file_result)

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
