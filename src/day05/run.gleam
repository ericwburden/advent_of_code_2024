import day05/day05
import day05/parse
import day05/part1
import day05/part2
import gleam/io

pub const part1_expected = 5087

pub const part2_expected = 4971

pub fn main() {
  let input = parse.read_input(day05.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 05, Part 1")
        False -> panic as "🛑 Failed Day 05, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 05, Part 2")
        False -> panic as "🛑 Failed Day 05, Part 2"
      }
    Error(s) -> panic as s
  }
}
