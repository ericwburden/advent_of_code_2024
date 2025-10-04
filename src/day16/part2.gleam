import common/grid2d
import day16/day16.{type Input, type Output, ValidInput, example1_path}
import day16/dijkstra
import day16/parse
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set

/// Build a map from each state to the list of predecessor states that keep the
/// total path cost optimal. We use this to walk backwards from the goal without
/// rerunning Dijkstra on a reversed graph (which would double-count turn costs).
fn find_optimal_predecessors(
  distances: dict.Dict(dijkstra.Reindeer, Int),
  walls: set.Set(grid2d.Index2D),
) -> dict.Dict(dijkstra.Reindeer, List(dijkstra.Reindeer)) {
  // Over all the state/distance pairs, generated from our Dijkstra's algorithm
  dict.fold(distances, dict.new(), fn(acc, state, cost) {
    // For each state found, we check each of the next steps from that state
    list.fold(
      dijkstra.next_possible_states(state, walls),
      acc,
      fn(acc, neighbor_entry) {
        let #(neighbor_state, step_cost) = neighbor_entry
        case dict.get(distances, neighbor_state) {
          // If the minimal cost to get to the state we are checking plus the
          // cost to take a step to the current neighbor is equal to the 
          // minimal cost to get to that neighbor from the start, then...
          Ok(neighbor_cost) if cost + step_cost == neighbor_cost ->
            // ...we add the state we are checking to the list of optimal
            // predecessors for the neighbor state, meaning the current state
            // is on the shortest path to the neighbor state.
            dict.upsert(acc, neighbor_state, fn(existing) {
              case existing {
                option.Some(existing) -> [state, ..existing]
                option.None -> [state]
              }
            })

          // Otherwise, we skip this neighbor and keep checking.  
          _ -> acc
        }
      },
    )
  })
}

/// Given the optimal predecessor map, traverse every state that sits on at 
/// least one optimal route. This is a simple depth-first walk using an 
/// explicit frontier list.
fn collect_states_on_shortest_paths(
  frontier: List(dijkstra.Reindeer),
  predecessors: dict.Dict(dijkstra.Reindeer, List(dijkstra.Reindeer)),
  seen: set.Set(dijkstra.Reindeer),
) -> set.Set(dijkstra.Reindeer) {
  case frontier {
    // Base case, if we've checked all the steps along all optimal paths, then
    // return the set of states seen.
    [] -> seen

    // Otherwise, pop the first state and...
    [state, ..rest] ->
      case set.contains(seen, state) {
        // If we've already collected that state, just keep going with the rest
        // of the stack.
        True -> collect_states_on_shortest_paths(rest, predecessors, seen)

        // Otherwise, add the next state to our list of seen states, grab every
        // state that leads to it from the optimal predecessors map, and add
        // them to the stack before continuing.
        False -> {
          let seen = set.insert(seen, state)
          let additional = case dict.get(predecessors, state) {
            Ok(states) -> states
            Error(_) -> []
          }
          let next_frontier = list.append(additional, rest)
          collect_states_on_shortest_paths(next_frontier, predecessors, seen)
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
  let ValidInput(start, goal, walls) = valid_input

  // Generate a mapping of the shortest distance to get to each state from
  // the start.
  let distances = dijkstra.map_shortest_distances_from_start(start, walls)

  // Identify the cost of the shortest path. This is what we did for part 1.
  let min_cost_result =
    dijkstra.cost_of_shortest_path(distances, goal)
    |> result.map_error(fn(_) {
      "No path found from the start to the end position"
    })

  use min_cost <- result.try(min_cost_result)

  // For each pair of reachable state and minimum cost to get there, we need
  // to identify which states represent the step immediately before it. This
  // will allow us to walk backwards from the state that represents the
  // shortest path to the goal and identify all the states along those shortest
  // paths.
  let predecessors = find_optimal_predecessors(distances, walls)

  // Since we can theoretically finish a shortest path to the goal facing any
  // direction, we grab all the states that represent the end of a shortest
  // path to the goal. This is necessary because, for example, it may be
  // possible to finish a shortest path heading East or North, but not West.
  let goal_states =
    list.filter(dijkstra.goal_states(goal), fn(state) {
      case dict.get(distances, state) {
        Ok(cost) -> cost == min_cost
        Error(_) -> False
      }
    })

  // Armed with the knowledge of the steps that lead to the shortest path to
  // each valid state, we can walk backwards from the valid goal states and
  // collect every state we find along the way.
  let all_states_in_shortest_paths =
    collect_states_on_shortest_paths(goal_states, predecessors, set.new())

  // Because each state is both an index and a direction, we strip the
  // directions and generate the set of unique tiles traversed.
  let tiles_in_shortest_paths =
    all_states_in_shortest_paths
    |> set.to_list
    |> list.map(fn(state) { state.0 })
    |> set.from_list

  // Report the number of unique tiles in all shortest paths
  Ok(set.size(tiles_in_shortest_paths))
}

pub fn main() -> Nil {
  let solve_result = example1_path |> parse.read_input |> solve
  case solve_result {
    Ok(count) -> io.println(int.to_string(count))
    Error(message) -> io.println(message)
  }
}
