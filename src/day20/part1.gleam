import common/grid2d
import day20/day20.{type Input, type Output, ValidatedInput}
import day20/parse
import gleam/deque
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set

/// Default configuration for part 1: a single two-step cheat must save
/// at least one hundred steps to count.
pub const default_cheat_distance = 2

pub const default_savings_threshold = 100

/// Look up adjacent passable tiles ('.', 'S', or 'E') from the given index.
/// We rely on this helper in all safe navigation routines.
fn passable_neighbors(
  grid: grid2d.Grid2D(Bool),
  index: grid2d.Index2D,
) -> List(grid2d.Index2D) {
  grid2d.cardinal_offsets
  // Translate the index by each cardinal offset to find candidate neighbors.
  |> list.map(fn(offset) { grid2d.apply_offset(index, offset) })
  // Keep only the cells that are present in the grid and marked as passable.
  |> list.filter(fn(candidate) {
    case dict.get(grid, candidate) {
      // We can move through any tile that contains `True`.
      Ok(True) -> True
      // Missing or False tiles are walls or out-of-bounds entries.
      _ -> False
    }
  })
}

/// Perform a breadth-first search that records the shortest number of safe
/// steps from the origin to every reachable passable tile. The result acts as a
/// lookup table for both the start-to-cheat and cheat-to-goal distances.
fn bfs_scan(
  grid: grid2d.Grid2D(Bool),
  origin: grid2d.Index2D,
) -> grid2d.Grid2D(Int) {
  let initial_queue = deque.new() |> deque.push_back(origin)
  let initial_distances = dict.from_list([#(origin, 0)])
  let initial_visited = set.from_list([origin])
  bfs_scan_go(grid, initial_queue, initial_distances, initial_visited)
}

/// Tail-recursive worker that consumes the BFS queue, updating the distances
/// map each time a new tile is discovered. We continue until the queue is
/// empty, which means every reachable tile has been processed.
fn bfs_scan_go(
  grid: grid2d.Grid2D(Bool),
  queue: deque.Deque(grid2d.Index2D),
  distances: dict.Dict(grid2d.Index2D, Int),
  visited: set.Set(grid2d.Index2D),
) -> grid2d.Grid2D(Int) {
  case deque.pop_front(queue) {
    // Queue exhausted: every reachable tile has been recorded.
    Error(Nil) -> distances

    Ok(#(current, rest_queue)) -> {
      // We can count on this to be safe, since we initialized distances to
      // contain an entry for every index in the original grid in the 
      // `bfs_scan` initialization. This assumption could break if that
      // invariant is changed, though.
      let assert Ok(current_distance) = dict.get(distances, current)

      // Get all the neighbors that are passable and not yet visited.
      let neighbors =
        passable_neighbors(grid, current)
        |> list.filter(fn(candidate) { !set.contains(visited, candidate) })

      // Update the search queue, distance map, and set of seen indices for
      // each neighbor.
      let #(next_queue, next_distances, next_seen) =
        list.fold(
          neighbors,
          #(rest_queue, distances, visited),
          fn(acc, neighbor) {
            let #(acc_queue, acc_distances, acc_seen) = acc
            let updated_queue = deque.push_back(acc_queue, neighbor)
            let updated_distances =
              dict.insert(acc_distances, neighbor, current_distance + 1)
            let updated_seen = set.insert(acc_seen, neighbor)
            #(updated_queue, updated_distances, updated_seen)
          },
        )

      // Keep recursing
      bfs_scan_go(grid, next_queue, next_distances, next_seen)
    }
  }
}

/// Evaluate every potential cheat landing spot around the origin, yielding the
/// destination index and the number of cheat steps required to get there.
fn possible_cheat_exit_points(
  grid: grid2d.Grid2D(Bool),
  origin: grid2d.Index2D,
  max_hops: Int,
) -> List(#(grid2d.Index2D, Int)) {
  let grid2d.Index2D(row, col) = origin

  cheat_offsets(max_hops)
  |> list.filter_map(fn(offset) {
    let #(row_delta, col_delta, cheat_cost) = offset
    let candidate = grid2d.Index2D(row + row_delta, col + col_delta)

    case dict.get(grid, candidate) {
      // Only keep landings that are already passable tiles.
      Ok(True) -> Ok(#(candidate, cheat_cost))
      _ -> Error(Nil)
    }
  })
}

/// Produce the cartesian product of two lists.
fn cartesian_product(list1: List(a), list2: List(b)) -> List(#(a, b)) {
  list.flat_map(list1, fn(el1) { list.map(list2, fn(el2) { #(el1, el2) }) })
}

/// Precompute every offset within the cheat radius, paired with its Manhattan
/// distance so callers can subtract cheat steps without recomputing it.
fn cheat_offsets(max_hops: Int) -> List(#(Int, Int, Int)) {
  let deltas = list.range(-max_hops, max_hops)
  cartesian_product(deltas, deltas)
  |> list.filter_map(fn(row_col_offset) {
    let #(row_offset, col_offset) = row_col_offset
    let total_steps =
      int.absolute_value(row_offset) + int.absolute_value(col_offset)
    case total_steps > 0 && total_steps <= max_hops {
      True -> Ok(#(row_offset, col_offset, total_steps))
      False -> Error(Nil)
    }
  })
}

/// Combine the two one-sided distance maps into a single lookup that records
/// both the steps from the start and the steps to the goal for every tile that
/// is reachable from the start and can also reach the goal.
fn calculate_pathing_distances(
  distances_from_start: dict.Dict(grid2d.Index2D, Int),
  distances_to_goal: dict.Dict(grid2d.Index2D, Int),
) -> dict.Dict(grid2d.Index2D, #(Int, Int)) {
  dict.fold(distances_from_start, dict.new(), fn(acc, index, steps_to_start) {
    case dict.get(distances_to_goal, index) {
      Ok(steps_to_goal) ->
        dict.insert(acc, index, #(steps_to_start, steps_to_goal))
      Error(Nil) -> acc
    }
  })
}

/// Count how many shortcuts satisfy the savings threshold. The outer fold walks
/// each candidate entry index; the inner fold checks every potential landing
/// spot for that entry and increments the tally for every successful shortcut.
fn count_worthwhile_cheats(
  grid: grid2d.Grid2D(Bool),
  distances: dict.Dict(grid2d.Index2D, #(Int, Int)),
  shortest_fair_path: Int,
  cheat_steps: Int,
  threshold: Int,
) -> Int {
  dict.to_list(distances)
  |> list.fold(0, fn(valid_cheat_count, entry) {
    let #(cheat_start_idx, #(steps_to_entry, _steps_from_entry)) = entry

    possible_cheat_exit_points(grid, cheat_start_idx, cheat_steps)
    |> list.fold(valid_cheat_count, fn(inner_count, target) {
      let #(cheat_end_idx, cheat_cost) = target

      case dict.get(distances, cheat_end_idx) {
        Ok(#(steps_to_exit, steps_from_exit)) -> {
          let forward_savings = steps_to_exit - steps_to_entry
          let finish_savings =
            steps_to_entry + cheat_cost + steps_from_exit - shortest_fair_path

          case forward_savings > 0 && finish_savings <= -threshold {
            True -> inner_count + 1
            False -> inner_count
          }
        }
        Error(Nil) -> inner_count
      }
    })
  })
}

/// Entry point for part 1. The solver receives the already parsed input along
/// with configurable cheat settings and returns how many shortcuts qualify.
pub fn solve(input: Input, cheat_steps: Int, threshold: Int) -> Output {
  use valid_input <- result.try(input)
  let ValidatedInput(grid, start, end) = valid_input

  // Generate the minimum number of steps to each tile in the grid from the
  // start with cheats turned off. This mapping will also give us the shortest,
  // non-cheating path to the end for comparison to paths with cheats
  // allowed.
  let distances_from_start = bfs_scan(grid, start)
  let try_fair_steps =
    dict.get(distances_from_start, end)
    |> result.map_error(fn(_) { "Could not find a fair path through the grid" })
  use shortest_fair_path <- result.try(try_fair_steps)

  // Generate another map of the minimum distance from the goal to each
  // passable tile in the grid. Essentially walks the grid backwards and
  // finds the shortest path to each tile, with cheats turned off.
  let distances_to_goal = bfs_scan(grid, end)

  // Combine both distance maps so every reachable tile records how far it is
  // from the start and how far it is from the goal. This lets us evaluate any
  // how much time can be saved by any proposed shortcut.
  let combined_distances =
    calculate_pathing_distances(distances_from_start, distances_to_goal)

  let result =
    count_worthwhile_cheats(
      grid,
      combined_distances,
      shortest_fair_path,
      cheat_steps,
      threshold,
    )

  Ok(result)
}

/// Convenience executable that runs the solver with the puzzle's default
/// configuration against the full input.
pub fn main() -> Output {
  day20.input_path
  |> parse.read_input
  |> solve(default_cheat_distance, default_savings_threshold)
  |> echo
}
