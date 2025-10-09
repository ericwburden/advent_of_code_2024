import common/grid2d
import day20/day20.{type ValidatedInput, ValidatedInput}
import gleam/dict
import gleam/int
import gleam/list
import gleam/string

fn grid_bounds(points: List(grid2d.Index2D)) -> #(Int, Int, Int, Int) {
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

fn cell_char(valid_input: ValidatedInput, index: grid2d.Index2D) -> String {
  let ValidatedInput(grid, start, end) = valid_input

  case index == start {
    True -> "S"
    False ->
      case index == end {
        True -> "E"
        False -> {
          let assert Ok(tile) = grid2d.get(grid, index)
          case tile {
            True -> "."
            False -> "#"
          }
        }
      }
  }
}

/// Converts a parsed map back into its textual representation so it can be
/// printed or compared with the original input.
pub fn render(valid_input: ValidatedInput) -> String {
  let ValidatedInput(grid, start, end) = valid_input

  let points =
    grid
    |> dict.to_list
    |> list.map(fn(entry) {
      let #(index, _) = entry
      index
    })
    |> list.append([start, end])

  case points {
    [] -> ""
    [_first, .._rest] -> {
      let #(min_row, max_row, min_col, max_col) = grid_bounds(points)

      list.range(min_row, max_row)
      |> list.map(fn(row) {
        list.range(min_col, max_col)
        |> list.map(fn(col) { cell_char(valid_input, grid2d.Index2D(row, col)) })
        |> string.join("")
      })
      |> string.join("\n")
    }
  }
}
