import common/types.{type Index2D}
import gleam/dict.{type Dict}

/// Represents one antenna, including it's label and location
pub type Antenna {
  Antenna(label: String, location: Index2D)
}

/// A simple type to wrap the bounds of the original grid
pub type Bounds {
  Bounds(rows: Int, cols: Int)
}

/// A lookup for [Antenna]s, allowing easy access to all [Antenna]s with
/// the same label.
pub type AntennaeByLabel =
  Dict(String, List(Antenna))

/// To identify the antinodes created by interfence between two different
/// antennae of the same type, we'll need the list of antennae, the size
/// of the grid, and it helps to have an easy index into the lists of
/// antennae by type.
pub type Input =
  Result(#(Bounds, List(Antenna), AntennaeByLabel), String)

/// The results for this puzzle will be counts of antinodes found.
pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day08/input.txt"

pub const example1_path = "test/day08/examples/example1.txt"

pub const example2_path = "test/day08/examples/example2.txt"
