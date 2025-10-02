import day14/day14
import day14/parse
import day14/part1
import day14/part2
import gleam/io

pub const part1_expected = 0

pub const part2_expected = 0

pub fn main() {
  let input = parse.read_input(day14.input_path)
  runner.run_day(14, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
