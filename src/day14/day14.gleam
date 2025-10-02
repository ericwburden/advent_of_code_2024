import common/grid2d

pub type Robot {
  Robot(position: grid2d.Index2D, velocity: grid2d.Offset2D)
}

pub type Input =
  Result(List(Robot), String)

pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day14/input.txt"

pub const example1_path = "test/day14/examples/example1.txt"

pub const example2_path = "test/day14/examples/example2.txt"
