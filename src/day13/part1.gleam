import day13/day13.{
  type Button, type Input, type Machine, type Output, type Prize, Machine,
}
import day13/parse
import gleam/int
import gleam/io
import gleam/list
import gleam/result

/// Compute the cross-product `a.dx * b.dy - a.dy * b.dx`. If this is zero, the
/// two button vectors are linearly dependent, so the system either has no
/// solution or infinitely many, and we cannot isolate unique press counts.
fn determinant(a: Button, b: Button) -> Int {
  { a.dx * b.dy } - { a.dy * b.dx }
}

/// Eliminate `p_b` by multiplying the first equation by `b.dy` and the second
/// by `b.dx`, then subtracting. The terms involving `p_b` cancel, leaving the
/// numerator for `p_a` as `prize.x * b.dy - b.dx * prize.y`.
fn numerator_for_a(b: Button, prize: Prize) -> Int {
  { prize.x * b.dy } - { b.dx * prize.y }
}

/// Similarly, eliminate `p_a` by multiplying the first equation by `a.dy` and
/// the second by `a.dx`, then subtracting to cancel the `p_a` terms. The
/// resulting numerator for `p_b` is `a.dx * prize.y - a.dy * prize.x`.
fn numerator_for_b(a: Button, prize: Prize) -> Int {
  { a.dx * prize.y } - { a.dy * prize.x }
}

/// Check that the numerator divides evenly by the determinant so that the
/// solution remains an integer number of button presses.
fn divides(numerator: Int, denominator: Int) -> Bool {
  numerator % denominator == 0
}

/// Apply the algebraic rearrangements above to obtain integer press counts.
/// If the determinant is zero we report the lack of a unique solution.
/// Otherwise we verify both quotients are integral and return them.
pub fn solve_machine(machine: Machine) -> Result(#(Int, Int), String) {
  let Machine(a: button_a, b: button_b, prize: prize) = machine
  let det = determinant(button_a, button_b)

  case det {
    0 -> Error("System does not have a unique solution")
    _ -> {
      let numerator_a = numerator_for_a(button_b, prize)
      let numerator_b = numerator_for_b(button_a, prize)

      case divides(numerator_a, det) && divides(numerator_b, det) {
        False -> Error("System does not have an integer solution")
        True -> {
          let p_a = numerator_a / det
          let p_b = numerator_b / det
          Ok(#(p_a, p_b))
        }
      }
    }
  }
}

pub fn calculate_token_cost(presses: #(Int, Int)) -> Int {
  let #(a_presses, b_presses) = presses
  { a_presses * 3 } + b_presses
}

/// Solve Part 1 by walking each input machine through the algebra described
/// above. For every machine we have the following system of linear equations
/// that can be used to solve for the number of button presses:
///
///   A.dx * p_a + B.dx * p_b = prize.x
///   A.dy * p_a + B.dy * p_b = prize.y
/// 
/// To solve this system of equations, we:
///
/// 1. Expand the two equations and check the cross-product `determinant` to
///    confirm the button vectors are not linearly dependent, i.e. that the
///    lines drawn in the X/Y plane by the button presses aren't either the
///    same line or parallel lines (meaning there's either no solution or
///    infinite solutions).
/// 2. Rearrange the equations to eliminate one variable at a time, computing
///    the numerators for `p_a` and `p_b` via the subtraction steps shown in
///    `numerator_for_a`/`numerator_for_b`.
/// 3. Ensure both numerators divide cleanly by the determinant so the result is
///    a whole number of presses. If either fails, the machine yields no valid
///    integer solution and is skipped.
/// 4. Convert the pair of presses into the token cost (`3 * p_a + p_b`) and add
///    it to the running total.
///
/// Only machines with valid integer solutions contribute to the sum.
pub fn solve(input: Input) -> Output {
  use machines <- result.try(input)

  let result =
    machines
    |> list.filter_map(solve_machine)
    |> list.map(calculate_token_cost)
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  day13.input_path |> parse.read_input |> solve |> echo
}
