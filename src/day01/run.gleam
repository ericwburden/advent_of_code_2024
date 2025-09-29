import day01/day01
import day01/parse
import day01/part1
import day01/part2
import gleam/io

pub const part1_expected = 2_176_849

pub const part2_expected = 23_384_288

pub fn main() {
  let input = parse.read_input(day01.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 01, Part 1")
        False -> panic as "🛑 Failed Day 01, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 01, Part 2")
        False -> panic as "🛑 Failed Day 01, Part 2"
      }
    Error(s) -> panic as s
  }
}
