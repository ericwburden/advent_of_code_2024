import common/grid2d

/// Parsed Day 18 input is the ordered list of byte coordinates that crash
/// into the grid, top to bottom, left to right.
pub type Input =
  Result(List(grid2d.Index2D), String)

/// Part 1 reports the number of steps required to reach the exit, wrapped in
/// the `Result` style used throughout the project.
pub type Output =
  Result(Int, String)

/// Location of the full puzzle input bundled with the repo.
pub const input_path = "inputs/day18/input.txt"

/// Example taken from the puzzle text.
pub const example1_path = "test/day18/examples/example1.txt"

/// Slightly larger example that was helpful while debugging the solver.
pub const example2_path = "test/day18/examples/example2.txt"
