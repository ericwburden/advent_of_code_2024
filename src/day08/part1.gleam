import common/fns.{require}
import common/types.{type Index2D, Index2D}
import day08/day08.{
  type Antenna, type AntennaeByLabel, type Bounds, type Input, type Output,
  Antenna, Bounds,
}
import gleam/dict
import gleam/list
import gleam/result
import gleam/set

/// Given a particular [Index2D] and the [Bounds] of the grid, indicate whether
/// that index is within the bounds of the grid.
pub fn is_inbounds(idx: Index2D, bounds: Bounds) {
  let Index2D(row, col) = idx
  let Bounds(rows, cols) = bounds
  row >= 0 && row < rows && col >= 0 && col < cols
}

/// Given two [Index2D], return the offset of the two indices as a 
/// [#(row_offset, col_offset)] tuple. Offsetting idx1 by the
/// return value will yield idx2.
pub fn get_offset(idx1: Index2D, idx2: Index2D) -> #(Int, Int) {
  let Index2D(row1, col1) = idx1
  let Index2D(row2, col2) = idx2
  #(row2 - row1, col2 - col1)
}

/// Offsets an [Index2D] by the offset tuple, yielding the index at that
/// offset.
pub fn add_offset(offset: #(Int, Int), idx: Index2D) -> Index2D {
  let Index2D(row, col) = idx
  let #(row_offset, col_offset) = offset
  Index2D(row + row_offset, col + col_offset)
}

/// Given a single [Antenna] and the [AntennaeByLabel] lookup, get the list
/// of all other antennae that share a type with [Antenna]. If there are none,
/// or if [AntennaeByLabel] doesn't contain an entry for the type of [Antenna],
/// returns an empty list.
pub fn get_complementary_antennae(
  antenna: Antenna,
  antennae_by_label: AntennaeByLabel,
) -> List(Antenna) {
  case dict.get(antennae_by_label, antenna.label) {
    Error(_) -> []
    Ok(other_antennae) ->
      list.filter(other_antennae, fn(other) {
        other.location != antenna.location
      })
  }
}

/// Given two [Antenna]s, find the antinode that is created starting at 
/// `antenna1` and checking on the other side of `antenna2`. If that antinode
/// would be out of bounds of the grid, return [Error(Nil)].
fn find_antinode(
  antenna1: Antenna,
  antenna2: Antenna,
  bounds: Bounds,
) -> Result(Index2D, Nil) {
  let Antenna(label1, location1) = antenna1
  let Antenna(label2, location2) = antenna2

  // Make sure that the two antennae are the same type, but that it's not the 
  // same exact antenna (same location).
  use _ <- result.try(require(label1 == label2))
  use _ <- result.try(require(location1 != location2))

  // The antinode is located on the other side of `antenna2`, equidistant
  // from `antenna1`.
  let offset = get_offset(location1, location2)
  let antinode = add_offset(offset, location2)

  // If the antinode is in the bounds of the grid, return it.
  case is_inbounds(antinode, bounds) {
    True -> Ok(antinode)
    False -> Error(Nil)
  }
}

/// To solve this puzzle, check every [Antenna] against every other [Antenna]
/// of the same type, identify the point on the grid representing the antinode
/// on the other side of the other antennae, then compiling the list of 
/// antinode spaces into a de-duplicated set and returning the number of unique 
/// antinodes.
pub fn solve(input: Input) -> Output {
  use input <- result.try(input)
  let #(bounds, antennae, antennae_by_label) = input

  // Internal function to identify all antinodes associated with a particular
  // [Antenna].
  let find_all_antinodes = fn(antenna) {
    antenna
    |> get_complementary_antennae(antennae_by_label)
    |> list.filter_map(fn(other) { find_antinode(antenna, other, bounds) })
  }

  // Find all the antinodes for every [Antenna].
  let antinode_list = list.flat_map(antennae, find_all_antinodes)

  // Compile the count of unique antinode indices.
  let antinode_count =
    antinode_list
    |> set.from_list
    |> set.size

  Ok(antinode_count)
}
