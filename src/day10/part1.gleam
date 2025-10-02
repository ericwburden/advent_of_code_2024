import common/grid2d
import day10/day10.{type Input, type Output}
import day10/parse
import gleam/dict
import gleam/int
import gleam/list
import gleam/set

/// Search through the grid and find the indices that correspond to trailheads.
/// It's all the locations in the grid occupied by '0'.
pub fn find_trailheads(grid: grid2d.Grid2D(Int)) -> List(grid2d.Index2D) {
  dict.filter(grid, fn(_, v) { v == 0 }) |> dict.keys
}

/// Given our input grid (the heightmap), the location of the trailhead to
/// score, some initial state, and a function to determine how to handle a
/// peak when we find one, calculate the total score for a given trailhead.
/// This function is a bit more complicated than it strictly needs to be
/// for part 1, but that's to help with part 2. For part 1, the state we're
/// interested in is a set of all the locations of peaks we've visited from
/// the given trailhead, so that we count each peak uniquely.
pub fn score_trailhead(
  grid: grid2d.Grid2D(Int),
  trailhead: grid2d.Index2D,
  initial_state: s,
  handle_peak: fn(s, Int, grid2d.Index2D) -> #(s, Int),
) -> Int {
  recurse_score_trailhead(grid, [trailhead], 0, initial_state, handle_peak)
}

/// Recursively perform a depth-first search through the grid to score the 
/// given trailhead. Trailheads are scored a bit differently in part 1 and 
/// part 2, but only in how peaks are counted. In part 1, we count each 
/// peak uniquely.
fn recurse_score_trailhead(
  grid: grid2d.Grid2D(Int),
  stack: List(grid2d.Index2D),
  acc: Int,
  state: s,
  handle_peak: fn(s, Int, grid2d.Index2D) -> #(s, Int),
) -> Int {
  // We're performing a depth-first search, so we'll continue until our stack
  // runs out.
  case stack {
    [] -> acc

    // While there are any values left to search...
    [head, ..rest] ->
      case grid2d.get(grid, head) {
        // If the next location to search is a peak (value of 9), then we need
        // to know whether or not we've counted it. We'll pass the peak 
        // location off to a separate handler and get back an updated state 
        // and accumulator, then keep going with those updates.
        Ok(9) -> {
          let #(new_state, new_acc) = handle_peak(state, acc, head)
          recurse_score_trailhead(grid, rest, new_acc, new_state, handle_peak)
        }

        // If the next location is anything other than a peak, we find all the
        // neighboring spaces with a height exactly one more than the current
        // space and add them to the stack to search on the next round.
        Ok(val) -> {
          let next_steps =
            grid2d.cardinal_neighbors_like(grid, head, fn(nv) { nv == val + 1 })
          let new_stack = list.append(next_steps, rest)
          recurse_score_trailhead(grid, new_stack, acc, state, handle_peak)
        }

        // This can't happen. We would only get an error if we tried to search
        // an index not in our grid, but the `grid2d.cardinal_neighbors_like`
        // function does the bounds-checking for us.
        Error(_) -> panic as "Out-of-bounds index should be impossible here"
      }
  }
}

/// In part 1, we only count peaks we haven't seen before. So, our state
/// consists of the set of locations for peaks we _have_ seen. If the
/// current peak is new, add it to the set and increase the accumulator. 
/// Otherwise, return the state and accumulator as-is.
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

/// In order to solve Part 1, we need to grab our input, find the trailheads,
/// then calculate the score for each trailhead based on the number of 
/// unique peaks that can be found walking gently uphill from that trailhead.
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
  |> echo
}
