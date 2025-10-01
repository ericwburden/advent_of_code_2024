import day13/day13.{type Input, type Machine, type Output, Machine, Prize}
import day13/parse
import day13/part1.{calculate_token_cost, solve_machine}
import gleam/int
import gleam/io
import gleam/list
import gleam/result

/// For Part 2 every prize coordinate is offset by `10_000_000_000_000` in both
/// axes before solving. This helper leaves the button definitions untouched and
/// adds the offset to the prize.
pub fn adjust_prize(machine: Machine) -> Machine {
  let Machine(a: button_a, b: button_b, prize: prize) = machine
  let Prize(x: x, y: y) = prize
  Machine(
    a: button_a,
    b: button_b,
    prize: Prize(x: x + 10_000_000_000_000, y: y + 10_000_000_000_000),
  )
}

/// Part 2 mirrors Part 1 with the sole change that prizes are shifted *way*
/// out before solving. We map each machine through `adjust_prize`, then 
/// reuse the Part 1 solver and token-cost calculation to accumulate the total.
pub fn solve(input: Input) -> Output {
  use machines <- result.try(input)

  let result =
    machines
    |> list.map(adjust_prize)
    |> list.filter_map(solve_machine)
    |> list.map(calculate_token_cost)
    |> int.sum

  Ok(result)
}

pub fn main() -> Output {
  day13.input_path |> parse.read_input |> solve |> echo
}
