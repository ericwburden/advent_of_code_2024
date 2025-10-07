import common/grid2d
import day18/day18.{type Input, type Output}
import day18/parse
import gleam/deque
import gleam/dict
import gleam/list
import gleam/result
import gleam/set

pub fn empty_grid(grid_size: Int) -> grid2d.Grid2D(Bool) {
  list.flat_map(list.range(0, grid_size), fn(row) {
    list.map(list.range(0, grid_size), fn(col) {
      #(grid2d.Index2D(row, col), True)
    })
  })
  |> dict.from_list
}

pub fn corrupt_grid_at(
  grid: grid2d.Grid2D(Bool),
  at: grid2d.Index2D,
) -> grid2d.Grid2D(Bool) {
  dict.insert(grid, at, False)
}

pub fn get_safe_neighbors(
  grid: grid2d.Grid2D(Bool),
  from: grid2d.Index2D,
) -> List(grid2d.Index2D) {
  grid2d.cardinal_neighbors_like(grid, from, fn(v) { v })
}

pub fn find_shortest_path(
  grid: grid2d.Grid2D(Bool),
  start: grid2d.Index2D,
  end: grid2d.Index2D,
) -> Result(Int, String) {
  let queue = deque.new() |> deque.push_back(#(start, 0))
  let visited = set.new() |> set.insert(start)
  find_shortest_path_go(grid, end, queue, visited)
}

fn find_shortest_path_go(
  grid: grid2d.Grid2D(Bool),
  goal: grid2d.Index2D,
  queue: deque.Deque(#(grid2d.Index2D, Int)),
  visited: set.Set(grid2d.Index2D),
) -> Result(Int, String) {
  case deque.pop_front(queue) {
    Error(Nil) -> Error("Could not find a path through the grid!")
    Ok(#(current_entry, rest_queue)) -> {
      let #(current, distance) = current_entry
      case current == goal {
        True -> Ok(distance)
        False -> {
          let new_neighbors =
            get_safe_neighbors(grid, current)
            |> list.filter(fn(idx) { !set.contains(visited, idx) })

          let #(next_queue, next_visited) =
            new_neighbors
            |> list.fold(#(rest_queue, visited), fn(acc, neighbor) {
              let #(acc_queue, acc_seen) = acc
              let updated_queue =
                deque.push_back(acc_queue, #(neighbor, distance + 1))
              let updated_seen = set.insert(acc_seen, neighbor)
              #(updated_queue, updated_seen)
            })

          find_shortest_path_go(grid, goal, next_queue, next_visited)
        }
      }
    }
  }
}

pub fn solve(input: Input, grid_size: Int, num_bytes: Int) -> Output {
  use byte_positions <- result.try(input)
  let grid = empty_grid(grid_size)
  let corrupted_grid =
    byte_positions |> list.take(num_bytes) |> list.fold(grid, corrupt_grid_at)
  let start = grid2d.Index2D(0, 0)
  let end = grid2d.Index2D(grid_size, grid_size)
  find_shortest_path(corrupted_grid, start, end)
}

pub fn main() -> Output {
  day18.input_path |> parse.read_input |> solve(70, 1024) |> echo
}
