import day07/day07.{type Input, type Output}
import day07/parse
import day07/part1.{can_solve_equation}
import gleam/io
import gleam/list
import gleam/result

/// Calculate the number of digits in an integer, using math!
fn num_digits(n: Int) -> Int {
  let abs = case n < 0 {
    True -> -n
    False -> n
  }

  // Zero has one digit. For everything else, we need to calculate.
  case abs {
    0 -> 1
    _ -> recursive_num_digits(abs, 0)
  }
}

/// Recursively divide the number by 10, adding one to the count of digits
/// each time there's a remainder from this operation.
fn recursive_num_digits(n: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> recursive_num_digits(n / 10, acc + 1)
  }
}

/// Looks like we need to write our own exponentiation function, using
/// recursion!
fn int_pow(base: Int, exp: Int) -> Int {
  recurse_int_pow(base, exp, 1)
}

/// Recursively calculate the result of raising [base] to the [exp] power.
fn recurse_int_pow(base: Int, exp: Int, acc: Int) -> Int {
  case exp {
    0 -> acc
    _ -> recurse_int_pow(base, exp - 1, acc * base)
  }
}

/// Using all our helper functions above, concatenate two integers into a 
/// bigger integer, using math! Because type conversions are lame (and 
/// less performant than using math).
pub fn concat_ints(a: Int, b: Int) -> Int {
  let digits_b = num_digits(b)
  a * int_pow(10, digits_b) + b
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
  |> io.debug
}
