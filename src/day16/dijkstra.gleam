import common/grid2d
import day16/day16.{type Direction, East, North, South, West}
import gleam/dict
import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/set
import gleamy/priority_queue

/// Shared navigation helpers for both parts. Everything in here revolves around
/// the `(position, direction)` state we feed into Dijkstra.
pub type Reindeer =
  #(grid2d.Index2D, Direction)

/// The priority queue stores cost/state pairs, so we give them a dedicated type
/// alias to keep signatures readable.
pub type QueueEntry =
  #(Int, Reindeer)

/// Rotating 90° costs 1,000 points in the puzzle description.
pub const rotate_cost = 1000

/// Moving forward a single tile costs 1 point.
pub const forward_cost = 1

/// The pairing-heap priority queue needs to know how to compare two entries.
fn compare_queue_entries(a: QueueEntry, b: QueueEntry) -> Order {
  let #(cost_a, _) = a
  let #(cost_b, _) = b
  int.compare(cost_a, cost_b)
}

/// Convert a direction into the offset used by the grid helpers.
pub fn direction_offset(direction: Direction) -> grid2d.Offset2D {
  case direction {
    North -> grid2d.Offset2D(-1, 0)
    East -> grid2d.Offset2D(0, 1)
    South -> grid2d.Offset2D(1, 0)
    West -> grid2d.Offset2D(0, -1)
  }
}

/// Rotate 90° counter-clockwise.
fn turn_left(direction: Direction) -> Direction {
  case direction {
    North -> West
    West -> South
    South -> East
    East -> North
  }
}

/// Rotate 90° clockwise.
fn turn_right(direction: Direction) -> Direction {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

/// Enumerate every legal move from the current state.
pub fn next_possible_states(
  state: Reindeer,
  walls: set.Set(grid2d.Index2D),
) -> List(#(Reindeer, Int)) {
  let #(position, direction) = state

  let turns = [
    #(#(position, turn_left(direction)), rotate_cost),
    #(#(position, turn_right(direction)), rotate_cost),
  ]

  let next_position = grid2d.apply_offset(position, direction_offset(direction))
  case set.contains(walls, next_position) {
    True -> turns
    False -> [#(#(next_position, direction), forward_cost), ..turns]
  }
}

/// Generic Dijkstra runner. The caller supplies the initial frontier with their
/// chosen costs and the function returns the full distance map.
pub fn map_shortest_distances_from_start(
  start: Reindeer,
  walls: set.Set(grid2d.Index2D),
) -> dict.Dict(Reindeer, Int) {
  let queue =
    priority_queue.new(compare_queue_entries)
    |> priority_queue.push(#(0, start))
  let distances = dict.new() |> dict.insert(start, 0)
  map_shortest_distances_from_start_go(queue, distances, walls)
}

/// Internal tail-recursive loop that processes the priority queue until all
/// optimal distances have been discovered.
fn map_shortest_distances_from_start_go(
  queue: priority_queue.Queue(QueueEntry),
  distances: dict.Dict(Reindeer, Int),
  walls: set.Set(grid2d.Index2D),
) -> dict.Dict(Reindeer, Int) {
  case priority_queue.pop(queue) {
    // Base case, the priority queue is empty and we've checked every
    // passable space on the map.
    Error(_) -> distances

    // Otherwise, we process the next entry in the queue
    Ok(#(queue_entry, remaining_queue)) -> {
      let #(cost, state) = queue_entry

      // Get the last best cost for the current state
      case dict.get(distances, state) {
        // If the current cost is greater than the last best cost, then we know
        // we are not on an optimal path, so we can stop processing this path
        // and move to the next item in the queue.
        Ok(best_cost) if cost > best_cost ->
          map_shortest_distances_from_start_go(
            remaining_queue,
            distances,
            walls,
          )

        // Otherwise, either no cost for the current state has been recorded,
        // or the current cost is less than or equal to the last best cost.
        // Either way, we attempt to branch out from the current state.
        _ -> {
          let #(next_queue, next_distances) =
            update_search_state(remaining_queue, distances, state, cost, walls)

          map_shortest_distances_from_start_go(
            next_queue,
            next_distances,
            walls,
          )
        }
      }
    }
  }
}

/// Walk the neighbour list for the current state, inserting any improved paths
/// into the priority queue and distance map. Returns the updated `(queue,
/// distances)` pair so the caller can continue the main search loop.
fn update_search_state(
  queue: priority_queue.Queue(QueueEntry),
  distances: dict.Dict(Reindeer, Int),
  state: Reindeer,
  cost: Int,
  walls: set.Set(grid2d.Index2D),
) -> #(priority_queue.Queue(QueueEntry), dict.Dict(Reindeer, Int)) {
  list.fold(
    next_possible_states(state, walls),
    #(queue, distances),
    fn(acc, edge) {
      // For each possible state reachable from the current state, calculate
      // the cost to reach that next state.
      let #(queue_acc, dist_acc) = acc
      let #(neighbor_state, step_cost) = edge
      let new_cost = cost + step_cost

      case dict.get(dist_acc, neighbor_state) {
        // If the cost to reach that next state is no less than the recorded
        // cost, then leave the queue and distances map as-is.
        Ok(existing_cost) if new_cost >= existing_cost -> #(queue_acc, dist_acc)

        // Otherwise, if we don't know the cost to get to the next state or
        // the last best cost is greater than the current cost, update the
        // distances mapping with the new cost and add the current state
        // to the priority queue to be expanded on in a future step.
        _ -> {
          let dist_acc = dict.insert(dist_acc, neighbor_state, new_cost)
          let queue_acc =
            priority_queue.push(queue_acc, #(new_cost, neighbor_state))
          #(queue_acc, dist_acc)
        }
      }
    },
  )
}

/// A helper that returns the goal tile with every possible facing, which lets
/// the callers treat orientation and position uniformly.
pub fn goal_states(goal: grid2d.Index2D) -> List(Reindeer) {
  [
    #(goal, North),
    #(goal, East),
    #(goal, South),
    #(goal, West),
  ]
}

/// Given a finished distance map, find the cheapest way to reach the goal tile.
pub fn cost_of_shortest_path(
  distances: dict.Dict(Reindeer, Int),
  goal: grid2d.Index2D,
) -> Result(Int, Nil) {
  list.fold(goal_states(goal), Error(Nil), fn(acc, state) {
    case dict.get(distances, state), acc {
      Ok(cost), Error(_) -> Ok(cost)
      Ok(cost), Ok(existing) -> Ok(int.min(existing, cost))
      Error(_), _ -> acc
    }
  })
}
