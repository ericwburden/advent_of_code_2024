import common/fns
import day07/day07.{type Input, type Output}
import day07/parse
import day07/part1.{can_solve_equation}
import gleam/io
import gleam/list
import gleam/result

/// Using our common helper functions, concatenate two integers into a 
/// bigger integer, using math! Because type conversions are lame (and 
/// less performant than using math).
pub fn concat_ints(a: Int, b: Int) -> Int {
  let digits_b = fns.n_digits(b)
  a * fns.int_pow(10, digits_b) + b
}

/// The only difference from Part 1 here is the addition of the `concat_ints`
/// function to the list of allowed operations.
pub fn solve(input: Input) -> Output {
  use equation_parts <- result.map(input)

  let valid_operations = [
    fn(a, b) { a + b },
    fn(a, b) { a * b },
    concat_ints,
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
