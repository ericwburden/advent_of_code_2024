import day07/day07.{type EquationParts, type Input, type Output, EquationParts}
import day07/parse
import gleam/io
import gleam/list
import gleam/result

/// Given an [EquationParts] and a set of allowed operations, attempt to
/// combine the numbers to yield the test value and return whether or
/// not this is possible. If any combination of operations succeeds in
/// producing the test value, return true.
pub fn can_solve_equation(
  equation_parts: EquationParts,
  operations: List(fn(Int, Int) -> Int),
) -> Bool {
  let EquationParts(test_value, numbers) = equation_parts
  case numbers {
    [first, ..rest] ->
      recurse_can_solve_equation(test_value, rest, first, operations)

    // An empty list of numbers can never produce a test value
    [] -> False
  }
}

/// Recursively check all possible applications of allowed operations to the
/// list of numbers, returning true if any combination of all the numbers 
/// yields the test value.
fn recurse_can_solve_equation(
  test_value: Int,
  remaining: List(Int),
  current_value: Int,
  operations: List(fn(Int, Int) -> Int),
) -> Bool {
  case remaining {
    [] -> current_value == test_value
    [first, ..rest] -> {
      list.any(operations, fn(op) {
        let next_value = op(current_value, first)
        recurse_can_solve_equation(test_value, rest, next_value, operations)
      })
    }
  }
}

/// Given the list of [EquationParts], attempt to solve each one by applying
/// the list of allowed operations, ignoring precedence, to the list of numbers
/// to yield the test value. For each solvable equation, add the test value to
/// the accumulated total.
pub fn solve(input: Input) -> Output {
  use equation_parts <- result.map(input)

  let valid_operations = [
    fn(a, b) { a + b },
    fn(a, b) { a * b },
  ]

  list.fold(equation_parts, 0, fn(acc, eq) {
    case can_solve_equation(eq, valid_operations) {
      True -> acc + eq.test_value
      False -> acc
    }
  })
}

/// This helps with just running this one part
pub fn main() -> Output {
  day07.input_path
  |> parse.read_input
  |> solve
  |> echo
}
