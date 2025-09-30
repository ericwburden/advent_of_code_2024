import common/grid2d

pub type Input =
  Result(grid2d.Grid2D(UtfCodepoint), String)

pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day12/input.txt"

pub const example1_path = "test/day12/examples/example1.txt"

pub const example2_path = "test/day12/examples/example2.txt"
