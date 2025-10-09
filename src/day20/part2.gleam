import day20/day20.{type Input, type Output}
import day20/parse
import day20/part1

pub const cheat_distance = 20
pub const savings_threshold = part1.default_savings_threshold

pub fn solve(input: Input, cheat_steps: Int, threshold: Int) -> Output {
  part1.solve(input, cheat_steps, threshold)
}

pub fn main() -> Output {
  day20.input_path |> parse.read_input |> solve(cheat_distance, savings_threshold) |> echo
}
