import day18/day18
import day18/parse
import day18/part1
import day18/part2
import common/runner

pub const part1_expected = 0

pub const part2_expected = 0

pub fn main() {
  let input = parse.read_input(day18.input_path)
  runner.run_day(18, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
