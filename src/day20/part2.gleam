import day20/day20.{type Input, type Output}
import day20/parse
import day20/part1

/// Part 2 allows a single cheat burst of up to twenty steps while keeping the
/// same savings threshold as part 1.
pub const cheat_distance = 20
pub const savings_threshold = part1.default_savings_threshold

pub fn solve(input: Input) -> Output {
  part1.solve(input, cheat_distance, savings_threshold)
}

pub fn main() -> Output {
  day20.input_path |> parse.read_input |> solve |> echo
}
