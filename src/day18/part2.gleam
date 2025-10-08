import common/grid2d
import day18/day18.{type Input}
import day18/parse
import day18/part1
import gleam/int
import gleam/list
import gleam/result
import gleam/set

/// Helper that reuses the Part 1 solver to check if a route is still possible
/// after dropping a given set of bytes. Just searches a grid for any path
/// from `start` to `end` and reports whether a path can be found.
fn path_still_exists(
  corrupted_bytes: set.Set(grid2d.Index2D),
  start: grid2d.Index2D,
  end: grid2d.Index2D,
  grid_size: Int,
) -> Bool {
  case part1.find_shortest_path(corrupted_bytes, start, end, grid_size) {
    // A successful solve means the path is still open.
    Ok(_) -> True
    // Any error indicates the maze is blocked.
    Error(_) -> False
  }
}

/// Entry point for the binary search for the point at which the path finally
/// becomes blocked. We know we can drop at least `already_dropped` bytes from
/// the list without blocking the path, because we learned that in Part 1.
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

/// Recursive binary search helper that narrows the blocking byte interval.
/// Finds the singular byte that blocks the last remaining path through the
/// grid.
fn binary_search_for_blocking_byte_go(
  bytes: List(grid2d.Index2D),
  grid_size: Int,
  start: grid2d.Index2D,
  end: grid2d.Index2D,
  low: Int,
  high: Int,
) -> Result(grid2d.Index2D, Nil) {
  case low < high {
    // Converged on the blocking byte index; fetch its coordinates.
    False -> byte_at_index(bytes, low)

    // Otherwise, split the interval and test which half is viable.
    True -> {
      // Standard binary search: slice the coordinates into the first `mid`
      // bytes, test whether we can still reach the goal after corrupting the
      // first `mid` bytes, and narrow the search space appropriately.
      let mid = low + int.bitwise_shift_right(high - low, 1)
      let corrupted_bytes = bytes |> list.take(mid) |> set.from_list
      let keep_searching = fn(l, h) {
        binary_search_for_blocking_byte_go(bytes, grid_size, start, end, l, h)
      }
      case path_still_exists(corrupted_bytes, start, end, grid_size) {
        // There is still a path through the maze, so we know that the blocking
        // byte is further down the list than the midpoint.
        True -> keep_searching(mid + 1, high)

        // The path is blocked, so we know that the blocking byte occurs prior
        // to `mid` in the list.
        False -> keep_searching(low, mid)
      }
    }
  }
}

/// Apparently Gleam used to have a standard library function for plucking the
/// value at a specific index from a list, and now it doesn't, so here's a 
/// simple helper to do just that. We'll use it to grab the value from the 
/// list of byte indices at the index determined by our binanry search.
fn byte_at_index(
  bytes: List(grid2d.Index2D),
  idx: Int,
) -> Result(grid2d.Index2D, Nil) {
  case list.drop(bytes, idx - 1) {
    // Found a coordinate at the requested position.
    [next, ..] -> Ok(next)
    // Dropping ran out of bytes, so the index is invalid.
    _ -> Error(Nil)
  }
}

/// In Part 2, we need to find out just how much time we have before all paths
/// out of the maze are closed forever. To that end, we perform a binary search
/// to find the cumulative number of bytes greater than `num_bytes` that will
/// drop the one byte that closes the last remaining path and report the
/// coordinates of that byte.
pub fn solve(
  input: Input,
  grid_size: Int,
  num_bytes: Int,
) -> Result(String, String) {
  use byte_positions <- result.try(input)
  let start = grid2d.Index2D(0, 0)
  let end = grid2d.Index2D(grid_size, grid_size)

  // Try to find the final byte that blocks the last remaining path. Would
  // return an error if no such byte exists, but it definitely does (otherwise
  // the puzzle wouldn't be solvable).
  let try_the_final_byte_idx =
    binary_search_for_blocking_byte(
      byte_positions,
      num_bytes,
      grid_size,
      start,
      end,
    )

  // Clean up and format the result
  try_the_final_byte_idx
  |> result.map(fn(idx) {
    int.to_string(idx.col) <> "," <> int.to_string(idx.row)
  })
  |> result.map_error(fn(_) { "Could not find a blocking byte!" })
}

/// Default entry point wired up to the shared runner expectations.
pub fn main() -> Result(String, String) {
  day18.input_path |> parse.read_input |> solve(70, 1024) |> echo
}
