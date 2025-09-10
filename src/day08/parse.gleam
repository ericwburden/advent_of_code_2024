import common/types.{Index2D}
import day08/day08.{type Antenna, type Input, Antenna, Bounds}
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile

/// Parse a single line from the input file, returning a list of the [Antenna]s
/// that appear on that line.
fn parse_line(row: Int, str: String) -> List(Antenna) {
  string.to_graphemes(str)
  |> list.index_map(fn(char, col) { #(char, col) })
  |> list.filter_map(fn(char_and_col) {
    let #(char, col) = char_and_col
    case char {
      "." -> Error(Nil)
      _ -> Ok(Antenna(char, Index2D(row, col)))
    }
  })
}

/// Read and parse the input file, identifying and returning the [Bouds] of the
/// input grid, the list of [Antenna]s, and an [AntennaeByLable] dict allowing 
/// for easy identification of all [Antenna]s with a particular label.
pub fn read_input(input_path) -> Input {
  let assert Ok(contents) = simplifile.read(input_path)

  // Parse the input file to compile a list of all the [Antenna]
  let antennae =
    string.split(contents, on: "\n")
    |> list.index_map(fn(line, row) { parse_line(row, line) })
    |> list.flatten

  // Re-format the list of [Antenna]s to an [AntennaeByLabel]
  let antennae_by_label =
    antennae
    |> list.fold(dict.new(), fn(acc, antenna) {
      let Antenna(label, _) = antenna
      let existing =
        dict.get(acc, label)
        |> result.unwrap([])
      dict.insert(acc, label, [antenna, ..existing])
    })

  // Measure the input grid and compile into the [Bounds] of the grid
  let rows =
    string.split(contents, on: "\n")
    |> list.filter(fn(s) { s != "" })
    |> list.length
  let cols = case string.split(contents, on: "\n") {
    [] -> 0
    [first, ..] -> string.length(first)
  }
  let bounds = Bounds(rows, cols)

  Ok(#(bounds, antennae, antennae_by_label))
}
