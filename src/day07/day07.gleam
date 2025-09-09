pub type EquationParts {
  EquationParts(test_value: Int, components: List(Int))
}

pub type Input =
  Result(List(EquationParts), String)

pub type Output =
  Result(Int, String)

pub const input_path = "test/day07/input/input.txt"

pub const example1_path = "test/day07/examples/example1.txt"

pub const example2_path = "test/day07/examples/example2.txt"
