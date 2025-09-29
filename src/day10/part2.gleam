import common/grid2d
import day10/day10.{type Input, type Output}
import day10/parse
import day10/part1.{find_trailheads, score_trailhead}
import gleam/int
import gleam/io
import gleam/list

fn handle_peak_part2(state: Nil, acc: Int, _head: grid2d.Index2D) -> #(Nil, Int) {
  #(state, acc + 1)
}

pub fn solve(input: Input) -> Output {
  let checksum =
    input
    |> find_trailheads
    |> list.map(fn(trailhead) {
      score_trailhead(input, trailhead, Nil, handle_peak_part2)
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
