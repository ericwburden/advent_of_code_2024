import day13/day13
import day13/parse
import day13/part1
import day13/part2
import gleam/io

pub const part1_expected = 31_897

pub const part2_expected = 87_596_249_540_359

pub fn main() {
  let input = parse.read_input(day13.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 13, Part 1")
        False -> panic as "🛑 Failed Day 13, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 13, Part 2")
        False -> panic as "🛑 Failed Day 13, Part 2"
      }
    Error(s) -> panic as s
  }
}
