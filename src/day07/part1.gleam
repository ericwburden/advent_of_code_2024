import day07/day07.{type EquationParts, type Input, type Output, EquationParts}
import day07/parse
import gleam/io
import gleam/list
import gleam/result

pub fn can_solve_equation(
  equation_parts: EquationParts,
  operations: List(fn(Int, Int) -> Int),
) -> Bool {
  let EquationParts(test_value, components) = equation_parts
  case components {
    [first_component, ..rest] ->
      recurse_can_solve_equation(test_value, rest, first_component, operations)
    [] -> False
  }
}

fn recurse_can_solve_equation(
  target_value: Int,
  remaining_components: List(Int),
  current_total: Int,
  operations: List(fn(Int, Int) -> Int),
) -> Bool {
  case remaining_components {
    [] -> current_total == target_value
    [next_component, ..rest] -> {
      list.any(operations, fn(op) {
        let next_total = op(current_total, next_component)
        recurse_can_solve_equation(target_value, rest, next_total, operations)
      })
    }
  }
}

pub fn solve(input: Input) -> Output {
  use equation_parts <- result.map(input)

  let valid_operations = [
    fn(a, b) { a + b },
    fn(a, b) { a * b },
  ]

  equation_parts
  |> list.fold(0, fn(acc, eq) {
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
  |> io.debug
}
