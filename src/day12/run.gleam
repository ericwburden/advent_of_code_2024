import day12/day12
import day12/parse
import day12/part1
import day12/part2
import gleam/io

pub const part1_expected = 1_344_578

pub const part2_expected = 814_302

pub fn main() {
  let input = parse.read_input(day12.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 12, Part 1")
        False -> panic as "🛑 Failed Day 12, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 12, Part 2")
        False -> panic as "🛑 Failed Day 12, Part 2"
      }
    Error(s) -> panic as s
  }
}
