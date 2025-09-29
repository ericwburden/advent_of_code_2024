import day04/day04
import day04/parse
import day04/part1
import day04/part2
import gleam/io

pub const part1_expected = 2297

pub const part2_expected = 1745

pub fn main() {
  let input = parse.read_input(day04.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 04, Part 1")
        False -> panic as "🛑 Failed Day 04, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 04, Part 2")
        False -> panic as "🛑 Failed Day 04, Part 2"
      }
    Error(s) -> panic as s
  }
}
