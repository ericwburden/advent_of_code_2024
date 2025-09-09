import day04/day04
import day06/day06.{type Guard, type Input, type Output, type PatrolMap}
import gleam/dict
import gleam/list
import gleam/result
import gleam/set

/// Give a [Guard] and the [PatrolMap], move that [Guard] one space forward,
/// where 'forward' depends on the [Guard]'s location, heading, and potential
/// obstacles.
pub fn move_guard(guard: Guard, patrol_map: PatrolMap) -> Result(Guard, Nil) {
  case dict.has_key(patrol_map, guard.location) {
    False -> panic as "Guard started off the map somehow!"
    True -> {
      // Find the index of the next space the guard wants to move to.
      let day04.Index2D(row, col) = guard.location
      let next_space_idx = case guard.direction {
        day06.East -> day04.Index2D(..guard.location, col: col + 1)
        day06.North -> day04.Index2D(..guard.location, row: row - 1)
        day06.South -> day04.Index2D(..guard.location, row: row + 1)
        day06.West -> day04.Index2D(..guard.location, col: col - 1)
      }

      // If that space is empty, move the guard there. If it's an obstacle,
      // turn the guard to the right.
      case dict.get(patrol_map, next_space_idx) {
        Error(_) -> Error(Nil)
        Ok(day06.Empty) -> Ok(day06.Guard(..guard, location: next_space_idx))
        Ok(day06.Obstacle) ->
          case guard.direction {
            day06.East -> Ok(day06.Guard(..guard, direction: day06.South))
            day06.North -> Ok(day06.Guard(..guard, direction: day06.East))
            day06.South -> Ok(day06.Guard(..guard, direction: day06.West))
            day06.West -> Ok(day06.Guard(..guard, direction: day06.North))
          }
      }
    }
  }
}

/// Keep moving the [Guard] forward until they exit the map and return
/// the list of [Guard] states that the [Guard] moves through to find the
/// exit.
pub fn trace_guard_path(guard: Guard, patrol_map: PatrolMap) -> List(Guard) {
  recurse_trace_guard_path(guard, patrol_map, [guard])
}

/// Recursively build up the list of [Guard] states that represent a path
/// through the grid.
fn recurse_trace_guard_path(
  guard: Guard,
  patrol_map: PatrolMap,
  path: List(Guard),
) -> List(Guard) {
  case move_guard(guard, patrol_map) {
    Error(Nil) -> path
    Ok(next_guard) -> {
      let path = [next_guard, ..path]
      recurse_trace_guard_path(next_guard, patrol_map, path)
    }
  }
}

/// Take the [Guard] and [PatrolMap], walk the [Guard] through the map,
/// count the number of unique locations the [Guard] moves through, and
/// return that count.
pub fn solve(input: Input) -> Output {
  use #(guard, patrol_map) <- result.map(input)
  trace_guard_path(guard, patrol_map)
  |> list.fold(set.new(), fn(acc, g) { set.insert(acc, g.location) })
  |> set.size
}
