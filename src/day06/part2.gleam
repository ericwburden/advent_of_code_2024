import day06/day06.{type Guard, type Input, type Output, type PatrolMap}
import day06/parse
import day06/part1
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}

/// Given a [Guard] and a [PatrolMap], walk the [Guard] forward until they
/// either enter a loop or exit the map. Return whether they enter a loop.
fn does_path_loop(guard: Guard, patrol_map: PatrolMap) -> Bool {
  recurse_does_path_loop(guard, patrol_map, set.new())
}

/// Build up a set of visited [Guard] states as the [Guard] walks through
/// the map. If the [Guard] re-visits a previous state, then we have
/// detected a loop. If the [Guard] exits the map, then there's no loop.
fn recurse_does_path_loop(
  guard: Guard,
  patrol_map: PatrolMap,
  visited: Set(Guard),
) -> Bool {
  case part1.move_guard(guard, patrol_map) {
    Error(Nil) -> False
    Ok(next_guard) -> {
      case set.contains(visited, next_guard) {
        True -> True
        False -> {
          let visited = set.insert(visited, next_guard)
          recurse_does_path_loop(next_guard, patrol_map, visited)
        }
      }
    }
  }
}

/// Take the [Guard] and [PatrolMap], trace their path through the map, then
/// start checking for loops. Return the count of loops that can be made by
/// placing a single [Obstacle] along the [Guard]'s happy path.
pub fn solve(input: Input) -> Output {
  use #(guard, patrol_map) <- result.map(input)

  // Get the happy path
  let path = part1.trace_guard_path(guard, patrol_map)

  // Given the happy path, create a dict where each key is an index in the
  // map and the associated value is the guard state immediately prior to that
  // index. This gives us a set of starting states to begin searching for
  // loops.
  let guard_next_step_pairs =
    path
    |> list.drop(1)
    |> list.zip(path)
    |> list.fold(dict.new(), fn(acc, pair) {
      let #(g1, g2) = pair
      dict.insert(acc, g2.location, g1)
    })

  // With the set of starting states, begin to step through, placing an
  // obstacle immediately in front of the guard, then walking them forward
  // to check for a loop. Count the starting states that yield a loop.
  dict.fold(guard_next_step_pairs, 0, fn(acc, object_idx, prev_guard) {
    let test_map = dict.insert(patrol_map, object_idx, day06.Obstacle)
    case does_path_loop(prev_guard, test_map) {
      True -> acc + 1
      False -> acc
    }
  })
}

/// Apparently running this takes too long for the unit test framework. Lame!
pub fn main() -> Output {
  day06.input_path
  |> parse.read_input
  |> solve
  |> io.debug
}
