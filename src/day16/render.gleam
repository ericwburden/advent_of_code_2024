import common/grid2d
import day16/day16.{type ValidInput, ValidInput}
import gleam/int
import gleam/list
import gleam/set
import gleam/string

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
