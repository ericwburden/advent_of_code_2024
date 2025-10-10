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

/// Produce the cartesian product of two lists.
fn cartesian_product(list1: List(a), list2: List(b)) -> List(#(a, b)) {
  list.flat_map(list1, fn(el1) { list.map(list2, fn(el2) { #(el1, el2) }) })
}

/// Precompute every offset within the cheat radius, paired with its Manhattan
/// distance so callers can subtract cheat steps without recomputing it.
fn cheat_offsets(cheat_steps: Int) -> List(#(Int, Int, Int)) {
  let deltas = list.range(-cheat_steps, cheat_steps)
  cartesian_product(deltas, deltas)
  |> list.filter_map(fn(row_col_offset) {
    let #(row_offset, col_offset) = row_col_offset
    let total_steps =
      int.absolute_value(row_offset) + int.absolute_value(col_offset)
    case total_steps > 0 && total_steps <= cheat_steps {
      True -> Ok(#(row_offset, col_offset, total_steps))
      False -> Error(Nil)
    }
  })
}

/// Combine the two one-sided distance maps into a single lookup that records
/// both the steps from the start and the steps to the goal for every tile that
/// is reachable from the start and can also reach the goal.
fn annotate_grid_with_step_counts(
  grid: grid2d.Grid2D(Bool),
  distances_from_start: dict.Dict(grid2d.Index2D, Int),
  distances_to_exit: dict.Dict(grid2d.Index2D, Int),
) -> dict.Dict(grid2d.Index2D, #(Bool, Int, Int)) {
  dict.fold(distances_from_start, dict.new(), fn(acc, index, steps_from_start) {
    case dict.get(distances_to_exit, index) {
      Ok(steps_to_exit) -> {
        let assert Ok(is_passable) = dict.get(grid, index)
        dict.insert(acc, index, #(is_passable, steps_from_start, steps_to_exit))
      }
      Error(Nil) -> acc
    }
  })
}

/// Count how many shortcuts satisfy the savings threshold. The outer fold 
/// walks each index in the grid and checks each passable tile to see if it can 
/// be the starting point for a cheat of up to `cheat_steps` steps that can
/// save at leeast `threshold` steps off the shortest non-cheat path through
/// the grid.
fn count_worthwhile_cheats(
  grid_annotated: dict.Dict(grid2d.Index2D, #(Bool, Int, Int)),
  shortest_fair_path: Int,
  cheat_steps: Int,
  threshold: Int,
) -> Int {
  // A list of all the offsets in a Manhattan radius of `cheat_steps` from
  // the origin. Used to find the indices where a cheat could potentially
  // end.
  let offsets = cheat_offsets(cheat_steps)

  dict.fold(grid_annotated, 0, fn(valid_cheat_count, cheat_start_idx, idx_info) {
    let #(is_passable, steps_from_start, _) = idx_info

    case is_passable {
      // Cheats can't start at an impassable tile, so skip checking those.
      False -> valid_cheat_count

      // For each tile that could potentially be the starting point for a
      // cheat (i.e., every normally passable tile), count the number of 
      // points on the grid where the cheat could end *and* save at least the
      // `threshold` of steps.
      True -> {
        let qualifying_cheats =
          count_worthwhile_cheat_exits(
            cheat_start_idx,
            grid_annotated,
            steps_from_start,
            offsets,
            shortest_fair_path,
            threshold,
          )
        valid_cheat_count + qualifying_cheats
      }
    }
  })
}

/// Given a starting tile, count every landing tile that would produce a
/// shortcut meeting the savings requirement. According to the puzzle text,
/// it doesn't matter what path the robot takes while cheating, a cheat is
/// counted only once for each unique start/end coordinate pair.
fn count_worthwhile_cheat_exits(
  cheat_start_idx: grid2d.Index2D,
  grid_annotated: dict.Dict(grid2d.Index2D, #(Bool, Int, Int)),
  steps_from_start: Int,
  offsets: List(#(Int, Int, Int)),
  shortest_fair_path: Int,
  threshold: Int,
) -> Int {
  let grid2d.Index2D(row, col) = cheat_start_idx

  // For every reachable offset from the starting index...
  list.fold(offsets, 0, fn(acc, offset) {
    let #(row_delta, col_delta, cheat_cost) = offset
    let cheat_end_idx = grid2d.Index2D(row + row_delta, col + col_delta)

    // Check the tile information at that reachable offset.
    case dict.get(grid_annotated, cheat_end_idx) {
      // Impassable tiles can't be the end point for a cheat, skip that one.
      // Same for any index that points off the grid.
      Ok(#(False, _, _)) | Error(_) -> acc

      // Any exit point that would result in a path that saves at least
      // `threshold` steps gets counted.
      Ok(#(True, _steps_from_start, steps_to_exit)) -> {
        let new_path_length = steps_from_start + cheat_cost + steps_to_exit
        let saved_steps = shortest_fair_path - new_path_length
        case saved_steps >= threshold {
          True -> acc + 1
          False -> acc
        }
      }
    }
  })
}

/// Part 1 of today's puzzle asks us to participate in a race with cheat codes!
/// Granted, it's not really cheating, since everyone is doing it and there are
/// rules about it, but it's more fun to call it a cheat, so that's what we're
/// doing. We'll start by analyzing the grid and the path to the goal with 
/// collisions turned on, then start checking for opportunities to cheat by
/// walking through walls. Counts every opportunity to save enough time by
/// doing so.
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
  let distances_to_exit = bfs_scan(grid, end)

  // Combine both distance maps and the original grid so that every index now
  // indicates whether it is passable, the number of steps away from the start
  // it is on the way to the goal, and the number of steps left until the
  // goal. 
  let grid_with_steps_annotated =
    annotate_grid_with_step_counts(
      grid,
      distances_from_start,
      distances_to_exit,
    )

  let result =
    count_worthwhile_cheats(
      grid_with_steps_annotated,
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
