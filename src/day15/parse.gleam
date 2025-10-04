import common/grid2d
import day15/day15.{
  type Direction, type Input, type Tile, Box, Down, Left, Right, Robot, Up, Wall,
  render_grid, tile_to_char,
}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

/// Takes a single character from the map and decides which warehouse inhabitant
/// it represents. Walls, boxes, and the robot become tiles, while empty spaces
/// quietly disappear with `None` so we can keep the grid sparse.
fn parse_tile(ch: String) -> Result(Option(Tile), String) {
  case ch {
    "#" -> Ok(Some(Wall))
    "O" -> Ok(Some(Box))
    "@" -> Ok(Some(Robot))
    "." -> Ok(None)
    _ -> Error("Unexpected grid character: " <> ch)
  }
}

/// Walks one line of the input grid, turning each interesting character into a
/// `grid2d.Index2D`/`Tile` pair. Empty cells are skipped, and any unexpected
/// glyphs bubble up as a friendly parsing error.
fn parse_grid_row(
  row: Int,
  line: String,
) -> Result(List(#(grid2d.Index2D, Tile)), String) {
  line
  |> string.to_graphemes
  |> list.index_map(fn(ch, col) { #(col, parse_tile(ch)) })
  |> list.fold(Ok([]), fn(acc, col_and_maybe_tile) {
    case acc, col_and_maybe_tile {
      // Errors get propagated forward, starting with the first error
      // encountered from trying to parse a character
      Error(e), _ -> Error(e)
      _, #(_, Error(e)) -> Error(e)

      // If we do parse a valid character and that character represents
      // an empty space, skip it and keep going.
      Ok(entries), #(_, Ok(None)) -> Ok(entries)

      // If we parse a valid character into a wall, box, or robot, then we add
      // an entry for that object along with its index.
      Ok(entries), #(col, Ok(Some(tile))) ->
        Ok([#(grid2d.Index2D(row, col), tile), ..entries])
    }
  })
}

/// Parses the entire warehouse layout into a grid and pinpoints the robot's
/// starting coordinates. We stitch the row results together, build a sparse
/// dict-backed grid, and double-check that the robot actually exists.
fn parse_grid(
  text: String,
) -> Result(#(grid2d.Grid2D(Tile), grid2d.Index2D), String) {
  let entries_result =
    text
    |> string.trim
    |> string.split(on: "\n")
    |> list.index_map(fn(line, row) { parse_grid_row(row, line) })
    |> result.all
    |> result.map(list.flatten)

  use entries <- result.try(entries_result)

  let grid = grid2d.from_list(entries)

  let robot_result =
    entries
    |> list.find_map(fn(entry) {
      let #(index, tile) = entry
      case tile {
        Robot -> Ok(index)
        _ -> Error(Nil)
      }
    })
    |> result.replace_error("Grid is missing the robot location")

  use robot <- result.try(robot_result)
  Ok(#(grid, robot))
}

/// Similar idea for the instruction stream: map arrow glyphs to their matching
/// cardinal directions, complain if anything unexpected sneaks in.
fn parse_direction(ch: String) -> Result(Direction, String) {
  case ch {
    "^" -> Ok(Up)
    ">" -> Ok(Right)
    "v" -> Ok(Down)
    "<" -> Ok(Left)
    _ -> Error("Unexpected direction character: " <> ch)
  }
}

/// Converts the full run of instructions into a directional playlist. We strip
/// whitespace, ignore newlines, and translate each arrow into a `Direction`.
fn parse_directions(text: String) -> Result(List(Direction), String) {
  text
  |> string.trim
  |> string.to_graphemes
  |> list.filter(fn(ch) { ch != "\n" })
  |> list.map(parse_direction)
  |> result.all
}

/// Reads the puzzle input, splitting it into the warehouse map and the list of
/// move instructions. Returns both as a handy tuple, or a friendly error if the
/// text looks nothing like what we expected.
pub fn read_input(input_path) -> Input {
  let read_result =
    simplifile.read(input_path)
    |> result.map_error(fn(_) { "Could not read input file" })

  use contents <- result.try(read_result)

  case string.split(string.trim(contents), on: "\n\n") {
    [grid_text, instruction_text, ..] -> {
      use #(grid, robot) <- result.try(parse_grid(grid_text))
      use directions <- result.try(parse_directions(instruction_text))
      Ok(#(grid, robot, directions))
    }

    _ -> Error("Input is missing either the map or the directions section")
  }
}

pub fn main() {
  let assert Ok(#(grid, _, _)) = day15.example2_path |> read_input
  grid |> render_grid(tile_to_char) |> io.println
}
