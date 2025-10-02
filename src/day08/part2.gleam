import common/types.{type Index2D}
import day08/day08.{type Antenna, type Bounds, type Input, type Output, Antenna}
import day08/parse
import day08/part1
import gleam/list
import gleam/result
import gleam/set

/// Now, antinodes start at the location of the second [Antenna] and repeat
/// to the edges of the grid, evenly spaced along a straight line. 
fn find_harmonic_antinodes(
  antenna1: Antenna,
  antenna2: Antenna,
  bounds: Bounds,
) -> List(Index2D) {
  let Antenna(_, idx1) = antenna1
  let Antenna(_, idx2) = antenna2
  let offset = part1.get_offset(idx1, idx2)
  recursive_find_harmonic_antinodes(idx2, bounds, offset, [])
}

/// Recursively build the list of antinodes, starting with the antinode at 
/// `idx2`, adding an antinode at each offset until the edge of the grid
/// is reached.
fn recursive_find_harmonic_antinodes(
  antinode_idx: Index2D,
  bounds: Bounds,
  offset: #(Int, Int),
  acc: List(Index2D),
) -> List(Index2D) {
  // If the `antinode_idx` is out of bounds, just return the list already
  // compiled.
  case part1.is_inbounds(antinode_idx, bounds) {
    False -> acc
    True -> {
      // If the `antinode_idx` is in bounds, add it to the list, and check
      // the next location provided by the offset.
      let acc = [antinode_idx, ..acc]
      let next_antinode_idx = part1.add_offset(offset, antinode_idx)
      recursive_find_harmonic_antinodes(next_antinode_idx, bounds, offset, acc)
    }
  }
}

/// Part 2 is exactly the same as Part 1, just subbing in the new function for
/// identifying the multiple antinodes created by harmonic convergence (or 
/// whatever it's called).
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let #(bounds, antennae, antennae_by_label) = input

  let find_all_antinodes = fn(antenna) {
    antenna
    |> part1.get_complementary_antennae(antennae_by_label)
    |> list.flat_map(fn(o) { find_harmonic_antinodes(antenna, o, bounds) })
  }

  let antinode_list = list.flat_map(antennae, find_all_antinodes)

  let antinode_count =
    antinode_list
    |> set.from_list
    |> set.size

  Ok(antinode_count)
}

pub fn main() -> Output {
  day08.input_path
  |> parse.read_input
  |> solve
  |> echo
}
