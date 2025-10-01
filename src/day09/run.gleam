import common/runner
import day09/day09
import day09/parse
import day09/part1
import day09/part2

pub const part1_expected = 6_430_446_922_192

pub const part2_expected = 6_460_170_593_016

pub fn main() {
  let input = parse.read_input(day09.input_path)
  runner.run_day(9, input, [
    #("Part 1", part1_expected, part1.solve),
    #("Part 2", part2_expected, part2.solve),
  ])
}
