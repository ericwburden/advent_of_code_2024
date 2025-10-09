import common/grid2d
import day20/day20.{type Input, ValidatedInput}
import day20/render
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

type ParseState {
  ParseState(
    cells: List(#(grid2d.Index2D, Bool)),
    start: Option(grid2d.Index2D),
    end: Option(grid2d.Index2D),
  )
}

fn parse_cell(
  state: ParseState,
  index: grid2d.Index2D,
  ch: String,
) -> Result(ParseState, String) {
  let ParseState(cells, start, end) = state

  case ch {
    "#" -> Ok(ParseState([#(index, False), ..cells], start, end))
    "." -> Ok(ParseState([#(index, True), ..cells], start, end))
    "S" ->
      case start {
        None -> Ok(ParseState([#(index, True), ..cells], Some(index), end))
        Some(_) -> Error("Encountered multiple starting positions in the map")
      }
    "E" ->
      case end {
        None -> Ok(ParseState([#(index, True), ..cells], start, Some(index)))
        Some(_) -> Error("Encountered multiple end positions in the map")
      }
    _ -> Error("Unexpected grid character: " <> ch)
  }
}

fn parse_row(
  state: ParseState,
  row: Int,
  line: String,
) -> Result(ParseState, String) {
  let indexed_chars =
    line
    |> string.to_graphemes
    |> list.index_map(fn(ch, col) { #(col, ch) })

  list.fold(indexed_chars, Ok(state), fn(acc, entry) {
    case acc {
      Error(_) -> acc
      Ok(state) -> {
        let #(col, ch) = entry
        let index = grid2d.Index2D(row, col)
        parse_cell(state, index, ch)
      }
    }
  })
}

fn parse_map(contents: String) -> Result(day20.ValidatedInput, String) {
  let trimmed = string.trim(contents)

  case trimmed {
    "" -> Error("Input file was empty")
    _ -> {
      let rows = string.split(trimmed, on: "\n")

      let parse_result =
        rows
        |> list.index_map(fn(line, row) { #(row, line) })
        |> list.fold(Ok(ParseState([], None, None)), fn(acc, entry) {
          case acc {
            Error(_) -> acc
            Ok(state) -> {
              let #(row, line) = entry
              parse_row(state, row, line)
            }
          }
        })

      use state <- result.try(parse_result)
      let ParseState(cells, start, end) = state

      case start, end {
        Some(start), Some(end) -> {
          let grid = cells |> list.reverse |> grid2d.from_list
          Ok(ValidatedInput(grid, start, end))
        }
        None, _ -> Error("Map is missing the starting position 'S'")
        _, None -> Error("Map is missing the end position 'E'")
      }
    }
  }
}

pub fn read_input(input_path) -> Input {
  let read_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read file at " <> input_path })

  use contents <- result.try(read_result)
  parse_map(contents)
}

pub fn main() {
  let assert Ok(validated_input) = day20.example1_path |> read_input
  validated_input |> render.render |> io.println
}
