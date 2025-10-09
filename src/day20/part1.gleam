import common/grid2d
import day20/day20.{type Input, type Output, ValidatedInput}
import day20/parse
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set

pub fn get_valid_neighbors(
  grid: grid2d.Grid2D(Bool),
  state: #(grid2d.Index2D, Int),
) -> List(#(grid2d.Index2D, Int)) {
  let #(index, cheats_remaining) = state

  case dict.get(grid, index) {
    Error(Nil) -> []
    Ok(current_tile) ->
      case current_tile {
        True ->
          grid2d.cardinal_offsets
          |> list.map(fn(offset) { grid2d.apply_offset(index, offset) })
          |> list.filter_map(fn(candidate) {
            case dict.get(grid, candidate) {
              Ok(True) -> Ok(#(candidate, cheats_remaining))
              Ok(False) ->
                case cheats_remaining > 0 {
                  True -> Ok(#(candidate, cheats_remaining - 1))
                  False -> Error(Nil)
                }
              Error(Nil) -> Error(Nil)
            }
          })
        False ->
          case cheats_remaining > 0 {
            False -> []
            True ->
              grid2d.cardinal_offsets
              |> list.map(fn(offset) { grid2d.apply_offset(index, offset) })
              |> list.filter_map(fn(candidate) {
                case dict.get(grid, candidate) {
                  Ok(_) -> Ok(#(candidate, cheats_remaining - 1))
                  Error(Nil) -> Error(Nil)
                }
              })
          }
      }
  }
}

pub fn shortest_path_length(
  grid: grid2d.Grid2D(Bool),
  start: #(grid2d.Index2D, Int),
  goal: #(grid2d.Index2D, Int),
) -> Result(List(Int), String) {
  let initial_visited = set.from_list([start])
  let lengths = collect_path_lengths(grid, goal, start, 0, initial_visited)

  case lengths {
    [] -> Error("Could not find a path through the grid")
    lengths -> Ok(lengths)
  }
}

fn collect_path_lengths(
  grid: grid2d.Grid2D(Bool),
  goal: #(grid2d.Index2D, Int),
  current: #(grid2d.Index2D, Int),
  steps: Int,
  visited: set.Set(#(grid2d.Index2D, Int)),
) -> List(Int) {
  case current == goal {
    True -> [steps]
    False -> {
      let visited_next = set.insert(visited, current)

      let neighbors =
        get_valid_neighbors(grid, current)
        |> list.filter(fn(neighbor) { !set.contains(visited_next, neighbor) })

      neighbors
      |> list.flat_map(fn(neighbor) {
        collect_path_lengths(grid, goal, neighbor, steps + 1, visited_next)
      })
    }
  }
}

pub fn solve(input: Input) -> Output {
  use valid_input <- result.try(input)
  let ValidatedInput(grid, start, end) = valid_input
  let threshold = 100

  let fair_start = #(start, 0)
  let goal_state = #(end, 0)
  let try_all_fair_paths = shortest_path_length(grid, fair_start, goal_state)
  use all_fair_path_lengths <- result.try(try_all_fair_paths)

  let try_shortest_fair_path =
    all_fair_path_lengths
    |> list.reduce(int.min)
    |> result.map_error(fn(_) { "Could not find any fair path!" })
  use shortest_fair_path <- result.try(try_shortest_fair_path)

  let cheat_start = #(start, 2)
  let try_all_cheat_paths = shortest_path_length(grid, cheat_start, goal_state)
  use all_cheat_paths <- result.try(try_all_cheat_paths)

  let cheats_above_threshold =
    list.filter(all_cheat_paths, fn(path_length) {
      { shortest_fair_path - path_length } >= threshold
    })
    |> list.length
  Ok(cheats_above_threshold)
}

pub fn main() -> Output {
  day20.input_path |> parse.read_input |> solve |> echo
}
