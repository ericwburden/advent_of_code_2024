import common/grid2d
import day16/day16.{
  type Direction, type Input, type ValidInput, East, ValidInput, example2_path,
}
import day16/render
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set
import gleam/string
import simplifile

type ParseState {
  ParseState(
    start: Option(#(grid2d.Index2D, Direction)),
    end: Option(grid2d.Index2D),
    walls: set.Set(grid2d.Index2D),
  )
}

/// Takes a single glyph from the input grid and updates the parse state to
/// reflect what we saw. Walls get dropped into the set, start and end positions
/// are recorded exactly once, and empty spaces fall straight through.
fn parse_cell(
  state: ParseState,
  index: grid2d.Index2D,
  ch: String,
) -> Result(ParseState, String) {
  let ParseState(start, end, walls) = state
  case ch {
    "#" -> Ok(ParseState(start, end, set.insert(walls, index)))
    "." -> Ok(state)
    "S" ->
      case start {
        None -> Ok(ParseState(Some(#(index, East)), end, walls))
        Some(_) -> Error("Encountered multiple starting positions in the map")
      }
    "E" ->
      case end {
        None -> Ok(ParseState(start, Some(index), walls))
        Some(_) -> Error("Encountered multiple end positions in the map")
      }
    _ -> Error("Unexpected grid character: " <> ch)
  }
}

/// Parses a single row of the map, walking each character in order and
/// threading the parse state forward.
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

/// Consumes the entire grid, ensuring we saw one start and one end and bundling
/// everything up into the puzzle's `ValidInput` structure.
fn parse_map(text: String) -> Result(ValidInput, String) {
  let rows =
    text
    |> string.trim
    |> string.split(on: "\n")

  let parse_result =
    rows
    |> list.index_map(fn(line, row) { #(row, line) })
    |> list.fold(Ok(ParseState(None, None, set.new())), fn(acc, entry) {
      case acc {
        Error(_) -> acc
        Ok(state) -> {
          let #(row, line) = entry
          parse_row(state, row, line)
        }
      }
    })

  use state <- result.try(parse_result)

  let ParseState(start, end, walls) = state

  case start, end {
    Some(start), Some(end) -> Ok(ValidInput(start, end, walls))
    None, _ -> Error("Map is missing the starting position 'S'")
    _, None -> Error("Map is missing the end position 'E'")
  }
}

/// Reads the raw puzzle input from disk and hands it off to the map parser,
/// translating any I/O failures into friendly error messages along the way.
pub fn read_input(input_path) -> Input {
  let read_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read input file" })

  use contents <- result.try(read_result)
  parse_map(contents)
}

pub fn main() {
  let assert Ok(input) = example2_path |> read_input
  input |> render.render_map |> io.println
}
