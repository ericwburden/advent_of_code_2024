import common/grid2d

pub type ValidatedInput {
  ValidatedInput(
    grid: grid2d.Grid2D(Bool),
    start: grid2d.Index2D,
    end: grid2d.Index2D,
  )
}

pub type Input =
  Result(ValidatedInput, String)

pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day20/input.txt"

pub const example1_path = "test/day20/examples/example1.txt"

pub const example2_path = "test/day20/examples/example2.txt"
