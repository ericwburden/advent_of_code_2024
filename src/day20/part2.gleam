import day20/day20.{type Input, type Output}
import day20/parse
import day20/part1

/// Configuration for part 2: the single cheat burst may span up to twenty steps.
pub const cheat_distance = 20

pub const savings_threshold = part1.default_savings_threshold

/// Part 2 reuses the part 1 solver, supplying the puzzle-specific limits.
pub fn solve(input: Input, cheat_steps: Int, threshold: Int) -> Output {
  part1.solve(input, cheat_steps, threshold)
}

/// Command-line entry that runs the part 2 solver against the full input.
pub fn main() -> Output {
  day20.input_path
  |> parse.read_input
  |> solve(cheat_distance, savings_threshold)
  |> echo
}
