import common/grid2d
import day10/day10.{type Input, type Output}
import day10/parse
import day10/part1.{find_trailheads, score_trailhead}
import gleam/int
import gleam/list

/// Part 2 is actually simpler. Here, we count every peak we encounter every
/// time we encounter it. Because of the structure of the grid and the rules
/// around trails (they form a directed, acyclic graph), we can't backtrack
/// on a valid trail. So, every time we encounter a peak, we have found a new
/// way to get there, and we count it.
fn handle_peak_part2(state: Nil, acc: Int, _head: grid2d.Index2D) -> #(Nil, Int) {
  #(state, acc + 1)
}

/// In order to solve Part 2, we need to grab our input, find the trailheads,
/// then calculate the score for each trailhead based on the number of 
/// times we can find a peak by walking gently uphill from that trailhead.
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
  |> echo
}
