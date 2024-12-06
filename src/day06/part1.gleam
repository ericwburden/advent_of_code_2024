import day04/day04
import day06/day06.{type Guard, type Input, type Output, type PatrolMap}
import gleam/dict
import gleam/result
import gleam/set.{type Set}

pub fn move_guard(guard: Guard, patrol_map: PatrolMap) -> Result(Guard, Nil) {
  case dict.has_key(patrol_map, guard.location) {
    False -> panic as "Guard started off the map somehow!"
    True -> {
      let day04.Index2D(row, col) = guard.location
      let next_space_idx = case guard.direction {
        day06.East -> day04.Index2D(..guard.location, col: col + 1)
        day06.North -> day04.Index2D(..guard.location, row: row - 1)
        day06.South -> day04.Index2D(..guard.location, row: row + 1)
        day06.West -> day04.Index2D(..guard.location, col: col - 1)
      }

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

pub fn trace_guard_path(
  guard: Guard,
  patrol_map: PatrolMap,
) -> Set(day04.Index2D) {
  let path = set.new() |> set.insert(guard.location)
  recurse_trace_guard_path(guard, patrol_map, path)
}

fn recurse_trace_guard_path(
  guard: Guard,
  patrol_map: PatrolMap,
  path: Set(day04.Index2D),
) -> Set(day04.Index2D) {
  case move_guard(guard, patrol_map) {
    Error(Nil) -> path
    Ok(next_guard) -> {
      let path = set.insert(path, next_guard.location)
      recurse_trace_guard_path(next_guard, patrol_map, path)
    }
  }
}

pub fn solve(input: Input) -> Output {
  use #(guard, patrol_map) <- result.map(input)
  trace_guard_path(guard, patrol_map) |> set.size
}
