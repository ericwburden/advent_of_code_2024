import common/types.{type Index2D}
import gleam/dict.{type Dict}

/// It's helpful to have the cardinal directions as type variants
pub type Direction {
  North
  East
  South
  West
}

/// There are two kinds of spaces on our grid, impassable obstacles and 
/// empty spaces
pub type Space {
  Obstacle
  Empty
}

/// The Guard will move around the map, and they will have their current
/// location and the direction they are heading.
pub type Guard {
  Guard(location: Index2D, direction: Direction)
}

/// The grid the Guard moves around on, a mapping of spatial index to the
/// type of space on the grid.
pub type PatrolMap =
  Dict(Index2D, Space)

/// In order to find the length of the Guard's path, we just need the
/// Guard's location and the map for them to move around on.
pub type Input =
  Result(#(Guard, PatrolMap), String)

/// The result will be a number representing path length and number of 
/// paths matching the criteria (looping).
pub type Output =
  Result(Int, String)

pub const input_path = "answers/day06/input.txt"

pub const example1_path = "test/day06/examples/example1.txt"

pub const example2_path = "test/day06/examples/example2.txt"
