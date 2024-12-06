import day06/day06.{type Guard, type Input, type Output, type PatrolMap}
import day06/parse
import day06/part1
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}

fn does_path_loop(guard: Guard, patrol_map: PatrolMap) -> Bool {
  recurse_does_path_loop(guard, patrol_map, set.new())
}

fn recurse_does_path_loop(
  guard: Guard,
  patrol_map: PatrolMap,
  path: Set(#(Guard, Guard)),
) -> Bool {
  case part1.move_guard(guard, patrol_map) {
    Error(Nil) -> False
    Ok(next_guard) -> {
      let step = #(guard, next_guard)
      case set.contains(path, step) {
        True -> True
        False -> {
          let path = set.insert(path, step)
          recurse_does_path_loop(next_guard, patrol_map, path)
        }
      }
    }
  }
}

pub fn solve(input: Input) -> Output {
  use #(guard, patrol_map) <- result.map(input)

  let path = part1.trace_guard_path(guard, patrol_map)
  set.to_list(path)
  |> list.filter(fn(idx) {
    let test_map = dict.insert(patrol_map, idx, day06.Obstacle)
    does_path_loop(guard, test_map)
  })
  |> list.length
}

/// Apparently running this takes too long for the unit test framework. Lame!
pub fn main() -> Output {
  day06.input_path
  |> parse.read_input
  |> solve
  |> io.debug
}
