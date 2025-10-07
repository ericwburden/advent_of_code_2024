import common/grid2d
import day18/day18.{type Input}
import day18/parse
import day18/part1
import gleam/int
import gleam/list
import gleam/result

fn grid_after_drops(
  grid_size: Int,
  byte_positions: List(grid2d.Index2D),
  count: Int,
) -> grid2d.Grid2D(Bool) {
  let bytes_to_apply = list.take(byte_positions, count)
  list.fold(bytes_to_apply, part1.empty_grid(grid_size), part1.corrupt_grid_at)
}

fn path_still_exists(
  grid_size: Int,
  byte_positions: List(grid2d.Index2D),
  count: Int,
  start: grid2d.Index2D,
  end: grid2d.Index2D,
) -> Bool {
  let grid = grid_after_drops(grid_size, byte_positions, count)
  case part1.find_shortest_path(grid, start, end) {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn search_blocking_count(
  grid_size: Int,
  byte_positions: List(grid2d.Index2D),
  start: grid2d.Index2D,
  end: grid2d.Index2D,
  low: Int,
  high: Int,
) -> Int {
  case low < high {
    False -> low
    True -> {
      let mid = low + int.bitwise_shift_right(high - low, 1)
      case path_still_exists(grid_size, byte_positions, mid, start, end) {
        True ->
          search_blocking_count(
            grid_size,
            byte_positions,
            start,
            end,
            mid + 1,
            high,
          )
        False ->
          search_blocking_count(grid_size, byte_positions, start, end, low, mid)
      }
    }
  }
}

pub fn solve(
  input: Input,
  grid_size: Int,
  num_bytes: Int,
) -> Result(String, String) {
  use byte_positions <- result.try(input)
  let total_bytes = list.length(byte_positions)
  let start = grid2d.Index2D(0, 0)
  let end = grid2d.Index2D(grid_size, grid_size)

  case path_still_exists(grid_size, byte_positions, num_bytes, start, end) {
    False -> Error("The initial prefix already blocks the exit")
    True -> {
      case
        path_still_exists(grid_size, byte_positions, total_bytes, start, end)
      {
        True -> Error("Even the full corruption leaves a path open")
        False -> {
          let blocking_count =
            search_blocking_count(
              grid_size,
              byte_positions,
              start,
              end,
              num_bytes + 1,
              total_bytes,
            )
          case list.drop(byte_positions, blocking_count - 1) {
            [grid2d.Index2D(row, col), ..] ->
              Ok(int.to_string(col) <> "," <> int.to_string(row))
            [] -> Error("Blocking byte index out of bounds")
          }
        }
      }
    }
  }
}

pub fn main() -> Result(String, String) {
  day18.input_path |> parse.read_input |> solve(70, 1024) |> echo
}
