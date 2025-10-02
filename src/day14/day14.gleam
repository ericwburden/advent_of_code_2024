import common/grid2d

/// Day 14's story stars a bunch of robots zooming around a grid. For each
/// Robot, we'll keep track of their position and velocity.
pub type Robot {
  Robot(position: grid2d.Index2D, velocity: grid2d.Offset2D)
}

/// Parsing might fail, so our input is a friendly `Result` that either hands
/// over the list of robots or an error message explaining what went wrong.
pub type Input =
  Result(List(Robot), String)

/// The answer for both parts is a number, even though it means different
/// things for part 1 and part 2.
pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day14/input.txt"

pub const example1_path = "test/day14/examples/example1.txt"

pub const example2_path = "test/day14/examples/example2.txt"
