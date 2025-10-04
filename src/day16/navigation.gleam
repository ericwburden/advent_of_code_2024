import common/grid2d
import day16/day16.{
  type Direction, type ValidInput, East, North, South, ValidInput, West,
}
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
pub fn dijkstra(
  initial: List(#(Reindeer, Int)),
  walls: set.Set(grid2d.Index2D),
) -> dict.Dict(Reindeer, Int) {
  let queue0 = priority_queue.new(compare_queue_entries)

  let queue =
    list.fold(initial, queue0, fn(acc, entry) {
      let #(state, cost) = entry
      priority_queue.push(acc, #(cost, state))
    })

  let distances =
    list.fold(initial, dict.new(), fn(acc, entry) {
      let #(state, cost) = entry
      dict.insert(acc, state, cost)
    })

  search(queue, distances, walls)
}

/// Given a finished distance map, find the cheapest way to reach the goal tile.
pub fn min_cost_to_goal(
  distances: dict.Dict(Reindeer, Int),
  goal: grid2d.Index2D,
) -> Result(Int, Nil) {
  dict.fold(distances, Error(Nil), fn(acc, state, cost) {
    let #(position, _) = state
    case position == goal {
      True ->
        case acc {
          Error(_) -> Ok(cost)
          Ok(existing) -> Ok(int.min(existing, cost))
        }
      False -> acc
    }
  })
}

/// Internal tail-recursive loop that processes the priority queue until all
/// optimal distances have been discovered.
fn search(
  queue: priority_queue.Queue(QueueEntry),
  distances: dict.Dict(Reindeer, Int),
  walls: set.Set(grid2d.Index2D),
) -> dict.Dict(Reindeer, Int) {
  case priority_queue.pop(queue) {
    Error(_) -> distances
    Ok(#(queue_entry, remaining_queue)) -> {
      let #(cost, state) = queue_entry

      case dict.get(distances, state) {
        Ok(best_cost) if cost > best_cost ->
          search(remaining_queue, distances, walls)

        _ -> {
          let #(next_queue, next_distances) =
            list.fold(
              next_possible_states(state, walls),
              #(remaining_queue, distances),
              fn(acc, edge) {
                let #(queue_acc, dist_acc) = acc
                let #(neighbor_state, step_cost) = edge
                let new_cost = cost + step_cost

                case dict.get(dist_acc, neighbor_state) {
                  Ok(existing_cost) if new_cost >= existing_cost -> #(
                    queue_acc,
                    dist_acc,
                  )
                  _ -> {
                    let dist_acc =
                      dict.insert(dist_acc, neighbor_state, new_cost)
                    let queue_acc =
                      priority_queue.push(queue_acc, #(new_cost, neighbor_state))
                    #(queue_acc, dist_acc)
                  }
                }
              },
            )

          search(next_queue, next_distances, walls)
        }
      }
    }
  }
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

/// Convenience accessor that hides the tuple juggling in `ValidInput`.
pub fn start_state(valid_input: ValidInput) -> Reindeer {
  let ValidInput(start_state, _, _) = valid_input
  start_state
}

/// Extract the wall set from the parsed input.
pub fn walls(valid_input: ValidInput) -> set.Set(grid2d.Index2D) {
  let ValidInput(_, _, walls) = valid_input
  walls
}

/// Extract just the goal coordinate.
pub fn goal(valid_input: ValidInput) -> grid2d.Index2D {
  let ValidInput(_, goal, _) = valid_input
  goal
}
