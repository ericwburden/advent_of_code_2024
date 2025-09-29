/// Each line consists of a target value and a list of space-separated numbers
pub type EquationParts {
  EquationParts(test_value: Int, numbers: List(Int))
}

/// In order to attempt to solve each parial equation, we need a list
///  of each set of equation parts.
pub type Input =
  Result(List(EquationParts), String)

/// The result will be the number of solvable equations using the allowed
/// operations, ignoring precedence.
pub type Output =
  Result(Int, String)

pub const input_path = "inputs/day07/input.txt"

pub const example1_path = "test/day07/examples/example1.txt"

pub const example2_path = "test/day07/examples/example2.txt"
