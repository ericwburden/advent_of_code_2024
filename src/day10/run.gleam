import day10/day10
import day10/parse
import day10/part1
import day10/part2
import gleam/io

pub const part1_expected = 514

pub const part2_expected = 1162

pub fn main() {
  let input = parse.read_input(day10.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 10, Part 1")
        False -> panic as "🛑 Failed Day 10, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 10, Part 2")
        False -> panic as "🛑 Failed Day 10, Part 2"
      }
    Error(s) -> panic as s
  }
}
