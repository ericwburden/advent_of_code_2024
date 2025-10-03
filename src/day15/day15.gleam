import common/grid2d
import gleam/dict
import gleam/int
import gleam/list
import gleam/string

pub type Tile {
  Robot
  Box
  Wall
}

pub type DoubleTile {
  DoubleRobot
  DoubleWall
  LeftBox
  RightBox
}

pub type Direction {
  Up
  Right
  Down
  Left
}

pub type Input =
  Result(#(grid2d.Grid2D(Tile), grid2d.Index2D, List(Direction)), String)

pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day15/input.txt"

pub const example1_path = "test/day15/examples/example1.txt"

pub const example2_path = "test/day15/examples/example2.txt"

pub fn tile_to_char(tile: Tile) -> String {
  case tile {
    Robot -> "@"
    Box -> "O"
    Wall -> "#"
  }
}

pub fn double_tile_to_char(tile: DoubleTile) -> String {
  case tile {
    DoubleRobot -> "@"
    DoubleWall -> "#"
    LeftBox -> "["
    RightBox -> "]"
  }
}

fn grid_bounds(grid: grid2d.Grid2D(a)) -> #(Int, Int, Int, Int) {
  let cells = dict.to_list(grid)

  list.fold(cells, #(0, 0, 0, 0), fn(acc, entry) {
    let #(min_row, max_row, min_col, max_col) = acc
    let #(grid2d.Index2D(r, c), _) = entry
    #(
      int.min(r, min_row),
      int.max(r, max_row),
      int.min(c, min_col),
      int.max(c, max_col),
    )
  })
}

pub fn render_grid(grid: grid2d.Grid2D(a), char_fn: fn(a) -> String) -> String {
  let #(min_row, max_row, min_col, max_col) = grid_bounds(grid)

  let char_grid =
    list.range(min_row, max_row)
    |> list.map(fn(row) {
      list.range(min_col, max_col)
      |> list.map(fn(col) {
        let index = grid2d.Index2D(row, col)
        case grid2d.get(grid, index) {
          Ok(value) -> char_fn(value)
          Error(_) -> "."
        }
      })
    })

  char_grid |> list.map(fn(row) { string.join(row, "") }) |> string.join("\n")
}
