import common/grid2d
import day10/day10.{type Input, type Output}
import day10/parse
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set

fn find_trailheads(grid: grid2d.Grid2D(Int)) -> List(grid2d.Index2D) {
  dict.filter(grid, fn(_, v) { v == 0 }) |> dict.keys
}

fn calc_trailhead_score(
  grid: grid2d.Grid2D(Int),
  trailhead: grid2d.Index2D,
) -> Int {
  recurse_calc_trailhead_score(grid, [trailhead], set.new(), 0)
}

fn recurse_calc_trailhead_score(
  grid: grid2d.Grid2D(Int),
  stack: List(grid2d.Index2D),
  peaks_seen: set.Set(grid2d.Index2D),
  acc: Int,
) -> Int {
  case stack {
    [] -> acc
    [head, ..rest] ->
      case grid2d.get(grid, head) {
        Ok(9) -> handle_peak(grid, rest, peaks_seen, acc, head)
        Ok(val) -> {
          let next_steps =
            grid2d.cardinal_neighbors_like(grid, head, fn(neighbor_val) {
              neighbor_val == val + 1
            })
          let new_stack = list.append(next_steps, rest)
          recurse_calc_trailhead_score(grid, new_stack, peaks_seen, acc)
        }

        Error(_) -> panic as "Out-of-bounds index should be impossible here"
      }
  }
}

fn handle_peak(
  grid: grid2d.Grid2D(Int),
  rest: List(grid2d.Index2D),
  peaks_seen: set.Set(grid2d.Index2D),
  acc: Int,
  head: grid2d.Index2D,
) -> Int {
  case set.contains(peaks_seen, head) {
    True -> recurse_calc_trailhead_score(grid, rest, peaks_seen, acc)

    False -> {
      let updated_peaks = set.insert(peaks_seen, head)
      recurse_calc_trailhead_score(grid, rest, updated_peaks, acc + 1)
    }
  }
}

pub fn solve(input: Input) -> Output {
  let checksum =
    input
    |> find_trailheads
    |> list.map(fn(trailhead) { calc_trailhead_score(input, trailhead) })
    |> int.sum

  Ok(checksum)
}

pub fn main() {
  day10.input_path
  |> parse.read_input
  |> solve
  |> io.debug
}
