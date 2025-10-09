import common/grid2d
import day20/day20.{type Input, type Output, ValidatedInput}
import day20/parse
import gleam/deque
import gleam/dict
import gleam/list
import gleam/result
import gleam/set

/// Default number of steps we may travel while "cheating" straight through
/// walls. This mirrors the allowance for part 1 of the puzzle.
pub const default_cheat_distance = 2

/// Default minimum improvement required for a shortcut to count.
pub const default_savings_threshold = 100

/// Lightweight absolute value helper – Gleam's core `int` module does not ship
/// with one, and writing it out keeps the rest of the code tidy.
fn abs(value: Int) -> Int {
  case value < 0 {
    True -> -value
    False -> value
  }
}

/// Enumerate passable (".", "S", or "E") neighbors one step away from the
/// provided index. This powers the ordinary breadth-first searches that operate
/// without cheating.
fn passable_neighbors(
  grid: grid2d.Grid2D(Bool),
  index: grid2d.Index2D,
) -> List(grid2d.Index2D) {
  grid2d.cardinal_offsets
  |> list.map(fn(offset) { grid2d.apply_offset(index, offset) })
  |> list.filter(fn(candidate) {
    case dict.get(grid, candidate) {
      Ok(True) -> True
      _ -> False
    }
  })
}

