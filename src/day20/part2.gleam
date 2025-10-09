import day20/day20.{type Input, type Output}
import day20/parse
import day20/part1

pub fn solve(input: Input, cheat_steps: Int, threshold: Int) -> Output {
  part1.solve(input, cheat_steps, threshold)
}

pub fn main() -> Output {
  day20.example1_path |> parse.read_input |> solve(20, 50) |> echo
}
