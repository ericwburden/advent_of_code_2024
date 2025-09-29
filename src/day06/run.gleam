import day06/day06
import day06/parse
import day06/part1
import day06/part2
import gleam/io

pub const part1_expected = 4454

pub const part2_expected = 1503

pub fn main() {
  let input = parse.read_input(day06.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 06, Part 1")
        False -> panic as "🛑 Failed Day 06, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 06, Part 2")
        False -> panic as "🛑 Failed Day 06, Part 2"
      }
    Error(s) -> panic as s
  }
}
