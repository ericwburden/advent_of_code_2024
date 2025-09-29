import common/grid2d
import day10/day10.{type Input, type Output}
import day10/parse
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set

pub fn find_trailheads(grid: grid2d.Grid2D(Int)) -> List(grid2d.Index2D) {
  dict.filter(grid, fn(_, v) { v == 0 }) |> dict.keys
}

pub fn score_trailhead(
  grid: grid2d.Grid2D(Int),
  trailhead: grid2d.Index2D,
  initial_state: s,
  handle_peak: fn(s, Int, grid2d.Index2D) -> #(s, Int),
) -> Int {
  recurse_score_trailhead(grid, [trailhead], 0, initial_state, handle_peak)
}

fn recurse_score_trailhead(
  grid: grid2d.Grid2D(Int),
  stack: List(grid2d.Index2D),
  acc: Int,
  state: s,
  handle_peak: fn(s, Int, grid2d.Index2D) -> #(s, Int),
) -> Int {
  case stack {
    [] -> acc
    [head, ..rest] ->
      case grid2d.get(grid, head) {
        Ok(9) -> {
          let #(new_state, new_acc) = handle_peak(state, acc, head)
          recurse_score_trailhead(grid, rest, new_acc, new_state, handle_peak)
        }
        Ok(val) -> {
          let next_steps =
            grid2d.cardinal_neighbors_like(grid, head, fn(nv) { nv == val + 1 })
          let new_stack = list.append(next_steps, rest)
          recurse_score_trailhead(grid, new_stack, acc, state, handle_peak)
        }

        Error(_) -> panic as "Out-of-bounds index should be impossible here"
      }
  }
}

fn handle_peak_part1(
  peaks_seen: set.Set(grid2d.Index2D),
  acc: Int,
  head: grid2d.Index2D,
) -> #(set.Set(grid2d.Index2D), Int) {
  case set.contains(peaks_seen, head) {
    True -> #(peaks_seen, acc)
    False -> #(set.insert(peaks_seen, head), acc + 1)
  }
}

pub fn solve(input: Input) -> Output {
  let checksum =
    input
    |> find_trailheads
    |> list.map(fn(trailhead) {
      score_trailhead(input, trailhead, set.new(), handle_peak_part1)
    })
    |> int.sum

  Ok(checksum)
}

pub fn main() {
  day10.input_path
  |> parse.read_input
  |> solve
  |> io.debug
}
