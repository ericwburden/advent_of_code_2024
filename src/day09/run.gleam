import day09/day09
import day09/parse
import day09/part1
import day09/part2
import gleam/io

pub const part1_expected = 0

pub const part2_expected = 0

pub fn main() {
  let input = parse.read_input(day09.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 09, Part 1")
        False -> panic as "🛑 Failed Day 09, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 09, Part 2")
        False -> panic as "🛑 Failed Day 09, Part 2"
      }
    Error(s) -> panic as s
  }
}
