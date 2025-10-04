import common/grid2d
import day16/day16.{type Input, type Output, example1_path}
import day16/navigation
import day16/parse
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set

/// Build a map from each state to the list of predecessor states that keep the
/// total path cost optimal. We use this to walk backwards from the goal without
/// rerunning Dijkstra on a reversed graph (which would double-count turn costs).
fn optimal_predecessors(
  distances: dict.Dict(navigation.State, Int),
  walls: set.Set(grid2d.Index2D),
) -> dict.Dict(navigation.State, List(navigation.State)) {
  dict.fold(distances, dict.new(), fn(acc, state, cost) {
    navigation.neighbors(state, walls)
    |> list.fold(acc, fn(acc, neighbor_entry) {
      let #(neighbor_state, edge_cost) = neighbor_entry
      case dict.get(distances, neighbor_state) {
        Ok(neighbor_cost) if cost + edge_cost == neighbor_cost ->
          case dict.get(acc, neighbor_state) {
            Ok(existing) ->
              dict.insert(acc, neighbor_state, [state, ..existing])
            Error(_) -> dict.insert(acc, neighbor_state, [state])
          }
        _ -> acc
      }
    })
  })
}

/// Given the predecessor map, traverse every state that sits on at least one
/// optimal route. This is a simple depth-first walk using an explicit frontier
/// list.
fn collect_optimal_states(
  frontier: List(navigation.State),
  predecessors: dict.Dict(navigation.State, List(navigation.State)),
  seen: set.Set(navigation.State),
) -> set.Set(navigation.State) {
  case frontier {
    [] -> seen
    [state, ..rest] ->
      case set.contains(seen, state) {
        True -> collect_optimal_states(rest, predecessors, seen)
        False -> {
          let seen = set.insert(seen, state)
          let additional = case dict.get(predecessors, state) {
            Ok(states) -> states
            Error(_) -> []
          }
          let next_frontier = list.append(additional, rest)
          collect_optimal_states(next_frontier, predecessors, seen)
        }
      }
  }
}

/// Part 2 counts the distinct tiles that appear on any optimal path. We collect
/// predecessor information from the first Dijkstra pass, seed the traversal
/// with the orientations that reach the goal at minimum cost, and finally count
/// how many unique positions those states cover.
pub fn solve(input: Input) -> Output {
  use valid_input <- result.try(input)

  let start = navigation.start_state(valid_input)
  let walls = navigation.walls(valid_input)
  let goal = navigation.goal(valid_input)

  let distances = navigation.dijkstra([#(start, 0)], walls)

  let min_cost_result =
    navigation.min_cost_to_goal(distances, goal)
    |> result.map_error(fn(_) {
      "No path found from the start to the end position"
    })

  use min_cost <- result.try(min_cost_result)

  let predecessors = optimal_predecessors(distances, walls)

  let goal_states =
    navigation.goal_states(goal)
    |> list.filter(fn(state) {
      case dict.get(distances, state) {
        Ok(cost) -> cost == min_cost
        Error(_) -> False
      }
    })

  case goal_states {
    [] -> Error("No path found from the start to the end position")
    states -> {
      let optimal_states =
        collect_optimal_states(states, predecessors, set.new())

      let optimal_tiles =
        set.fold(optimal_states, set.new(), fn(acc, state) {
          let #(position, _) = state
          set.insert(acc, position)
        })

      Ok(set.size(optimal_tiles))
    }
  }
}

/// Handy CLI entry point that runs the solver against the first sample maze.
pub fn main() -> Nil {
  let solve_result = example1_path |> parse.read_input |> solve
  case solve_result {
    Ok(count) -> io.println(int.to_string(count))
    Error(message) -> io.println(message)
  }
}
