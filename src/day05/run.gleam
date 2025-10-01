import common/runner
import day05/day05
import day05/parse
import day05/part1
import day05/part2

pub const part1_expected = 5087

pub const part2_expected = 4971

pub fn main() {
  let input = parse.read_input(day05.input_path)
  runner.run_day(5, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
