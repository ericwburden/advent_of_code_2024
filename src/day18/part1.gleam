import common/grid2d
import day18/day18.{type Input, type Output}
import day18/parse
import gleam/deque
import gleam/list
import gleam/result
import gleam/set

/// Enumerate the uncorrupted cardinal neighbors of a grid position that are
/// still within the puzzle area. This is the movement budget for the BFS.
pub fn get_safe_neighbors(
  corrupted_bytes: set.Set(grid2d.Index2D),
  grid_size: Int,
  from: grid2d.Index2D,
) -> List(grid2d.Index2D) {
  grid2d.cardinal_offsets
  |> list.map(fn(offset) { grid2d.apply_offset(from, offset) })
  |> list.filter(fn(neighbor) {
    // Check each neighbor in each cardinal direction to be sure it's not
    // corrupted and it's in the bounds of the grid.
    let grid2d.Index2D(row, col) = neighbor
    let in_bounds = row >= 0 && row <= grid_size && col >= 0 && col <= grid_size
    in_bounds && !set.contains(corrupted_bytes, neighbor)
  })
}

/// Breadth-first search from the start to the exit, treating every dropped
/// byte as an impassable wall. This is the entry point to the search.
pub fn find_shortest_path(
  corrupted_bytes: set.Set(grid2d.Index2D),
  start: grid2d.Index2D,
  end: grid2d.Index2D,
  grid_size: Int,
) -> Result(Int, String) {
  let queue = deque.new() |> deque.push_back(#(start, 0))
  let visited = set.new() |> set.insert(start)
  find_shortest_path_go(corrupted_bytes, end, queue, grid_size, visited)
}

/// Tail-recursive worker that performs the breadth-first search over the grid.
fn find_shortest_path_go(
  corrupted_bytes: set.Set(grid2d.Index2D),
  goal: grid2d.Index2D,
  queue: deque.Deque(#(grid2d.Index2D, Int)),
  grid_size: Int,
  visited: set.Set(grid2d.Index2D),
) -> Result(Int, String) {
  case deque.pop_front(queue) {
    // When there are no more positions to explore,  and we haven't found the
    // exit yet, we know the exit is unreachable.
    Error(Nil) -> Error("Could not find a path through the grid!")

    // Otherwise, pop the next position and continue the search.
    Ok(#(current_entry, rest_queue)) -> {
      let #(current, distance) = current_entry
      case current == goal {
        // Found the exit; report the shortest known distance.
        True -> Ok(distance)

        // Need to expand neighbors and keep searching.
        False -> {
          // Only explore neighbors we haven't visited yet so the BFS stays
          // linear and each tile is enqueued at most once.
          let new_neighbors =
            get_safe_neighbors(corrupted_bytes, grid_size, current)
            |> list.filter(fn(idx) { !set.contains(visited, idx) })

          // Update the two accumulators, the queue of grid indices to check
          // next and the set of indices already checked, by adding the new
          // neighbors to both.
          let #(next_queue, next_visited) =
            list.fold(new_neighbors, #(rest_queue, visited), fn(acc, neighbor) {
              let #(acc_queue, acc_seen) = acc
              let updated_queue =
                deque.push_back(acc_queue, #(neighbor, distance + 1))
              let updated_seen = set.insert(acc_seen, neighbor)
              #(updated_queue, updated_seen)
            })

          // Keep searching...
          find_shortest_path_go(
            corrupted_bytes,
            goal,
            next_queue,
            grid_size,
            next_visited,
          )
        }
      }
    }
  }
}

/// For part 1, we drop the first `num_bytes` falling bytes into the grid,
/// corrupting every space they land on, then search the safe grid spaces to
/// find the shortest path from the top left position to the bottom right
/// position.
pub fn solve(input: Input, grid_size: Int, num_bytes: Int) -> Output {
  use byte_positions <- result.try(input)
  let corrupted_bytes = list.take(byte_positions, num_bytes) |> set.from_list
  let start = grid2d.Index2D(0, 0)
  let end = grid2d.Index2D(grid_size, grid_size)
  find_shortest_path(corrupted_bytes, start, end, grid_size)
}

/// Default entry point wired up to the shared runner expectations.
pub fn main() -> Output {
  day18.input_path |> parse.read_input |> solve(70, 1024) |> echo
}
