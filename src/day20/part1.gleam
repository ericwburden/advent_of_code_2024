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

fn bfs_distances(
  grid: grid2d.Grid2D(Bool),
  origin: grid2d.Index2D,
) -> dict.Dict(grid2d.Index2D, Int) {
  let initial_queue = deque.new() |> deque.push_back(origin)
  let initial_distances = dict.from_list([#(origin, 0)])
  let initial_visited = set.from_list([origin])
  bfs_loop(grid, initial_queue, initial_distances, initial_visited)
}

fn bfs_loop(
  grid: grid2d.Grid2D(Bool),
  queue: deque.Deque(grid2d.Index2D),
  distances: dict.Dict(grid2d.Index2D, Int),
  visited: set.Set(grid2d.Index2D),
) -> dict.Dict(grid2d.Index2D, Int) {
  case deque.pop_front(queue) {
    Error(Nil) -> distances

    Ok(#(current, rest_queue)) -> {
      let assert Ok(current_distance) = dict.get(distances, current)

      let fresh_neighbors =
        passable_neighbors(grid, current)
        |> list.filter(fn(candidate) { !set.contains(visited, candidate) })

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

      bfs_loop(grid, next_queue, next_distances, next_seen)
    }
  }
}

fn cheat_targets(
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
      Ok(True) -> Ok(#(candidate, cheat_cost))
      _ -> Error(Nil)
    }
  })
}

fn cheat_offsets(max_hops: Int) -> List(#(Int, Int, Int)) {
  list.range(-max_hops, max_hops)
  |> list.flat_map(fn(row_delta) {
    list.range(-max_hops, max_hops)
    |> list.filter_map(fn(col_delta) {
      let cheat_cost =
        int.absolute_value(row_delta) + int.absolute_value(col_delta)

      case cheat_cost > 0 && cheat_cost <= max_hops {
        True -> Ok(#(row_delta, col_delta, cheat_cost))
        False -> Error(Nil)
      }
    })
  })
}

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
    case dict.get(distances_to_goal, cheat_entry) {
      Error(Nil) -> acc
      Ok(steps_from_entry) ->
        case on_shortest_path(steps_to_entry, steps_from_entry, fair_steps) {
          False -> acc
          True ->
            cheat_targets(grid, cheat_entry, max_cheat_steps)
            |> list.fold(acc, fn(acc_inner, target) {
              let #(cheat_exit, cheat_cost) = target

              case
                dict.get(distances_from_start, cheat_exit),
                dict.get(distances_to_goal, cheat_exit)
              {
                Ok(steps_to_exit), Ok(steps_from_exit) -> {
                  let on_path =
                    on_shortest_path(steps_to_exit, steps_from_exit, fair_steps)
                  case on_path && steps_to_exit > steps_to_entry {
                    False -> acc_inner
                    True -> {
                      let candidate_steps =
                        steps_to_entry + cheat_cost + steps_from_exit

                      case fair_steps - candidate_steps >= threshold {
                        True -> record_shortcut(acc_inner, cheat_cost)
                        False -> acc_inner
                      }
                    }
                  }
                }
                _, _ -> acc_inner
              }
            })
        }
    }
  })
}

fn on_shortest_path(steps_to: Int, steps_from: Int, fair_steps: Int) -> Bool {
  steps_to + steps_from == fair_steps
}

fn record_shortcut(
  counts: dict.Dict(Int, Int),
  cheat_cost: Int,
) -> dict.Dict(Int, Int) {
  let existing =
    dict.get(counts, cheat_cost)
    |> result.unwrap(0)
  dict.insert(counts, cheat_cost, existing + 1)
}

pub fn solve(input: Input, cheat_steps: Int, threshold: Int) -> Output {
  use valid_input <- result.try(input)
  let ValidatedInput(grid, start, end) = valid_input

  let distances_from_start = bfs_distances(grid, start)
  let try_fair_steps =
    dict.get(distances_from_start, end)
    |> result.map_error(fn(_) { "Could not find a fair path through the grid" })
  use fair_steps <- result.try(try_fair_steps)

  let distances_to_goal = bfs_distances(grid, end)

  let cheat_counts =
    count_cheat_paths_by_cost(
      grid,
      distances_from_start,
      distances_to_goal,
      fair_steps,
      cheat_steps,
      threshold,
    )

  let qualifying =
    dict.fold(cheat_counts, 0, fn(acc, cheat_cost, amount) {
      case cheat_cost <= cheat_steps {
        True -> acc + amount
        False -> acc
      }
    })

  Ok(qualifying)
}

pub fn main() -> Output {
  day20.input_path
  |> parse.read_input
  |> solve(default_cheat_distance, default_savings_threshold)
  |> echo
}
