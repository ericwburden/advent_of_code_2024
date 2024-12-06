import day04/day04
import gleam/dict.{type Dict}

pub type Direction {
  North
  East
  South
  West
}

pub type Space {
  Obstacle
  Empty
}

pub type Guard {
  Guard(location: day04.Index2D, direction: Direction)
}

pub type PatrolMap =
  Dict(day04.Index2D, Space)

pub type Input =
  Result(#(Guard, PatrolMap), String)

pub type Output =
  Result(Int, String)

pub const input_path = "test/day06/input/input.txt"

pub const example1_path = "test/day06/examples/example1.txt"

pub const example2_path = "test/day06/examples/example2.txt"
