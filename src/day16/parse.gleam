import common/grid2d
import day16/day16.{
  type Direction, type Input, type ValidInput, East, ValidInput, example2_path,
}
import gleam/int
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

fn empty_state() -> ParseState {
  ParseState(None, None, set.new())
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
    |> list.fold(Ok(empty_state()), fn(acc, entry) {
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

fn map_bounds(points: List(grid2d.Index2D)) -> #(Int, Int, Int, Int) {
  case points {
    [] -> #(0, 0, 0, 0)
    [first, ..rest] -> {
      let grid2d.Index2D(first_row, first_col) = first
      list.fold(
        rest,
        #(first_row, first_row, first_col, first_col),
        fn(acc, index) {
          let #(min_row, max_row, min_col, max_col) = acc
          let grid2d.Index2D(row, col) = index
          #(
            int.min(row, min_row),
            int.max(row, max_row),
            int.min(col, min_col),
            int.max(col, max_col),
          )
        },
      )
    }
  }
}

fn tile_to_char(valid_input: ValidInput, index: grid2d.Index2D) -> String {
  let ValidInput(start, end, walls) = valid_input
  let #(start_index, _) = start
  case index == start_index {
    True -> "S"
    False ->
      case index == end {
        True -> "E"
        False ->
          case set.contains(walls, index) {
            True -> "#"
            False -> "."
          }
      }
  }
}

/// Renders the parsed map back into text. Useful for debugging or ensuring
/// round-tripping works the way we expect.
pub fn render_map(valid_input: ValidInput) -> String {
  let ValidInput(start, end, walls) = valid_input
  let #(start_index, _) = start

  let points = [start_index, end, ..set.to_list(walls)]
  let #(min_row, max_row, min_col, max_col) = map_bounds(points)

  list.range(min_row, max_row)
  |> list.map(fn(row) {
    list.range(min_col, max_col)
    |> list.map(fn(col) { tile_to_char(valid_input, grid2d.Index2D(row, col)) })
    |> string.join("")
  })
  |> string.join("\n")
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
  input |> render_map |> io.println
}
