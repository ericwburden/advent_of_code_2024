import day08/day08
import day08/parse
import day08/part1
import day08/part2
import gleam/io

pub const part1_expected = 0

pub const part2_expected = 0

pub fn main() {
  let input = parse.read_input(day08.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 08, Part 1")
        False -> panic as "🛑 Failed Day 08, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 08, Part 2")
        False -> panic as "🛑 Failed Day 08, Part 2"
      }
    Error(s) -> panic as s
  }
}
