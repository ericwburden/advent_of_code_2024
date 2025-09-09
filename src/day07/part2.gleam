import day07/day07.{type Input, type Output}
import day07/parse
import day07/part1.{can_solve_equation}
import gleam/io
import gleam/list
import gleam/result

fn num_digits(n: Int) -> Int {
  let abs = case n < 0 {
    True -> -n
    False -> n
  }

  case abs {
    0 -> 1
    _ -> recursive_num_digits(abs, 0)
  }
}

fn recursive_num_digits(x: Int, acc: Int) -> Int {
  case x {
    0 -> acc
    _ -> recursive_num_digits(x / 10, acc + 1)
  }
}

fn int_pow(base: Int, exp: Int) -> Int {
  recurse_int_pow(base, exp, 1)
}

fn recurse_int_pow(b: Int, e: Int, acc: Int) -> Int {
  case e {
    0 -> acc
    _ -> recurse_int_pow(b, e - 1, acc * b)
  }
}

pub fn concatenate_numbers(a: Int, b: Int) -> Int {
  let digits_b = num_digits(b)
  a * int_pow(10, digits_b) + b
}

pub fn solve(input: Input) -> Output {
  use equation_parts <- result.map(input)

  let valid_operations = [
    fn(a, b) { a + b },
    fn(a, b) { a * b },
    concatenate_numbers,
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
