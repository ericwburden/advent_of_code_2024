import common/grid2d
import day10/day10.{type Input}
import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn parse_line(line: String, row: Int) -> List(#(grid2d.Index2D, Int)) {
  line
  |> string.to_graphemes
  |> list.index_map(fn(ch, col) {
    case int.parse(ch) {
      Ok(n) -> Ok(#(grid2d.Index2D(row, col), n))
      Error(_) -> Error(Nil)
    }
  })
  |> list.filter_map(fn(x) { x })
}

pub fn read_input(input_path) -> Input {
  let assert Ok(contents) = simplifile.read(input_path)
  string.split(contents, on: "\n")
  |> list.index_map(parse_line)
  |> list.flatten
  |> dict.from_list
}

pub fn main() {
  day10.example1_path
  |> read_input
  |> echo
}
