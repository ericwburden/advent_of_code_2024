pub type Report =
  List(Int)

pub type Input =
  Result(List(Report), String)

pub type Output =
  Result(Int, String)

pub const input_path = "answers/day02/input.txt"

pub const example1_path = "test/day02/examples/example1.txt"

pub const example2_path = "test/day02/examples/example2.txt"
