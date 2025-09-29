import day11/day11
import day11/parse
import day11/part1
import day11/part2
import gleam/io

pub const part1_expected = 197_357

pub const part2_expected = 234_568_186_890_978

pub fn main() {
  let input = parse.read_input(day11.input_path)

  case part1.solve(input) {
    Ok(result) ->
      case result == part1_expected {
        True -> io.println("✅ Passed Day 11, Part 1")
        False -> panic as "🛑 Failed Day 11, Part 1"
      }
    Error(s) -> panic as s
  }

  case part2.solve(input) {
    Ok(result) ->
      case result == part2_expected {
        True -> io.println("✅ Passed Day 11, Part 2")
        False -> panic as "🛑 Failed Day 11, Part 2"
      }
    Error(s) -> panic as s
  }
}