/// Classic breadth-first search that measures the shortest number of safe
/// steps from the given origin to every other passable index in the grid.
fn bfs_distances(
  grid: grid2d.Grid2D(Bool),
  origin: grid2d.Index2D,
) -> dict.Dict(grid2d.Index2D, Int) {
  let initial_queue = deque.new() |> deque.push_back(origin)
  let initial_distances = dict.from_list([#(origin, 0)])
  let initial_visited = set.from_list([origin])
  bfs_loop(
    grid,
    deque.pop_front(initial_queue),
    initial_distances,
    initial_visited,
  )
}

/// Tail-recursive worker for the BFS above: repeatedly pop the next cell, store
/// its distance, and enqueue any unseen passable neighbors.
fn bfs_loop(
  grid: grid2d.Grid2D(Bool),
  queue_result: Result(#(grid2d.Index2D, deque.Deque(grid2d.Index2D)), Nil),
  distances: dict.Dict(grid2d.Index2D, Int),
  visited: set.Set(grid2d.Index2D),
) -> dict.Dict(grid2d.Index2D, Int) {
  case queue_result {
    // No more indices to explore means we've catalogued every reachable tile.
    Error(Nil) -> distances

    Ok(#(current, rest_queue)) -> {
      let assert Ok(current_distance) = dict.get(distances, current)

      // Gather any adjacent safe tiles we haven't seen yet.
      let fresh_neighbors =
        passable_neighbors(grid, current)
        |> list.filter(fn(candidate) { !set.contains(visited, candidate) })

      // Enqueue those neighbors and remember their distances.
      let #(next_queue, next_distances, next_seen) =
        list.fold(
          fresh_neighbors,
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

      bfs_loop(grid, deque.pop_front(next_queue), next_distances, next_seen)
    }
  }
}

/// Enumerate every cheat target reachable from the given index while consuming
/// at most `max_hops` steps. Each result carries both the destination index and
/// the Manhattan cost of the cheating segment.
fn cheat_targets(
  grid: grid2d.Grid2D(Bool),
  origin: grid2d.Index2D,
  max_hops: Int,
) -> List(#(grid2d.Index2D, Int)) {
  let grid2d.Index2D(row, col) = origin

  list.range(-max_hops, max_hops)
  |> list.flat_map(fn(row_delta) {
    list.range(-max_hops, max_hops)
    |> list.filter_map(fn(col_delta) {
      let cheat_cost = abs(row_delta) + abs(col_delta)

      case cheat_cost == 0 || cheat_cost > max_hops {
        True -> Error(Nil)
        False -> {
          let candidate = grid2d.Index2D(row + row_delta, col + col_delta)
          case dict.get(grid, candidate) {
            Ok(True) -> Ok(#(candidate, cheat_cost))
            _ -> Error(Nil)
          }
        }
      }
    })
  })
}

/// Count cheat-enabled paths grouped by the number of cheat steps required.
/// Each entry in the returned dictionary maps a cheat distance to the number of
/// distinct shortcuts that save at least `threshold` steps versus the fair path.
fn count_cheat_paths_by_cost(
  grid: grid2d.Grid2D(Bool),
  distances_from_start: dict.Dict(grid2d.Index2D, Int),
  distances_to_goal: dict.Dict(grid2d.Index2D, Int),
  fair_steps: Int,
  max_cheat_steps: Int,
  threshold: Int,
) -> dict.Dict(Int, Int) {
  dict.to_list(distances_from_start)
  |> list.fold(dict.new(), fn(acc, entry) {
    let #(cheat_entry, steps_to_entry) = entry
    // Only consider starting points that lie on at least one shortest path; if
    // taking the fair path to this tile plus finishing the fair path from it
    // exceeds the best-known cost, it cannot contribute to a useful cheat.
    case dict.get(distances_to_goal, cheat_entry) {
      Error(Nil) -> acc
      Ok(steps_from_entry) if steps_to_entry + steps_from_entry != fair_steps ->
        acc
      Ok(_) ->
        cheat_targets(grid, cheat_entry, max_cheat_steps)
        |> list.fold(acc, fn(acc_inner, target) {
          let #(cheat_exit, cheat_cost) = target

          case
            dict.get(distances_from_start, cheat_exit),
            dict.get(distances_to_goal, cheat_exit)
          {
            Ok(steps_to_exit), Ok(steps_from_exit)
              if steps_to_exit + steps_from_exit == fair_steps
              && steps_to_exit > steps_to_entry
            -> {
              // Skipping the fair path segment between `cheat_entry` and
              // `cheat_exit` saves `(steps_to_exit - steps_to_entry)` moves.
              // Spending `cheat_cost` jumps us through the wall in a straight
              // line; if the net savings meets the threshold we count it.
              let candidate_steps =
                steps_to_entry + cheat_cost + steps_from_exit
              case fair_steps - candidate_steps >= threshold {
                True -> {
                  let existing =
                    dict.get(acc_inner, cheat_cost)
                    |> result.unwrap(0)
                  dict.insert(acc_inner, cheat_cost, existing + 1)
                }
                False -> acc_inner
              }
            }
            // Exit is not on a fair shortest path, or we would be travelling
            // backwards along that path, so this pair cannot possibly help.
            _, _ -> acc_inner
          }
        })
    }
  })
}

/// Sum the counts of every cheat that consumes at most `max_steps`.
fn sum_cheats_up_to(counts: dict.Dict(Int, Int), max_steps: Int) -> Int {
  dict.fold(counts, 0, fn(acc, cheat_cost, amount) {
    case cheat_cost <= max_steps {
      True -> acc + amount
      False -> acc
    }
  })
}

pub fn solve(input: Input, cheat_steps: Int, threshold: Int) -> Output {
  // Parse the raw text and bail quickly if the file could not be read.
  use valid_input <- result.try(input)
  let ValidatedInput(grid, start, end) = valid_input

  // Measure the ordinary shortest path without cheating. If the goal were
  // unreachable, the BFS would omit it and we propagate that failure here.
  let distances_from_start = bfs_distances(grid, start)
  let try_fair_steps =
    dict.get(distances_from_start, end)
    |> result.map_error(fn(_) { "Could not find a fair path through the grid" })
  use fair_steps <- result.try(try_fair_steps)

  // Distance-to-goal map lets us compute the remainder of the path after the
  // cheat segment ends.
  let distances_to_goal = bfs_distances(grid, end)

  // Count every cheat that saves at least the configured number of steps,
  // grouped by the number of cheating steps required.
  let cheat_counts =
    count_cheat_paths_by_cost(
      grid,
      distances_from_start,
      distances_to_goal,
      fair_steps,
      cheat_steps,
      threshold,
    )

  // Collapse the grouped counts so the public API still reports the aggregate.
  let qualifying = sum_cheats_up_to(cheat_counts, cheat_steps)

  Ok(qualifying)
}

pub fn main() -> Output {
  day20.example1_path
  |> parse.read_input
  |> solve(2, 20)
  |> echo
}
