import common/grid2d
import day18/day18.{type Input}
import day18/parse
import day18/part1
import gleam/int
import gleam/list
import gleam/result
import gleam/set

fn path_still_exists(
  corrupted_bytes: set.Set(grid2d.Index2D),
  start: grid2d.Index2D,
  end: grid2d.Index2D,
  grid_size: Int,
) -> Bool {
  case part1.find_shortest_path(corrupted_bytes, start, end, grid_size) {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn binary_search_for_blocking_byte(
  byte_positions: List(grid2d.Index2D),
  already_dropped: Int,
  grid_size: Int,
  start: grid2d.Index2D,
  end: grid2d.Index2D,
) -> Result(grid2d.Index2D, Nil) {
  binary_search_for_blocking_byte_go(
    byte_positions,
    grid_size,
    start,
    end,
    already_dropped,
    list.length(byte_positions),
  )
}

fn binary_search_for_blocking_byte_go(
  bytes: List(grid2d.Index2D),
  grid_size: Int,
  start: grid2d.Index2D,
  end: grid2d.Index2D,
  low: Int,
  high: Int,
) -> Result(grid2d.Index2D, Nil) {
  case low < high {
    False -> byte_at_index(bytes, low)
    True -> {
      let mid = low + int.bitwise_shift_right(high - low, 1)
      let corrupted_bytes = bytes |> list.take(mid) |> set.from_list
      let keep_searching = fn(l, h) {
        binary_search_for_blocking_byte_go(bytes, grid_size, start, end, l, h)
      }
      case path_still_exists(corrupted_bytes, start, end, grid_size) {
        True -> keep_searching(mid + 1, high)
        False -> keep_searching(low, mid)
      }
    }
  }
}

fn byte_at_index(
  bytes: List(grid2d.Index2D),
  idx: Int,
) -> Result(grid2d.Index2D, Nil) {
  case list.drop(bytes, idx - 1) {
    [next, ..] -> Ok(next)
    _ -> Error(Nil)
  }
}

pub fn solve(
  input: Input,
  grid_size: Int,
  num_bytes: Int,
) -> Result(String, String) {
  use byte_positions <- result.try(input)
  let start = grid2d.Index2D(0, 0)
  let end = grid2d.Index2D(grid_size, grid_size)

  binary_search_for_blocking_byte(
    byte_positions,
    num_bytes,
    grid_size,
    start,
    end,
  )
  |> result.map(fn(idx) {
    int.to_string(idx.col) <> "," <> int.to_string(idx.row)
  })
  |> result.map_error(fn(_) { "Could not find a blocking byte!" })
}

pub fn main() -> Result(String, String) {
  day18.input_path |> parse.read_input |> solve(70, 1024) |> echo
}
